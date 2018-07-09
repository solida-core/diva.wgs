import errno
import multiprocessing
import os.path


def cpu_count():
    return multiprocessing.cpu_count()


def conservative_cpu_count(reserve_cores=1, max_cores=5):
    cores = max_cores if cpu_count() > max_cores else cpu_count()
    return max(cores - reserve_cores, 1)


def references_abs_path():
    references = config.get('references')
    basepath = references['basepath']
    provider = references['provider']
    genome = references['genome_release']

    return [os.path.join(basepath, provider, genome)]


def resolve_single_filepath(basepath, filename):
    return [os.path.join(basepath, filename)]



def tmp_path(path=''):
    """
    if does not exists, create path and return it. If any errors, return
    default path
    :param path: path
    :return: path
    """
    default_path = os.getenv('TMPDIR', '/tmp')
    if path:
        try:
            os.makedirs(path)
        except OSError as e:
            if e.errno != errno.EEXIST:
                return default_path
        return path
    return default_path
