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

q = Query(Q, world=rasqal_world)
print q
print q.distinct
q.distinct = True
print 'after setting'
print q.distinct
print q

print q.get_graph_vertexes()
print q.adacency_matrix

print 'graph'
g = q.graph
print type(g), g
print g.nodes()
print g.edges()
print 'done'
print q.name
q.plot(show=True)