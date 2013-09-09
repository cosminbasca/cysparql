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

def expand(p):
    if isinstance(p, Pattern) and p.children is not None:
        for i in xrange(len(p.children)):
            p.children[i] = decomp(p.children[i])
            expand(p.children[i])

def THETA(graph_pattern, expand_all= False):
    p = decomp(graph_pattern)
    if expand_all:
        expand(p)
    return p

def print_operator_tree(gp, deppth = 0):
    print '\t'.join(['' for i in xrange(deppth)])+gp.operator_label
    for g in gp:
        print_operator_tree(g, deppth = deppth+1)


def KAPPA(graph_pattern):
    p = decomp(graph_pattern)
    if isinstance(p, TriplePattern):
        return PatternTypes.AND
    return p.type
# ----------------------------------------------------------------------------------------------------------------------
#
# simmilarity
#
# ----------------------------------------------------------------------------------------------------------------------

DELTA_FACTOR = 1.0 / 3.0

def delta_term(x1, x2, k = DELTA_FACTOR):
    s1 = unicode(x1.n3())
    s2 = unicode(x2.n3())
    d = float(distance(s1, s2))
    m = float(max(len(s1), len(s2)))
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

def DELTA(p1, p2):
    if isinstance(p1, Pattern) and isinstance(p2, Pattern):
        return delta_gpattern(p1, p2)
    elif isinstance(p1, TriplePattern) and isinstance(p2, TriplePattern):
        return delta_tpattern(p1, p2)


# ----------------------------------------------------------------------------------------------------------------------
#
# generalization
#
# ----------------------------------------------------------------------------------------------------------------------

def generalize_term(x1, x2):
    if delta_term(x1, x2) == 0:
        return x1
    return


def graph_pattern_matching(p1, p2, delta_max, mappings):
    assert isinstance(p1, GraphPattern)
    assert isinstance(p2, GraphPattern)
    s1 = THETA(p1)
    s2 = THETA(p2)

    if KAPPA(p1) != KAPPA(p2) \
        or len(s1.children) != len(s2.children):
        return {}
    while len(s1.children):
        g1 = s1.children.pop(0) # pop first
        found_mapping = False
        for g2 in s2.children:
            if (len(g1) == 1 and len(g2) == 1) or (isinstance(g1, TriplePattern) and isinstance(g2, TriplePattern)): # test for triple patterns
                if KAPPA(g1) == KAPPA(g2):
                    _g1 = mappings.get(g2, None)
                    if _g1 is None:
                        if DELTA(g1, g2) <= delta_max:
                            mappings[g2] = g1
                            found_mapping = True
                            break
                    else:
                        if DELTA(g1, g2) < DELTA(_g1, g2):
                            mappings[g2] = g1
                            s1.children.add(_g1)
                            found_mapping = True
                            break
            else:
                old_mappings = mappings
                mappings = graph_pattern_matching(g1, g2, delta_max, mappings)
                if mappings and len(mappings) > 0 and mappings != old_mappings:
                    found_mapping = True
        if not found_mapping:
            return {}
    return mappings

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
        example:Alice foaf:lastName "Alice" .
    }
}
    '''

    query = Query(qstring)
    # query.debug()
    GP = query.query_graph_pattern
    # GP.debug()
    tpatterns = list(query.triple_patterns)
    all_patterns = THETA(GP, True)
    print KAPPA(GP)

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
        # print 'min score T%d = %.2f'%(i+1, min(scores)), scores
        print 'min score T%d = %.2f'%(i+1, min(scores))

    mappings = graph_pattern_matching(GP[0], GP[2], 2, {})
    print
    print 'mappings --> ',mappings

if __name__ == '__main__':
    main()