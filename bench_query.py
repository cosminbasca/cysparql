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
SELECT ?label ?lat ?long
FROM <http://dbpedia.org>
WHERE {
        <http://dbpedia.org/resource/Karl_Gebhardt> rdfs:label ?label .
        FILTER (lang(?abstract) = 'en') .
        OPTIONAL {
            <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:lat ?lat .
            <http://dbpedia.org/resource/Karl_Gebhardt> wgs84_pos:long ?long
        }
        FILTER (lang(?abstract) = 'en')
}
'''

t1= time.time()
qry = Query.parse(q)
print "Took ", float(time.time()-t1) / 1000.0," ms"
qry.debug()
print qry.triple_patterns

print '--------'
for tp in qry.triple_patterns:
    for part in tp:
        print type(part), part