from time import time

__author__ = 'basca'

from cysparql import *
#
# w = RasqalWorld()
# literals = [
#     QueryLiteral.new_typed_literal(w, LiteralType.BOOLEAN, "1"),
#     QueryLiteral.new_string_literal(w, "muhaha"),
#     QueryLiteral.new_string_literal(w, "muhaha", lang="en"),
#     QueryLiteral.new_string_literal(w, "45.89", dtype="http://www.w3.org/2001/XMLSchema#float"),
# ]
# for tlit in literals:
#     print '------------------------------------------------------------------------------------'
#     print tlit, tlit.literal_type_label
#     print tlit.as_str(), ' -----> ',tlit.to_python().n3()
#

# disable_rasqal_warnings()
rasqal_world = RasqalWorld(default_wlevel=0)


Q = """
PREFIX foaf: <http://xmlns.com/foaf/>
PREFIX XXX: <http://xmlns.com/foafadsads/>
PREFIX YYY: <http://xmlns.com/foaf4525234/>
PREFIX example: <http://www.example.org/rdf#>
PREFIX example: <http://www.example.org/rdf#>
SELECT ?var_0 ?var_2 WHERE {
    ?var_0 foaf:knows ?var_2 .
    ?var_0 foaf:firstName ?var_1 .
}
    """

Q = """
PREFIX dbpo: <http://dbpedia.org/ontology/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
SELECT ?drug ?enzyme ?reaction  Where {
?drug1 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/drugCategory> <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugcategory/antibiotics> .
?drug2 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/drugCategory> <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugcategory/antiviralAgents> .
?drug3 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/drugCategory> <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugcategory/antihypertensiveAgents> .
?I1 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/interactionDrug2> ?drug1 .
?I1 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/interactionDrug1> ?drug .
?I2 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/interactionDrug2> ?drug2 .
?I2 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/interactionDrug1> ?drug .
?I3 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/interactionDrug2> ?drug3 .
?I3 <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/interactionDrug1> ?drug .
?drug <http://www.w3.org/2002/07/owl#sameAs> ?drug5 .
?drug5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://dbpedia.org/ontology/Drug> .
?drug <http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugbank/keggCompoundId> ?cpd .
?enzyme <http://bio2rdf.org/ns/kegg#xSubstrate> ?cpd .
?enzyme <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/kegg#Enzyme> .
?reaction <http://bio2rdf.org/ns/kegg#xEnzyme> ?enzyme .
?reaction <http://bio2rdf.org/ns/kegg#equation> ?equation .
}"""


# Q = '''
# SELECT ?predicate ?object WHERE {
#  	drugbank-drugs:DB00201 owl:sameAs ?caff .
# 	?caff ?predicate ?object .
# }
# '''
#
# q = Query(Q, pretty=True, world=rasqal_world)
# print q
# print q.distinct
# q.distinct = True
# print 'after setting'
# print q.distinct
# print q
#
# print q.get_graph_vertexes()
# t0 = time()
# print q.adacency_matrix
# print 'took ',(time()-t0)*1000,' miliseconds '
#
# print 'graph'
# g = q.graph
# print type(g), g
# print g.nodes()
# print g.edges()
# print 'done'
# print q.name
# # q.plot(show=True)
# print 'plot'
# q.plot(scale=4.0, show_predicates=True, layout='spring')

# url = 'http://www.w3.org/2002/07/owl#sameAs'
# print url is not None and REGEX_URL.search(url)
# print url is not None and REGEX_SPARQL_URL.search(url)
# url = '<http://www.w3.org/2002/07/owl#sameAs>'
# print url is not None and REGEX_URL.search(url)
# print url is not None and REGEX_SPARQL_URL.search(url)

Q = """
PREFIX example: <http://www.example.org/rdf#>
SELECT * WHERE {
    ?a example:p ?b1.
    ?a example:p ?b2.
    ?a example:p ?b3.
    ?a example:p ?b4.
    ?a example:p ?b5.
    ?a example:p ?b6.
    ?a example:q ?b6.
    ?b5 example:p ?x .
    ?b6 example:p ?y .
    ?a example:p ?b11.
    ?a example:p ?b21.
    ?a example:p ?b31.
    ?a example:p ?b41.
    ?a example:p ?b51.
    ?a example:p ?b61.
    ?a example:q ?b61.
    ?b51 example:p ?x1 .
    ?b61 example:p ?y1 .
    ?b11 example:p ?b1.
    ?b11 example:p ?b2.
    ?b11 example:p ?b3.
    ?b21 example:p ?b4.
    ?b21 example:p ?b5.
    ?b51 example:p ?b6.
    ?b51 example:q ?b6.
    ?b52 example:p ?x .
    ?b62 example:p ?y .
    ?b51 example:p ?x14 .
    ?b61 example:p ?y14 .
    ?b11 example:p ?b14.
    ?b11 example:p ?b24.
    ?b12 example:p ?b34.
    ?b22 example:p ?b44.
    ?b23 example:p ?b54.
    ?b53 example:p ?b64.
    ?b53 example:q ?b64.
    ?b53 example:p ?x4 .
    ?b63 example:p ?y4 .
}
"""

q = Query(Q, pretty=True)
# print q.adacency_matrix
from time import time
t0 = time()
stars = get_stars(q.triple_patterns)
print 'got {1} stars in {0} miliseconds'.format((time()-t0)*1000, len(stars))
print
for i,s in enumerate(stars):
    print '\nSTAR (%s): \n %s'%(i,s)
# q.plot(show=True)

print 'GRAPH = ',q.graph.edges()

