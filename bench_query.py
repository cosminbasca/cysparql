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

t1= time.time()
qry = Query.parse(q)
print "Took ", float(time.time()-t1) / 1000.0," ms"
qry.debug()
print qry.triple_patterns

print '--------'
for tp in qry.triple_patterns:
    for part in tp:
        print type(part), part