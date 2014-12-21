CySparql
========

CySparql is a python wrapper over the excellent heavy-duty C [Rasqal RDF](http://librdf.org/rasqal/) v0.9.33+ [SPARQL](http://www.w3.org/TR/rdf-sparql-query/) parser. The library is intended to give a pythonic feel to parsing SPARQL queries. There are several goodies included as well like:
* simple and fast star-pattern extraction from SPARQL queries
* node-edge (graph) visualizations of SPARQL queries
* simple descriptive command line utility to describe a given SPARQL query (from a file or read from stdin)
* auto pretty formatter for SPARQL queries (slower, than just parsing)

Important Notes
---------------
This software is the product of research carried out at the [University of Zurich](http://www.ifi.uzh.ch/ddis.html) and comes with no warranty whatsoever. Have fun!

TODO's
------
* The *librasqal* is not fully supported (e.g. filters, etc)
* The project is not documented (yet)

How to Compile the Project
--------------------------
Ensure that *librasqal* v0.9.33+ and *libraptor2* v2.0.13+ are installed on your system (either using the package manager of the OS or compiled from source).

To install **CySparql** you have two options: 1) manual installation (install requirements first) or 2) automatic with **pip**

**Manual** installation:
```sh
$ git clone https://github.com/cosminbasca/cysparql
$ cd cysparql
$ python setup.py install
```

Install the project with **pip**:
```sh
$ pip install https://github.com/cosminbasca/cysparql
```

Also have a look at the build.sh, clean.sh, test.sh scripts included in the codebase 

Basic Example
-------------
```python
from cysparql import *
q_string = """
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
}
"""

query = Query(q_string, pretty=True)
# should print:
#[[ 0.  0.  0.  0.  1.  0.  0.  0.  0.]
# [ 0.  0.  0.  0.  0.  1.  0.  0.  0.]
# [ 0.  0.  0.  1.  1.  1.  1.  1.  1.]
# [ 0.  0.  1.  0.  0.  0.  0.  0.  0.]
# [ 1.  0.  1.  0.  0.  0.  0.  0.  0.]
# [ 0.  1.  1.  0.  0.  0.  0.  0.  0.]
# [ 0.  0.  1.  0.  0.  0.  0.  0.  0.]
# [ 0.  0.  1.  0.  0.  0.  0.  0.  0.]
# [ 0.  0.  1.  0.  0.  0.  0.  0.  0.]]
print query.adjacency_matrix

# sould print: triple_patterns =  <cysparql.pattern.TriplePatternSequence object at 0x1049a4730>
print 'triple_patterns = ',query.triple_patterns

# should print:
#STAR (0): 
# [< ?a, http://www.example.org/rdf#p, ?b1 ,None>, < ?a, http://www.example.org/rdf#p, ?b2 ,None>, < ?a, http://www.example.org/rdf#p, ?b3 ,None>, < ?a, http://www.example.org/rdf#p, ?b4 ,None>, < ?a, http://www.example.org/rdf#p, ?b5 ,None>, < ?a, http://www.example.org/rdf#p, ?b6 ,None>, < ?a, http://www.example.org/rdf#q, ?b6 ,None>]
#
#STAR (1): 
# [< ?a, http://www.example.org/rdf#p, ?b5 ,None>, < ?b5, http://www.example.org/rdf#p, ?x ,None>]
#
#STAR (2): 
# [< ?a, http://www.example.org/rdf#p, ?b6 ,None>, < ?a, http://www.example.org/rdf#q, ?b6 ,None>, < ?b6, http://www.example.org/rdf#p, ?y ,None>]
stars = get_stars(query.triple_patterns)
for i,s in enumerate(stars):
    print '\nSTAR (%s): \n %s'%(i,s)

# if asciinet is installed
# should print:
#ASCII: 
#          ┌─────────────┐           
#          │     ?a      │           
#          └┬┬──┬─────┬┬┬┘           
#           ││  │     │││            
#           ││  │     ││└───┐        
#    ┌──────┼┘  │     ││    │        
#    │      │   │     ││    │        
#    v      v   │     ││    │        
#  ┌───┐  ┌───┐ │     ││    │        
#  │?b6│  │?b5│ │     ││    │        
#  └┬──┘  └─┬─┘ │     ││    │        
#   │       │   │     ││    │        
#   │     ┌─┘   │     │└────┼─────┐  
#   │     │     │     │     │     │  
#   v     v     v     v     v     v  
# ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
# │?y │ │?x │ │?b3│ │?b2│ │?b1│ │?b4│
# └───┘ └───┘ └───┘ └───┘ └───┘ └───┘
print 'ASCII: \n',query.ascii

# print the librasqal debug information
# should print:
#query verb: SELECT
#data graphs: []
#named variables: [variable(a), variable(b1), variable(b2), variable(b3), variable(b4), variable(b5), variable(b6), variable(x), variable(y)]
#anonymous variables: []
#projected variable names: a, b1, b2, b3, b4, b5, b6, x, y
#
#bound variables: [variable(a), variable(b1), variable(b2), variable(b3), variable(b4), variable(b5), variable(b6), variable(x), variable(y)]
#triples: [triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b1)), triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b2)), triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b3)), triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b4)), triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b5)), triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b6)), triple(variable(a), uri<http://www.example.org/rdf#q>, variable(b6)), triple(variable(b5), uri<http://www.example.org/rdf#p>, variable(x)), triple(variable(b6), uri<http://www.example.org/rdf#p>, variable(y))]
#prefixes: [prefix(example as http://www.example.org/rdf#)]
#query graph pattern: graph pattern[0] Basic(over 9 triples[triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b1)) ,triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b2)) ,triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b3)) ,triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b4)) ,triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b5)) ,triple(variable(a), uri<http://www.example.org/rdf#p>, variable(b6)) ,triple(variable(a), uri<http://www.example.org/rdf#q>, variable(b6)) ,triple(variable(b5), uri<http://www.example.org/rdf#p>, variable(x)) ,triple(variable(b6), uri<http://www.example.org/rdf#p>, variable(y))])
query.debug()
```

Thanks a lot to
---------------
* [University of Zurich](http://www.ifi.uzh.ch/ddis.html) and the [Swiss National Science Foundation](http://www.snf.ch/en/Pages/default.aspx) for generously funding the research that led to this software.
