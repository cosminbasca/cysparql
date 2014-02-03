from urlparse import urlparse
import re

REGEX_URL = re.compile(
    r'^https?://'  # http:// or https://
    r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'  # domain...
    r'localhost|'  # localhost...
    r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' # ...or ip
    r'(?::\d+)?'  # optional port
    r'(?:/?|[/?]\S+)$', re.IGNORECASE)

__rasqal_warning_level__ = 50

def disable_rasqal_warnings():
    global __rasqal_warning_level__
    __rasqal_warning_level__ = 0

def set_rasqal_warning_level(wlevel):
    global __rasqal_warning_level__
    __rasqal_warning_level__ = wlevel

def get_rasqal_warning_level():
    global __rasqal_warning_level__
    return __rasqal_warning_level__


def enum(*sequential, **named):
    """taken from: http://stackoverflow.com/questions/36932/how-can-i-represent-an-enum-in-python"""
    enums = dict(zip(sequential, range(len(sequential))), **named)
    reverse = dict((value, key) for key, value in enums.iteritems())
    enums['reverse_mapping'] = reverse
    return type('Enum', (), enums)

def term(uri):
    sp = '#' if uri.rfind('#') != -1 else '/'
    return uri.rsplit(sp, 1)[1]

def all_terms(uri):
    return [t for t in urlparse(uri).path.split('/')[1:] if t]

def is_valid_url(url):
    return url is not None and REGEX_URL.search(url)