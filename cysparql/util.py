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
SPARQL_VERB = re.compile(r'(select|SELECT|construct|CONSTRUCT|ask|ASK|describe|DESCRIBE)')
REGEX_PREFIX_IN_USE = re.compile(r'[aZ]')

PN_CHARS_BASE = r'[A-Z]|[a-z]'
PN_CHARS_U = PN_CHARS_BASE + r'|_'
PN_CHARS = 	PN_CHARS_U + r'|\-|[0-9]'
PN_PREFIX = r'('+PN_CHARS_BASE + r')((' + PN_CHARS + r'|\.)*' + PN_CHARS + r')+' + r':'
REGEX_PREFIX = re.compile(PN_PREFIX)

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
    from namespace import get_namespace_prefix, get_namespace_url, to_sparql_prefix_definition
    if not isinstance(sparql, (str, unicode)):
        raise ValueError('sparql must be string or unicode')

    verb_idx = SPARQL_VERB.search(sparql).start(0)
    pref_declarations = sparql[:verb_idx]
    sparql = sparql[verb_idx:]

    prefixes = dict()

    def url_to_prefix(match):
        uri = match.group()[1:-1]
        ns, term = uri_ns_split(uri)
        prefix = get_namespace_prefix(ns)
        if prefix:
            pattern = r'('+prefix.lower()+r'|'+prefix.upper()+r')\s*:\s+<'+ns+r'>'
            if not bool(re.compile(pattern).search(pref_declarations)):
                prefixes[prefix] = ns
            return '%s:%s'%(prefix, term)
        return '<%s>'%uri

    def namespace_handler(match):
        prefix = match.group()[:-1]
        if prefix not in prefixes:
            uri = get_namespace_url(prefix)
            if prefix:
                prefixes[prefix] = uri
        return match.group()

    # sanitize
    sparql = re.sub(REGEX_PREFIX, namespace_handler, sparql)
    # beautify
    sparql = re.sub(REGEX_SPARQL_URL, url_to_prefix, sparql)

    sparql = '%(new_prefixes)s\n%(old_prefixes)s\n\n%(query)s'%{
        'new_prefixes'  :to_sparql_prefix_definition(prefixes).strip(),
        'old_prefixes'  :pref_declarations.strip(),
        'query'         :sparql.strip()
    }

    return sparql
