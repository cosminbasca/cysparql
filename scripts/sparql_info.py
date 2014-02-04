#!/usr/bin/env python
import argparse
from cysparql import Query, disable_rasqal_warnings

# noinspection PyCallingNonCallable
def main():
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
        print 'ADJACENCY MATRIX     : ',query.adacency_matrix
        print 'NAME                 : ',query.query_id
        print '----------------------------------------------------------------------------------------------------'
        print '=> [query save to pdf] \n'
        query.plot(show=False)
        print '----------------------------------------------------------------------------------------------------'

if __name__ == '__main__':
    main()