__author__ = 'basca'

from cysparql import *
import time

q = '''
 SELECT ?mail ?phone ?doctor
    WHERE {
        ?professor <http://www.lehigh.edu/~zhp2/2004/0401/univ-bench.owl#emailAddress> ?mail .
        ?professor <http://www.lehigh.edu/~zhp2/2004/0401/univ-bench.owl#telephone> ?phone .
        ?professor <http://www.lehigh.edu/~zhp2/2004/0401/univ-bench.owl#doctoralDegreeFrom> ?doctor .
        ?professor <http://www.lehigh.edu/~zhp2/2004/0401/univ-bench.owl#name> "FullProfessor1" .
    } LIMIT 11
'''

q = '''
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX wgs84_pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>
SELECT *
FROM <http://dbpedia.org>
WHERE {
        <http://dbpedia.org/resource/Karl_Gebhardt> rdfs:label ?label .
        OPTIONAL {
            <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:lat ?lat .
            <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:long ?long
        }
        FILTER (lang(?label) = 'en')
}
'''

t1= time.time()
qry = Query(q)
print qry.query_string
print "Took ", float(time.time()-t1) * 1000.0," ms"
qry.debug()
print qry.triple_patterns

print '--------'
for tp in qry.triple_patterns:
    print 'SUBJECT = ',tp.subject
    print 'PREDICATE = ',tp.predicate
    print 'OBJECT = ',tp.object
    print 'iter...'
    for part in tp:
        print type(part), part

print '-------'
print qry.vars
print qry.projections
for var in qry.vars:
    print var.name
print '-------'
print qry.graph_patterns
for gp in qry.graph_patterns:
    print gp

print '---------'
label = qry.get_variable(0)
print label.name, label.n3()

print qry.variables['label'].n3()

vt = qry.create_vars_table()
user2 = vt.add_new_variable("user2")
print user2, type(user2)
vt.add_variable(list(qry.projections)[0])
print list(qry.projections)[0]
n = list(qry.projections)[0].name
print 'name ',n
v1 = vt['user2']
print 'v1 = ',v1
v2 = vt[n]
print 'v2 = ',v2
del vt
print v2
print v1
