#!/usr/bin/env python
import argparse
from cysparql import Query, disable_rasqal_warnings

# noinspection PyCallingNonCallable
def sparql_info():
    """
usage: sparql_info.py [-h] QUERY

Display information about the supplied sparql query

positional arguments:
  QUERY       the SPARQL query file (file containing the sparql query). Lines
              starging with '--' are ignored

optional arguments:
  -h, --help  show this help message and exit
    """
    parser = argparse.ArgumentParser(description='Display information about the supplied sparql query')
    parser.add_argument(metavar="QUERY", dest='queryfile',
                        help="the SPARQL query file (file containing the sparql query). Lines starging with '--' are ignored")
    parser.add_argument('--plot', dest='plot', action='store_true',
                       help='plot to file (if matplotlib is installed, nothing will happen otherwise)')

    args = parser.parse_args()
    disable_rasqal_warnings()

    with open(args.queryfile, 'r+') as QFILE:
        q_string = ''.join([ l for l in QFILE if not l.strip().startswith('--') ])
        query = Query(q_string)
        print '----------------------------------------------------------------------------------------------------'
        print '=> [parsed the following query] \n'
        print str(query)
        print '----------------------------------------------------------------------------------------------------'
        print '=> [query information] \n'
        query.debug()
        print 'IS STAR              : ',query.star
        print 'ADJACENCY MATRIX     : \n',query.adacency_matrix
        print 'NAME                 : ',query.query_id
        if args.plot:
            print '----------------------------------------------------------------------------------------------------'
            print '=> [query save to %s.pdf] \n'%query.query_id
            query.plot(show=False)
        print '----------------------------------------------------------------------------------------------------'
