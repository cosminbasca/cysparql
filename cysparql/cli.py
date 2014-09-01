import argparse
from cysparql import Query, disable_rasqal_warnings
from cysparql.__version__ import str_version

# noinspection PyCallingNonCallable
def sparql_info():
    parser = argparse.ArgumentParser(description='Display information about the supplied sparql query')
    parser.add_argument(metavar="QUERY", dest='queryfile',
                        help="the SPARQL query file (file containing the sparql query). Lines starging with '--' are ignored")
    parser.add_argument('--plot', dest='plot', action='store_true',
                        help='plot to file (if matplotlib is installed, nothing will happen otherwise)')

    args = parser.parse_args()
    disable_rasqal_warnings()

    with open(args.queryfile, 'r+') as QFILE:
        query_string = ''.join([l for l in QFILE if not l.strip().startswith('--')])
        query = Query(query_string, pretty=True)

        stars_info = ''.join(['\nStar ({0}): \n\t{1}'.format(i, '\n\t'.join([str(tp) for tp in star]))
                              for i, star in enumerate(query.stars)])

        query_info = """
------------------------------------------------------------------------------------------------------------------------
cysparql version {0[version]}

INPUT STRING:
{0[query_string]}

PRETTY STRING:
{0[pretty_query_string]}

VERB            : {0[verb]}
NAME            : {0[name]}
LIMIT           : {0[limit]}
OFFSET          : {0[offset]}
DISTINCT        : {0[distinct]}
EXPLAIN         : {0[explain]}
WILDCARD        : {0[wildcard]}
PREFIXES        : {0[prefixes]}
IS STAR         : {0[is_star]}
VARIABLES       : {0[variables]}
PROJECTIONS     : {0[projections]}

TRIPLE PATTERNS:
{0[triple_patterns]}

STARS:
{0[stars]}

ADJACENCY MATRIX:
{0[adj_matrix]}

{0[ascii]}
------------------------------------------------------------------------------------------------------------------------
        """.format({
            'version': str_version,
            'query_string': query_string,
            'verb': query.verb,
            'name': query.name,
            'limit': query.limit,
            'offset': query.offset,
            'distinct': query.distinct,
            'explain': query.explain,
            'wildcard': query.wildcard,
            'prefixes': [str(prefix) for prefix in query.prefixes],
            'is_star': query.is_star(),
            'pretty_query_string': str(query),
            'variables': [str(var) for var in query.vars],
            'projections': [str(var) for var in query.projections],
            'triple_patterns': '\n'.join([str(tp) for tp in query.triple_patterns]),
            'stars': stars_info,
            'adj_matrix': query.adacency_matrix,
            'ascii': query.ascii,
        })

        print query_info