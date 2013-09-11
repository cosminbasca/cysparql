from collections import namedtuple
from itertools import count
from pprint import pprint
from cysparql import *
# requires python-Levenshtein
from Levenshtein import distance
from rdflib.term import URIRef, Literal

__author__ = 'basca'

disable_rasqal_warnings()

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
    # print '(',delta_term(t1.subject, t2.subject),' + ',delta_term(t1.predicate, t2.predicate),' + ',delta_term(t1.object, t2.object),')'
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
    return delta_term(p1, p2)


# ----------------------------------------------------------------------------------------------------------------------
#
# generalization
#
# ----------------------------------------------------------------------------------------------------------------------

def unique_var(variables):
    for i in count():
        _var = '?var_%d'%i
        if _var not in variables:
            return _var

def generalize_term(x1, x2, tp_vars, term_mapping):
    """tp_vars = triple pattern vars"""
    if DELTA(x1, x2) == 0:
        return x1
    else:
        new_var = unique_var(tp_vars)
        if x1 in term_mapping and x2 in term_mapping:
            return term_mapping[x1]
        tp_vars.add(new_var)
        term_mapping[x1] = new_var
        term_mapping[x2] = new_var
        return new_var

def gemeralize_tpattern(t1, t2, tp_vars, term_mapping):
    assert isinstance(t1, TriplePattern)
    assert isinstance(t2, TriplePattern)

    for v in set([ part.n3() for tp in [t1, t2] for part in tp if isinstance(part, QueryVar) ]):
        tp_vars.add(v)

    for i in xrange(3):
        # pprint(term_mapping)
        # print 'TEST : ',t1[i],' , ',t2[i]
        part = generalize_term(t1[i], t2[i], tp_vars, term_mapping)
        # print '\t=> ',part
        if isinstance(part, basestring) and part.startswith('?'):
            tp_vars.add(part)

# ----------------------------------------------------------------------------------------------------------------------
#
# matching
#
# ----------------------------------------------------------------------------------------------------------------------

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
        # print 'TEST G1 = ',g1
        found_mapping = False
        for g2 in s2.children:
            # print '\t with G2 = ',g2
            if (len(g1) == 1 and len(g2) == 1) or (isinstance(g1, TriplePattern) and isinstance(g2, TriplePattern)): # test for triple patterns
                if KAPPA(g1) == KAPPA(g2):
                    _g1 = mappings.get(g2, None)
                    _delta = DELTA(g1, g2)
                    if _g1 is None:
                        # print '\tDELTA = ',_delta
                        # print '\tD_MAX = ',delta_max
                        if _delta <= delta_max:
                            mappings[g2] = g1
                            found_mapping = True
                            break
                    else:
                        # print '\tDELTA = ',_delta
                        # print "\tD**   = ",DELTA(_g1, g2)
                        if _delta < DELTA(_g1, g2):
                            mappings[g2] = g1
                            s1.children.add(_g1)
                            found_mapping = True
                            break
            else:
                old_mappings = mappings
                mappings = graph_pattern_matching(g1, g2, delta_max, mappings)
                if mappings and len(mappings) > 0 and mappings != old_mappings:
                    found_mapping = True

        # print '\tFOUND = ',found_mapping
        if not found_mapping:
            return {}
    return mappings


def generalize_queries(q1, q2, delta_max = 1.0):
    if isinstance(q1, basestring):
        q1 = Query(q1)
    if isinstance(q2, basestring):
        q2 = Query(q2)

    q_template = str(q1)
    tp_mapping = graph_pattern_matching(q1.query_graph_pattern, q2.query_graph_pattern, delta_max, {})
    if len(tp_mapping) == 0:
        return None

    term_mapping = {}
    tp_vars = set()
    for t1, t2 in tp_mapping.items():
        gemeralize_tpattern(t1, t2, tp_vars, term_mapping)
    # generalize
    # print 'TERM MAPPINGS'
    # pprint(term_mapping)
    for term, mapping in term_mapping.items():
        # print '\treplace ',term,type(term),' - ',mapping,type(mapping)
        s1 = term if isinstance(term, basestring) else term.n3()
        s2 = mapping if isinstance(mapping, basestring) else mapping.n3()
        q_template = q_template.replace('"%s"'%s1 if isinstance(term, Literal) else s1,
                                        '"%s"'%s2 if isinstance(mapping, Literal) else s2)

    return q_template

# ----------------------------------------------------------------------------------------------------------------------
#
# test
#
# ----------------------------------------------------------------------------------------------------------------------
def test_1():
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
        print 'min score T%d = %.2f'%(i+1, min(scores)), scores
        # print 'min score T%d = %.2f'%(i+1, min(scores))

    mappings = graph_pattern_matching(GP[0], GP[2], 2, {})
    print 'mappings --> ',mappings


def test_2():
    Q1 = """
PREFIX foaf: <http://xmlns.com/foaf/>
PREFIX example: <http://www.example.org/rdf#>
SELECT ?abcd ?b WHERE {
    ?abcd foaf:knows ?b .
    ?abcd foaf:firstName "Marley" .
}
    """

    Q2 ="""
PREFIX foaf: <http://xmlns.com/foaf/>
PREFIX example: <http://www.example.org/rdf#>
SELECT ?b WHERE {
    ?s foaf:knows ?another .
    ?s foaf:firstName "Bob" .
}
    """

    Q3 = """
PREFIX foaf: <http://xmlns.com/foaf/>
PREFIX example: <http://www.example.org/rdf#>
SELECT ?var_0 ?var_2 WHERE {
    ?var_0 foaf:knows ?var_2 .
    ?var_0 foaf:firstName ?var_1 .
}
    """

    q1 = Query(Q1)
    q2 = Query(Q2)
    print '--------------------------------------------------------------------------------------------------------'
    print 'Query 1 -> '
    print q1
    print '--------------------------------------------------------------------------------------------------------'
    print 'Query 2 -> '
    print q1
    print '--------------------------------------------------------------------------------------------------------'

    # M  = graph_pattern_matching(q1.query_graph_pattern, q2.query_graph_pattern, 1.0, {})
    # print 'Mappings -> '
    # pprint(M)

    gen_q = generalize_queries(q1, q2, delta_max=1.0)
    print 'Generalized Query -> '
    print gen_q

if __name__ == '__main__':
    # test_1()
    test_2()