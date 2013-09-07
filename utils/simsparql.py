from collections import namedtuple
from pprint import pprint
from cysparql import *
# requires python-Levenshtein
from Levenshtein import distance
from rdflib.term import URIRef, Literal

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
    tps = list(gp.triple_patterns)
    return Pattern(
        type=PatternTypes.AND,
        children=tps
    ) if len(tps) > 1 else tps[0]

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

def print_operator_tree(gp, deppth = 0):
    print '\t'.join(['' for i in xrange(deppth)])+gp.operator_label
    for g in gp:
        print_operator_tree(g, deppth = deppth+1)

# ----------------------------------------------------------------------------------------------------------------------
#
# simmilarity and merging
#
# ----------------------------------------------------------------------------------------------------------------------

DELTA_FACTOR = 1.0 / 3.0

def delta_term(x1, x2, k = DELTA_FACTOR):
    s1 = unicode(x1.n3())
    s2 = unicode(x2.n3())
    d = float(distance(s1, s2))
    m = float(max(len(s1), len(s2)))
    # print type(x1), s1, ' ----- ', type(x2), s2, ' ----- ',d, ', ',m

    if isinstance(x1, QueryVar) and isinstance(x2, QueryVar):
        assert 0 <= k < 1, 'k is not between 0 and 1, for the x1,x2 in Vars'
        return d / (m + 1.0) * float(k)
    elif (isinstance(x1, URIRef) and isinstance(x2, URIRef)) \
        or (isinstance(x1, Literal) and isinstance(x2, Literal)):
        return d / (m + 1.0)
    else:
        return 1.0

def delta_tpattern(t1, t2):
    assert isinstance(t1, TriplePattern)
    assert isinstance(t2, TriplePattern)
    return  delta_term(t1.subject, t2.subject) + \
            delta_term(t1.predicate, t2.predicate) + \
            delta_term(t1.object, t2.object)

def delta_gpattern(p1, p2):
    assert isinstance(p1, Pattern)
    assert isinstance(p2, Pattern)
    if len(p1.children) == 1 and len(p2.children) == 1:
        return delta_tpattern(p1.children[0], p2.children[0])
    return float('Inf')

def generalize_term(x1, x2):
    if delta_term(x1, x2) == 0:
        return x1
    return

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
    } UNION {
        example:Bob foaf:firstName "Bob" .
        example:Bob foaf:lastName "Alice" .
    }
}
    '''

    query = Query(qstring)
    # query.debug()
    GP = query.query_graph_pattern
    # GP.debug()
    tpatterns = list(query.triple_patterns)
    all_patterns = total_decomp(GP)

    pprint(all_patterns)
    t1,t2,t3,t4,t6,t5 = tpatterns
    t = [t1, t2, t6, t5, t4, t3]
    print 'T1: ', t[0]
    print 'T2: ', t[1]
    print 'T3: ', t[2]
    print 'T4: ', t[3]
    print 'T5: ', t[4]
    print 'T6: ', t[5]

    for i in xrange(len(t)):
        _delta = lambda itm: delta_tpattern(t[i], itm)
        _rest = t[:i]+t[i+1:]
        scores = map(_delta, _rest)
        print 'min score T%d = %.2f'%(i+1, min(scores)), scores

if __name__ == '__main__':
    main()