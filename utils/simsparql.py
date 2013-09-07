from cysparql import *

__author__ = 'basca'


# ----------------------------------------------------------------------------------------------------------------------
#
# graph pattern decomposition
#
# ----------------------------------------------------------------------------------------------------------------------

def decompose(graph_pattern):
    op = graph_pattern.operator
    if op == Operator.OPTIONAL:
        return op.sub_graph_patterns
    elif op == Operator.UNION:
        pass
    else: # defaults to AND
        pass


def  print_operator_tree(gp, deppth = 0):
    print '\t'.join(['' for i in xrange(deppth)])+gp.operator_label
    for g in gp:
        print_operator_tree(g, deppth = deppth+1)


# ----------------------------------------------------------------------------------------------------------------------
#
# simmilarity and merging
#
# ----------------------------------------------------------------------------------------------------------------------



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
    }
}
    '''

    query = Query(qstring)
    query.debug()
    GP = query.query_graph_pattern
    print_operator_tree(GP)


if __name__ == '__main__':
    main()