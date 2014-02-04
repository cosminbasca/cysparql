from urlparse import urlparse
import re

URL_PATTERN = r'https?://'\
    r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'\
    r'localhost|'\
    r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'\
    r'(?::\d+)?'\
    r'(?:/?|[/?]\S+)'

REGEX_URL = re.compile(URL_PATTERN, re.IGNORECASE)
REGEX_ONLY_URL = re.compile(r'^'+URL_PATTERN+r'$', re.IGNORECASE)
REGEX_SPARQL_URL = re.compile(r'<'+URL_PATTERN+r'>', re.IGNORECASE)

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


def uri_ns_split(uri):
    sp = '#' if uri.rfind('#') != -1 else '/'
    ns, term = uri.rsplit(sp, 1)
    return '%s%s'%(ns,sp), term


def all_terms(uri):
    return [t for t in urlparse(uri).path.split('/')[1:] if t]


def is_valid_url(url):
    return url is not None and REGEX_ONLY_URL.search(url)


def prettify(sparql):
    from prefix import get_prefix, to_sparql_prefix_definition
    if not isinstance(sparql, (str, unicode)):
        raise ValueError('sparql must be string or unicode')

    prefixes = dict()

    def url_to_prefix(match):
        uri = match.group()[1:-1]
        ns, term = uri_ns_split(uri)
        prefix = get_prefix(ns)
        if prefix:
            prefixes[prefix] = ns
            return '%s:%s'%(prefix, term)
        return '<%s>'%uri

    sparql = re.sub(REGEX_SPARQL_URL, url_to_prefix, sparql)
    sparql = '%s\n%s'%(to_sparql_prefix_definition(prefixes), sparql)

    return sparql