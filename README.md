CySparql
========

CySparql is a python wrapper over the excellent heavy-duty C [Rasqal RDF](http://librdf.org/rasqal/) v0.9.32+ [SPARQL](http://www.w3.org/TR/rdf-sparql-query/) parser. The library is intended to give a pythonic feel to parsing SPARQL queries. There are several goodies included as well like:
* simple and fast star-pattern extraction from SPARQL queries
* node-edge (graph) visualizations of SPARQL queries
* simple descriptive command line utility to describe a given SPARQL query (from a file or read from stdin)
* auto pretty formatter for SPARQL queries (slower, than just parsing)

Important Notes
---------------
This software is the product of research carried out at the [University of Zurich](http://www.ifi.uzh.ch/ddis.html) and comes with no warrenty whatsoever. Have fun!

TODO's
------
* The *librasqal* is not fully supported (e.g. filters, etc)
* The project is not documented (yet)

How to Compile the Project
--------------------------
Ensure that *librasqal* v0.9.32+ and *libraptor2* v2.0.13+ are installed on your system (either using the package manager of the OS or compiled from source).

To install **CySparql** you have two options: 1) manual installation (install requirements first) or 2) automatic with **pip**

Install the project manually from source (after downloading it locally):
```bash
$ python setup.py install
```

Install the project with pip:
```bash
$ pip install https://github.com/cosminbasca/cysparql
```

Also have a look at the build.sh, clean.sh, test.sh scripts included in the codebase 

Thanks a lot to
---------------
* [University of Zurich](http://www.ifi.uzh.ch/ddis.html) and the [Swiss National Science Foundation](http://www.snf.ch/en/Pages/default.aspx) are generously funding our research on graph processing and the development of this package.
