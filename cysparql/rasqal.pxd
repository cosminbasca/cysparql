#
# author: Cosmin Basca
#
# Copyright 2010 University of Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from libc.stdio cimport *
from libc.stdlib cimport *
from cysparql.raptor2 cimport *


__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# the rasqal sparql parsing library
#
#-----------------------------------------------------------------------------------------------------------------------
cdef extern from "rasqal/rasqal.h" nogil:
    #forward declarations
    ctypedef struct rasqal_variable
    ctypedef struct rasqal_xsd_decimal
    ctypedef struct rasqal_xsd_datetime
    ctypedef struct rasqal_world
    ctypedef struct rasqal_query
    ctypedef union literal_value
    ctypedef struct rasqal_literal
    ctypedef struct rasqal_variable
    ctypedef struct rasqal_triple
    ctypedef struct rasqal_data_graph
    ctypedef struct rasqal_prefix
    ctypedef struct rasqal_update_operation
    ctypedef struct rasqal_variables_table
    ctypedef struct rasqal_expression
    ctypedef struct raptor_iostream
    ctypedef struct rasqal_solution_modifier
    ctypedef struct rasqal_xsd_date

    #enums
    ctypedef enum rasqal_feature:
        RASQAL_FEATURE_NO_NET
        RASQAL_FEATURE_RAND_SEED
        RASQAL_FEATURE_LAST = RASQAL_FEATURE_RAND_SEED

    ctypedef enum rasqal_update_type:
        RASQAL_UPDATE_TYPE_UNKNOWN
        RASQAL_UPDATE_TYPE_CLEAR
        RASQAL_UPDATE_TYPE_CREATE
        RASQAL_UPDATE_TYPE_DROP
        RASQAL_UPDATE_TYPE_LOAD
        RASQAL_UPDATE_TYPE_UPDATE
        RASQAL_UPDATE_TYPE_ADD
        RASQAL_UPDATE_TYPE_MOVE
        RASQAL_UPDATE_TYPE_COPY
        RASQAL_UPDATE_TYPE_LAST

    ctypedef enum rasqal_update_flags:
        RASQAL_UPDATE_FLAGS_SILENT
        RASQAL_UPDATE_FLAGS_DATA

    ctypedef enum rasqal_update_graph_applies:
        RASQAL_UPDATE_GRAPH_ONE
        RASQAL_UPDATE_GRAPH_DEFAULT
        RASQAL_UPDATE_GRAPH_NAMED
        RASQAL_UPDATE_GRAPH_ALL

    ctypedef enum rasqal_query_verb:
        RASQAL_QUERY_VERB_UNKNOWN
        RASQAL_QUERY_VERB_SELECT
        RASQAL_QUERY_VERB_CONSTRUCT
        RASQAL_QUERY_VERB_DESCRIBE
        RASQAL_QUERY_VERB_ASK
        RASQAL_QUERY_VERB_DELETE
        RASQAL_QUERY_VERB_INSERT
        RASQAL_QUERY_VERB_UPDATE
        RASQAL_QUERY_VERB_LAST

    ctypedef enum rasqal_query_results_type:
        RASQAL_QUERY_RESULTS_BINDINGS
        RASQAL_QUERY_RESULTS_BOOLEAN
        RASQAL_QUERY_RESULTS_GRAPH
        RASQAL_QUERY_RESULTS_SYNTAX
        RASQAL_QUERY_RESULTS_UNKNOWN
        RASQAL_QUERY_RESULTS_LAST = RASQAL_QUERY_RESULTS_UNKNOWN

    ctypedef enum rasqal_compare_flags:
        RASQAL_COMPARE_NOCASE
        RASQAL_COMPARE_XQUERY
        RASQAL_COMPARE_RDF
        RASQAL_COMPARE_URI
        RASQAL_COMPARE_SAMETERM

    ctypedef enum rasqal_graph_pattern_operator:
        RASQAL_GRAPH_PATTERN_OPERATOR_UNKNOWN
        RASQAL_GRAPH_PATTERN_OPERATOR_BASIC
        RASQAL_GRAPH_PATTERN_OPERATOR_OPTIONAL
        RASQAL_GRAPH_PATTERN_OPERATOR_UNION
        RASQAL_GRAPH_PATTERN_OPERATOR_GROUP
        RASQAL_GRAPH_PATTERN_OPERATOR_GRAPH
        RASQAL_GRAPH_PATTERN_OPERATOR_FILTER
        RASQAL_GRAPH_PATTERN_OPERATOR_LET
        RASQAL_GRAPH_PATTERN_OPERATOR_SELECT
        RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE
        RASQAL_GRAPH_PATTERN_OPERATOR_MINUS
        RASQAL_GRAPH_PATTERN_OPERATOR_LAST

    ctypedef enum rasqal_query_results_format_flags:
        RASQAL_QUERY_RESULTS_FORMAT_FLAG_READER
        RASQAL_QUERY_RESULTS_FORMAT_FLAG_WRITER

    ctypedef enum rasqal_literal_type:
        RASQAL_LITERAL_UNKNOWN
        RASQAL_LITERAL_BLANK
        RASQAL_LITERAL_URI
        RASQAL_LITERAL_STRING
        RASQAL_LITERAL_XSD_STRING
        RASQAL_LITERAL_BOOLEAN
        RASQAL_LITERAL_INTEGER
        RASQAL_LITERAL_FLOAT
        RASQAL_LITERAL_DOUBLE
        RASQAL_LITERAL_DECIMAL
        RASQAL_LITERAL_DATETIME
        RASQAL_LITERAL_FIRST_XSD
        RASQAL_LITERAL_LAST_XSD
        RASQAL_LITERAL_UDT
        RASQAL_LITERAL_PATTERN
        RASQAL_LITERAL_QNAME
        RASQAL_LITERAL_VARIABLE
        RASQAL_LITERAL_INTEGER_SUBTYPE
        RASQAL_LITERAL_DATE
        RASQAL_LITERAL_LAST

    ctypedef enum rasqal_variable_type:
        RASQAL_VARIABLE_TYPE_UNKNOWN
        RASQAL_VARIABLE_TYPE_NORMAL
        RASQAL_VARIABLE_TYPE_ANONYMOUS

    ctypedef enum rasqal_triple_parts:
        RASQAL_TRIPLE_NONE
        RASQAL_TRIPLE_SUBJECT
        RASQAL_TRIPLE_PREDICATE
        RASQAL_TRIPLE_OBJECT
        RASQAL_TRIPLE_ORIGIN
        RASQAL_TRIPLE_GRAPH
        RASQAL_TRIPLE_SPO
        RASQAL_TRIPLE_SPOG

    ctypedef enum rasqal_triples_source_feature:
        RASQAL_TRIPLES_SOURCE_FEATURE_NONE
        RASQAL_TRIPLES_SOURCE_FEATURE_IOSTREAM_DATA_GRAPH

    ctypedef enum rasqal_data_graph_flags:
        RASQAL_DATA_GRAPH_NONE
        RASQAL_DATA_GRAPH_NAMED
        RASQAL_DATA_GRAPH_BACKGROUND

    ctypedef enum rasqal_op:
        # RASQAL_EXPR_UNKNOWN
        # RASQAL_EXPR_AND
        # RASQAL_EXPR_OR
        # RASQAL_EXPR_EQ
        # RASQAL_EXPR_NEQ
        # RASQAL_EXPR_LT
        # RASQAL_EXPR_GT
        # RASQAL_EXPR_LE
        # RASQAL_EXPR_GE
        # RASQAL_EXPR_UMINUS
        # RASQAL_EXPR_PLUS
        # RASQAL_EXPR_MINUS
        # RASQAL_EXPR_STAR
        # RASQAL_EXPR_SLASH
        # RASQAL_EXPR_REM
        # RASQAL_EXPR_STR_EQ
        # RASQAL_EXPR_STR_NEQ
        # RASQAL_EXPR_STR_MATCH
        # RASQAL_EXPR_STR_NMATCH
        # RASQAL_EXPR_TILDE
        # RASQAL_EXPR_BANG
        # RASQAL_EXPR_LITERAL
        # RASQAL_EXPR_FUNCTION
        # RASQAL_EXPR_BOUND
        # RASQAL_EXPR_STR
        # RASQAL_EXPR_LANG
        # RASQAL_EXPR_DATATYPE
        # RASQAL_EXPR_ISURI
        # RASQAL_EXPR_ISBLANK
        # RASQAL_EXPR_ISLITERAL
        # RASQAL_EXPR_CAST
        # RASQAL_EXPR_ORDER_COND_ASC
        # RASQAL_EXPR_ORDER_COND_DESC
        # RASQAL_EXPR_LANGMATCHES
        # RASQAL_EXPR_REGEX
        # RASQAL_EXPR_GROUP_COND_ASC
        # RASQAL_EXPR_GROUP_COND_DESC
        # RASQAL_EXPR_COUNT
        # RASQAL_EXPR_VARSTAR
        # RASQAL_EXPR_SAMETERM
        # RASQAL_EXPR_SUM
        # RASQAL_EXPR_AVG
        # RASQAL_EXPR_MIN
        # RASQAL_EXPR_MAX
        # RASQAL_EXPR_COALESCE
        # RASQAL_EXPR_IF
        # RASQAL_EXPR_URI
        # RASQAL_EXPR_IRI
        # RASQAL_EXPR_STRLANG
        # RASQAL_EXPR_STRDT
        # RASQAL_EXPR_BNODE
        # RASQAL_EXPR_GROUP_CONCAT
        # RASQAL_EXPR_SAMPLE
        # RASQAL_EXPR_IN
        # RASQAL_EXPR_NOT_IN
        # RASQAL_EXPR_ISNUMERIC
        # RASQAL_EXPR_YEAR
        # RASQAL_EXPR_MONTH
        # RASQAL_EXPR_DAY
        # RASQAL_EXPR_HOURS
        # RASQAL_EXPR_MINUTES
        # RASQAL_EXPR_SECONDS
        # RASQAL_EXPR_TIMEZONE
        # RASQAL_EXPR_CURRENT_DATETIME
        # RASQAL_EXPR_NOW
        # RASQAL_EXPR_FROM_UNIXTIME
        # RASQAL_EXPR_TO_UNIXTIME
        # RASQAL_EXPR_CONCAT
        # RASQAL_EXPR_STRLEN
        # RASQAL_EXPR_SUBSTR
        # RASQAL_EXPR_UCASE
        # RASQAL_EXPR_LCASE
        # RASQAL_EXPR_STRSTARTS
        # RASQAL_EXPR_STRENDS
        # RASQAL_EXPR_CONTAINS
        # RASQAL_EXPR_ENCODE_FOR_URI
        # RASQAL_EXPR_TZ
        # RASQAL_EXPR_RAND
        # RASQAL_EXPR_ABS
        # RASQAL_EXPR_ROUND
        # RASQAL_EXPR_CEIL
        # RASQAL_EXPR_FLOOR
        RASQAL_EXPR_UNKNOWN
        RASQAL_EXPR_AND
        RASQAL_EXPR_OR
        RASQAL_EXPR_EQ
        RASQAL_EXPR_NEQ
        RASQAL_EXPR_LT
        RASQAL_EXPR_GT
        RASQAL_EXPR_LE
        RASQAL_EXPR_GE
        RASQAL_EXPR_UMINUS
        RASQAL_EXPR_PLUS
        RASQAL_EXPR_MINUS
        RASQAL_EXPR_STAR
        RASQAL_EXPR_SLASH
        RASQAL_EXPR_REM
        RASQAL_EXPR_STR_EQ
        RASQAL_EXPR_STR_NEQ
        RASQAL_EXPR_STR_MATCH
        RASQAL_EXPR_STR_NMATCH
        RASQAL_EXPR_TILDE
        RASQAL_EXPR_BANG
        RASQAL_EXPR_LITERAL
        RASQAL_EXPR_FUNCTION
        RASQAL_EXPR_BOUND
        RASQAL_EXPR_STR
        RASQAL_EXPR_LANG
        RASQAL_EXPR_DATATYPE
        RASQAL_EXPR_ISURI
        RASQAL_EXPR_ISBLANK
        RASQAL_EXPR_ISLITERAL
        RASQAL_EXPR_CAST
        RASQAL_EXPR_ORDER_COND_ASC
        RASQAL_EXPR_ORDER_COND_DESC
        RASQAL_EXPR_LANGMATCHES
        RASQAL_EXPR_REGEX
        RASQAL_EXPR_GROUP_COND_ASC
        RASQAL_EXPR_GROUP_COND_DESC
        RASQAL_EXPR_COUNT
        RASQAL_EXPR_VARSTAR
        RASQAL_EXPR_SAMETERM
        RASQAL_EXPR_SUM
        RASQAL_EXPR_AVG
        RASQAL_EXPR_MIN
        RASQAL_EXPR_MAX
        RASQAL_EXPR_COALESCE
        RASQAL_EXPR_IF
        RASQAL_EXPR_URI
        RASQAL_EXPR_IRI
        RASQAL_EXPR_STRLANG
        RASQAL_EXPR_STRDT
        RASQAL_EXPR_BNODE
        RASQAL_EXPR_GROUP_CONCAT
        RASQAL_EXPR_SAMPLE
        RASQAL_EXPR_IN
        RASQAL_EXPR_NOT_IN
        RASQAL_EXPR_ISNUMERIC
        RASQAL_EXPR_YEAR
        RASQAL_EXPR_MONTH
        RASQAL_EXPR_DAY
        RASQAL_EXPR_HOURS
        RASQAL_EXPR_MINUTES
        RASQAL_EXPR_SECONDS
        RASQAL_EXPR_TIMEZONE
        RASQAL_EXPR_CURRENT_DATETIME
        RASQAL_EXPR_NOW
        RASQAL_EXPR_FROM_UNIXTIME
        RASQAL_EXPR_TO_UNIXTIME
        RASQAL_EXPR_CONCAT
        RASQAL_EXPR_STRLEN
        RASQAL_EXPR_SUBSTR
        RASQAL_EXPR_UCASE
        RASQAL_EXPR_LCASE
        RASQAL_EXPR_STRSTARTS
        RASQAL_EXPR_STRENDS
        RASQAL_EXPR_CONTAINS
        RASQAL_EXPR_ENCODE_FOR_URI
        RASQAL_EXPR_TZ
        RASQAL_EXPR_RAND
        RASQAL_EXPR_ABS
        RASQAL_EXPR_ROUND
        RASQAL_EXPR_CEIL
        RASQAL_EXPR_FLOOR
        RASQAL_EXPR_MD5
        RASQAL_EXPR_SHA1
        RASQAL_EXPR_SHA224
        RASQAL_EXPR_SHA256
        RASQAL_EXPR_SHA384
        RASQAL_EXPR_SHA512
        RASQAL_EXPR_STRBEFORE
        RASQAL_EXPR_STRAFTER
        RASQAL_EXPR_REPLACE
        RASQAL_EXPR_UUID
        RASQAL_EXPR_STRUUID
        # internal
        RASQAL_EXPR_LAST = RASQAL_EXPR_STRUUID

    ctypedef enum rasqal_expression_flags:
        RASQAL_EXPR_FLAG_DISTINCT
        RASQAL_EXPR_FLAG_AGGREGATE

    ctypedef enum rasqal_pattern_flags:
        RASQAL_PATTERN_FLAGS_OPTIONAL
        RASQAL_PATTERN_FLAGS_LAST = RASQAL_PATTERN_FLAGS_OPTIONAL

    # structs
    ctypedef struct rasqal_world:
        pass

    ctypedef struct rasqal_query:
        pass

    ctypedef struct rasqal_expression:
        rasqal_world* world
        int usage
        rasqal_op op
        rasqal_expression* arg1
        rasqal_expression* arg2
        rasqal_expression* arg3
        rasqal_literal* literal
        unsigned char *value
        raptor_uri* name
        raptor_sequence* args
        raptor_sequence* params
        unsigned int flags

    ctypedef struct rasqal_graph_pattern:
        pass

    ctypedef struct rasqal_variable:
        rasqal_variables_table* vars_table
        unsigned char *name
        rasqal_literal* value
        int offset
        rasqal_variable_type type
        rasqal_expression* expression
        void *user_data
        int usage

    ctypedef struct rasqal_triple:
        rasqal_literal* subject
        rasqal_literal* predicate
        rasqal_literal* object
        rasqal_literal* origin
        unsigned int flags

    ctypedef struct rasqal_data_graph:
        rasqal_world* world
        raptor_uri* uri
        raptor_uri* name_uri
        int flags
        char* format_type
        char* format_name
        raptor_uri* format_uri
        raptor_iostream* iostr
        raptor_uri* base_uri
        int usage

    ctypedef struct rasqal_prefix:
        rasqal_world* world
        unsigned char *prefix
        raptor_uri* uri
        int declared
        int depth

    ctypedef struct rasqal_update_operation:
        rasqal_update_type type
        raptor_uri* graph_uri
        raptor_uri* document_uri
        raptor_sequence* insert_templates
        raptor_sequence* delete_templates
        rasqal_graph_pattern* where
        int flags
        rasqal_update_graph_applies applies

    ctypedef int (*rasqal_graph_pattern_visit_fn) (rasqal_query *query, rasqal_graph_pattern *gp, void *user_data)

    # prefix
    rasqal_prefix* rasqal_new_prefix(rasqal_world *world, unsigned char *prefix, raptor_uri *uri)
    void rasqal_free_prefix(rasqal_prefix *p)
    int rasqal_prefix_print(rasqal_prefix *p, FILE *fh)

    # data graph
    rasqal_data_graph* rasqal_new_data_graph_from_data_graph(rasqal_data_graph *dg)
    rasqal_data_graph* rasqal_new_data_graph_from_uri(rasqal_world *world, raptor_uri *uri, raptor_uri *name_uri, int flags, char *format_type, char *format_name, raptor_uri *format_uri)
    void rasqal_free_data_graph(rasqal_data_graph *dg)
    int rasqal_data_graph_print(rasqal_data_graph *dg, FILE *fh)
     
    # query
    rasqal_query* rasqal_new_query(rasqal_world *world, char *name, char *uri)
    void rasqal_free_query(rasqal_query *query)
    int rasqal_query_add_data_graph(rasqal_query *query, rasqal_data_graph *data_graph)
    int rasqal_query_add_data_graphs(rasqal_query *query, raptor_sequence *data_graphs)
    int rasqal_query_add_prefix(rasqal_query *query, rasqal_prefix *prefix)
    int rasqal_query_add_variable(rasqal_query *query, rasqal_variable *var)
    int rasqal_query_dataset_contains_named_graph(rasqal_query *query, raptor_uri *graph_uri)
    raptor_sequence* rasqal_query_get_all_variable_sequence(rasqal_query *query)
    raptor_sequence* rasqal_query_get_anonymous_variable_sequence(rasqal_query *query)
    rasqal_variable* rasqal_query_get_bindings_variable(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_bindings_variables_sequence(rasqal_query *query)
    raptor_sequence* rasqal_query_get_bound_variable_sequence(rasqal_query *query)
    rasqal_triple* rasqal_query_get_construct_triple(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_construct_triples_sequence(rasqal_query *query)
    rasqal_data_graph* rasqal_query_get_data_graph(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_data_graph_sequence(rasqal_query *query)
    raptor_sequence* rasqal_query_get_describe_sequence(rasqal_query *query)
    int rasqal_query_get_distinct(rasqal_query *query)
    int rasqal_query_get_explain(rasqal_query *query)
    rasqal_expression* rasqal_query_get_group_condition(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_group_conditions_sequence(rasqal_query *query)
    rasqal_graph_pattern* rasqal_query_get_graph_pattern(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_graph_pattern_sequence(rasqal_query *query)
    rasqal_expression* rasqal_query_get_having_condition(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_having_conditions_sequence(rasqal_query *query)
    char* rasqal_query_get_label(rasqal_query *query)
    int rasqal_query_get_limit(rasqal_query *query)
    char* rasqal_query_get_name(rasqal_query *query)
    int rasqal_query_get_offset(rasqal_query *query)
    rasqal_expression* rasqal_query_get_order_condition(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_order_conditions_sequence(rasqal_query *query)
    rasqal_prefix* rasqal_query_get_prefix(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_prefix_sequence(rasqal_query *query)
    rasqal_graph_pattern* rasqal_query_get_query_graph_pattern(rasqal_query *query)
    rasqal_triple* rasqal_query_get_triple(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_triple_sequence(rasqal_query *query)
    void* rasqal_query_get_user_data(rasqal_query *query)
    rasqal_variable* rasqal_query_get_variable(rasqal_query *query, int idx)
    rasqal_query_verb rasqal_query_get_verb(rasqal_query *query)
    int rasqal_query_get_wildcard(rasqal_query *query)
    void rasqal_query_set_wildcard(rasqal_query *query, int wildcard)
    int rasqal_query_has_variable(rasqal_query *query, unsigned char *name)
    int rasqal_query_has_variable2(rasqal_query* query, rasqal_variable_type type, unsigned char *name)
    int rasqal_query_prepare(rasqal_query *query,unsigned char *query_string, raptor_uri *base_uri)
    int rasqal_query_print(rasqal_query *query, FILE *fh)
    void rasqal_query_graph_pattern_visit(rasqal_query *query, rasqal_graph_pattern_visit_fn visit_fn, void *data)
    void rasqal_query_set_distinct(rasqal_query *query, int distinct_mode)
    void rasqal_query_set_explain(rasqal_query *query, int is_explain)
    void rasqal_query_set_limit(rasqal_query *query, int limit)
    void rasqal_query_set_offset(rasqal_query *query, int offset)
    void rasqal_query_set_user_data(rasqal_query *query, void *user_data)
    int rasqal_query_set_variable(rasqal_query *query, char *name, rasqal_literal *value)
    int rasqal_query_set_variable2(rasqal_query *query, rasqal_variable_type type, const char *name, rasqal_literal *value)
    char* rasqal_query_verb_as_string(rasqal_query_verb verb)
    unsigned char* rasqal_query_escape_counted_string(rasqal_query *query, char *string, size_t len, size_t *output_len_p)
    int rasqal_query_set_feature(rasqal_query *query, rasqal_feature feature, int value)
    int rasqal_query_set_feature_string(rasqal_query *query, rasqal_feature feature, char *value)
    int rasqal_query_get_feature(rasqal_query *query, rasqal_feature feature)
    unsigned char* rasqal_query_get_feature_string(rasqal_query *query, rasqal_feature feature)
    rasqal_update_operation* rasqal_query_get_update_operation(rasqal_query *query, int idx)
    raptor_sequence* rasqal_query_get_update_operations_sequence(rasqal_query *query)
    int rasqal_query_write(raptor_iostream *iostr, rasqal_query *query, raptor_uri *format_uri, raptor_uri *base_uri)

    # XSD api
    rasqal_xsd_datetime* rasqal_new_xsd_datetime(rasqal_world *world, char *datetime_string)
    void rasqal_free_xsd_datetime(rasqal_xsd_datetime *dt)
    int rasqal_xsd_datetime_compare(rasqal_xsd_datetime *dt1, rasqal_xsd_datetime *dt2)
    int rasqal_xsd_datetime_equals(rasqal_xsd_datetime *dt1, rasqal_xsd_datetime *dt2)
    rasqal_xsd_decimal* rasqal_xsd_datetime_get_seconds_as_decimal(rasqal_world *world, rasqal_xsd_datetime *dt)
    char* rasqal_xsd_datetime_get_timezone_as_counted_string(rasqal_xsd_datetime *dt, size_t *len_p)
    char* rasqal_xsd_datetime_to_counted_string(rasqal_xsd_datetime *dt, size_t *len_p)
    char* rasqal_xsd_datetime_to_string(rasqal_xsd_datetime *dt)
    void rasqal_free_xsd_decimal(rasqal_xsd_decimal *dec)
    rasqal_xsd_decimal* rasqal_new_xsd_decimal(rasqal_world *world)
    int rasqal_xsd_decimal_add(rasqal_xsd_decimal *result, rasqal_xsd_decimal *a, rasqal_xsd_decimal *b)
    char* rasqal_xsd_decimal_as_counted_string(rasqal_xsd_decimal *dec, size_t *len_p)
    char* rasqal_xsd_decimal_as_string(rasqal_xsd_decimal *dec)
    int rasqal_xsd_decimal_compare(rasqal_xsd_decimal *a, rasqal_xsd_decimal *b)
    int rasqal_xsd_decimal_divide(rasqal_xsd_decimal *result, rasqal_xsd_decimal *a, rasqal_xsd_decimal *b)
    int rasqal_xsd_decimal_equals(rasqal_xsd_decimal *a, rasqal_xsd_decimal *b)
    double rasqal_xsd_decimal_get_double(rasqal_xsd_decimal *dec)
    int rasqal_xsd_decimal_is_zero(rasqal_xsd_decimal *d)
    int rasqal_xsd_decimal_multiply(rasqal_xsd_decimal *result, rasqal_xsd_decimal *a, rasqal_xsd_decimal *b)
    int rasqal_xsd_decimal_print(rasqal_xsd_decimal *dec, FILE *stream)
    int rasqal_xsd_decimal_set_double(rasqal_xsd_decimal *dec, double d)
    int rasqal_xsd_decimal_set_long(rasqal_xsd_decimal *dec, long Param2)
    int rasqal_xsd_decimal_set_string(rasqal_xsd_decimal *dec, char *string)
    int rasqal_xsd_decimal_subtract(rasqal_xsd_decimal *result, rasqal_xsd_decimal *a, rasqal_xsd_decimal *b)
    int rasqal_xsd_decimal_negate(rasqal_xsd_decimal *result, rasqal_xsd_decimal *a)

    # variable
    rasqal_variable* rasqal_new_variable_from_variable(rasqal_variable *v)
    void rasqal_free_variable(rasqal_variable *v)
    int rasqal_variable_print(rasqal_variable *v, FILE *fh)
    void rasqal_variable_set_value(rasqal_variable *v, rasqal_literal *l)

    # triple
    rasqal_triple* rasqal_new_triple(rasqal_literal *subject, rasqal_literal *predicate, rasqal_literal *object)
    rasqal_triple* rasqal_new_triple_from_triple(rasqal_triple *t)
    void rasqal_free_triple(rasqal_triple *t)
    rasqal_literal* rasqal_triple_get_origin(rasqal_triple *t)
    int rasqal_triple_print(rasqal_triple *t, FILE *fh)
    void rasqal_triple_set_origin(rasqal_triple *t, rasqal_literal *l)

    # literal
    rasqal_literal* rasqal_new_typed_literal(rasqal_world *world, rasqal_literal_type type, char *string)
    rasqal_literal* rasqal_new_boolean_literal(rasqal_world *world, int value)
    rasqal_literal* rasqal_new_datetime_literal_from_datetime(rasqal_world *world, rasqal_xsd_datetime *dt)
    rasqal_literal* rasqal_new_decimal_literal(rasqal_world *world, char *string)
    rasqal_literal* rasqal_new_decimal_literal_from_decimal(rasqal_world *world, char *string, rasqal_xsd_decimal *decimal)
    rasqal_literal* rasqal_new_double_literal(rasqal_world *world, double d)
    rasqal_literal* rasqal_new_float_literal(rasqal_world *world, float f)
    rasqal_literal* rasqal_new_integer_literal(rasqal_world *world, rasqal_literal_type type, int integer)
    rasqal_literal* rasqal_new_numeric_literal_from_long(rasqal_world *world, rasqal_literal_type type, long value)
    rasqal_literal* rasqal_new_pattern_literal(rasqal_world *world, char *pattern, char *flags)
    rasqal_literal* rasqal_new_simple_literal(rasqal_world *world, rasqal_literal_type type, char *string)
    rasqal_literal* rasqal_new_string_literal(rasqal_world *world, char *string, char *language, raptor_uri *datatype, unsigned char *datatype_qname)
    rasqal_literal* rasqal_new_uri_literal(rasqal_world *world, raptor_uri *uri)
    rasqal_literal* rasqal_new_variable_literal(rasqal_world *world, rasqal_variable *variable)
    rasqal_literal* rasqal_new_literal_from_literal(rasqal_literal *l)
    void rasqal_free_literal(rasqal_literal *l)
    rasqal_literal* rasqal_literal_as_node(rasqal_literal *l)
    unsigned char* rasqal_literal_as_counted_string(rasqal_literal *l, size_t *len_p, int flags, int *error)
    unsigned char* rasqal_literal_as_string(rasqal_literal *l)
    unsigned char* rasqal_literal_as_string_flags(rasqal_literal *l, int flags, int *error)
    rasqal_variable* rasqal_literal_as_variable(rasqal_literal *l)
    int rasqal_literal_compare(rasqal_literal *l1, rasqal_literal *l2, int flags, int *error)
    raptor_uri* rasqal_literal_datatype(rasqal_literal *l)
    int rasqal_literal_equals(rasqal_literal *l1, rasqal_literal *l2)
    rasqal_literal_type rasqal_literal_get_rdf_term_type(rasqal_literal *l)
    rasqal_literal_type rasqal_literal_get_type(rasqal_literal* l)
    char* rasqal_literal_get_language(rasqal_literal* l)
    int rasqal_literal_is_rdf_literal(rasqal_literal *l)
    int rasqal_literal_print(rasqal_literal *l, FILE *fh)
    void rasqal_literal_print_type(rasqal_literal *l, FILE *fh)
    char* rasqal_literal_type_label(rasqal_literal_type type)
    int rasqal_literal_same_term(rasqal_literal *l1, rasqal_literal *l2)
    rasqal_literal* rasqal_literal_value(rasqal_literal *l)

    # graph pattern
    int rasqal_graph_pattern_add_sub_graph_pattern(rasqal_graph_pattern *graph_pattern, rasqal_graph_pattern *sub_graph_pattern)
    rasqal_expression* rasqal_graph_pattern_get_filter_expression(rasqal_graph_pattern *gp)
    int rasqal_graph_pattern_set_filter_expression(rasqal_graph_pattern *gp, rasqal_expression *expr)
    raptor_sequence* rasqal_graph_pattern_get_flattened_triples(rasqal_query *query, rasqal_graph_pattern *graph_pattern)
    raptor_sequence* rasqal_graph_pattern_get_triples(rasqal_query* query, rasqal_graph_pattern* graph_pattern)
    int rasqal_graph_pattern_get_index (rasqal_graph_pattern *gp)
    rasqal_graph_pattern_operator rasqal_graph_pattern_get_operator(rasqal_graph_pattern *graph_pattern)
    rasqal_literal* rasqal_graph_pattern_get_origin(rasqal_graph_pattern *graph_pattern)
    rasqal_graph_pattern* rasqal_graph_pattern_get_sub_graph_pattern(rasqal_graph_pattern *graph_pattern, int idx)
    raptor_sequence* rasqal_graph_pattern_get_sub_graph_pattern_sequence(rasqal_graph_pattern *graph_pattern)
    rasqal_triple* rasqal_graph_pattern_get_triple(rasqal_graph_pattern *graph_pattern, int idx)
    rasqal_literal* rasqal_graph_pattern_get_service(rasqal_graph_pattern *graph_pattern)
    rasqal_variable* rasqal_graph_pattern_get_variable(rasqal_graph_pattern *graph_pattern)
    char* rasqal_graph_pattern_operator_as_string(rasqal_graph_pattern_operator op)
    int rasqal_graph_pattern_print(rasqal_graph_pattern *gp, FILE *fh)
    int rasqal_graph_pattern_variable_bound_in(rasqal_graph_pattern *gp, rasqal_variable *v)
    int rasqal_graph_pattern_visit(rasqal_query *query, rasqal_graph_pattern *gp, rasqal_graph_pattern_visit_fn fn, void *user_data)

    # expressions
    int rasqal_expression_print(rasqal_expression *e,  FILE *fh)
    rasqal_literal *  rasqal_expression_evaluate(rasqal_world *world, raptor_locator *locator, rasqal_expression *e, int flags)
    char * rasqal_expression_op_label(rasqal_op op)

    # library
    rasqal_world* rasqal_new_world()
    int rasqal_world_open(rasqal_world *world)
    void rasqal_free_world(rasqal_world *world)
    raptor_world* rasqal_world_get_raptor(rasqal_world *world)
    void rasqal_world_set_raptor(rasqal_world *world, raptor_world *raptor_world_ptr)
    int rasqal_world_set_warning_level(rasqal_world *world, unsigned int warning_level)
    int rasqal_language_name_check(rasqal_world *world, char *name)

    # memory
    void* rasqal_alloc_memory(size_t size)
    void* rasqal_calloc_memory(size_t nmemb, size_t size)
    void rasqal_free_memory(void *ptr)

    # variables table
    rasqal_variables_table* rasqal_new_variables_table(rasqal_world* world)
    void rasqal_free_variables_table(rasqal_variables_table* vt)
    rasqal_variable*  rasqal_variables_table_add(rasqal_variables_table* vt, rasqal_variable_type tp, const char *name, rasqal_literal *value)
    int rasqal_variables_table_add_variable(rasqal_variables_table *vt, rasqal_variable *variable)
    rasqal_variable*  rasqal_variables_table_get_by_name(rasqal_variables_table *vt, rasqal_variable_type tp, const char *name)
    int rasqal_variables_table_contains(rasqal_variables_table *vt, rasqal_variable_type tp, const char *name)
