from collections import namedtuple
from pprint import pprint
from cysparql import *

__author__ = 'basca'

PatternTypes = enum(UNION='union', OPTIONAL='optional', AND='and')
Pattern = namedtuple('Pattern', ['type', 'children'])

# ----------------------------------------------------------------------------------------------------------------------
#
# graph pattern decomposition
#
# ----------------------------------------------------------------------------------------------------------------------
def decomp_union(gp):
    # test
    if not isinstance(gp, GraphPattern): return None
    if gp.operator != Operator.UNION:
        return None
    # decomp
    return Pattern(
        type=PatternTypes.UNION,
        children=list(gp.sub_graph_patterns)
    )

def decomp_and(gp):
    # test
    if isinstance(gp, TriplePattern):
        return gp

    if not isinstance(gp, GraphPattern): return None
    if gp.operator != Operator.BASIC:
        return None
    # decomp
    return Pattern(
        type=PatternTypes.AND,
        children=list(gp.triple_patterns)
    )

def decomp_optional(gp):
    # test
    if not isinstance(gp, GraphPattern): return None
    if gp.operator != Operator.GROUP:
        return None
    is_optional = False
    for g in gp:
        if g.operator == Operator.OPTIONAL:
            is_optional = True
            break
    if not is_optional:
        return None
    # decomp
    gps = []
    for g in gp:
        if g.operator != Operator.OPTIONAL:
            gps.append(g)
        else:
            gps.extend(list(g.sub_graph_patterns))
    return Pattern(
        type=PatternTypes.OPTIONAL,
        children=gps
    )

def decomp(graph_pattern):
    for decomp_func in [decomp_union, decomp_optional, decomp_and]:
        res = decomp_func(graph_pattern)
        if res != None:
            return res
    return None

def total_decomp(graph_pattern):
    def _decomp(p):
        if isinstance(p, Pattern) and p.children is not None:
            for i in xrange(len(p.children)):
                p.children[i] = decomp(p.children[i])
                _decomp(p.children[i])

    p = decomp(graph_pattern)
    _decomp(p)
    return p

def  print_operator_tree(gp, deppth = 0):
    print '\t'.join(['' for i in xrange(deppth)])+gp.operator_label
    for g in gp:
        print_operator_tree(g, deppth = deppth+1)


# ----------------------------------------------------------------------------------------------------------------------
#
# simmilarity and merging
#
# ----------------------------------------------------------------------------------------------------------------------



# ----------------------------------------------------------------------------------------------------------------------
#
# test
#
# ----------------------------------------------------------------------------------------------------------------------
def main():
    qstring = '''
PREFIX foaf: <http://xmlns.com/foaf/>
PREFIX example: <http://www.example.org/rdf#>
SELECT * WHERE {
    {
        ?p1 foaf:firstName "Alice" .
        ?p1 ?associationWith example:Bob .
    } UNION {
        ?p2 foaf:firstName "Carol" .
        OPTIONAL {
            ?p2 ?associationWith ?p1 .
        }
    }
}
    '''

    query = Query(qstring)
    GP = query.query_graph_pattern
    all_patterns = total_decomp(GP)

    pprint(all_patterns)

if __name__ == '__main__':
    main()