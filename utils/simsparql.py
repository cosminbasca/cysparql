from cysparql import *

__author__ = 'basca'


# ----------------------------------------------------------------------------------------------------------------------
#
# graph pattern decomposition
#
# ----------------------------------------------------------------------------------------------------------------------

GP_UNION = 'union'
GP_AND = 'and'
GP_OPTIONAL = 'optional'

def decompose(graph_pattern, decomp_type):
    if decomp_type == GP_UNION:
        pass
    elif decomp_type == GP_OPTIONAL:
        pass
    elif decomp_type == GP_AND:
        pass




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
    print GP.operator
    print GP.operator_label


if __name__ == '__main__':
    main()