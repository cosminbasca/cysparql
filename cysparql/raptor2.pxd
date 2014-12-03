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


__author__ = 'basca'

# ----------------------------------------------------------------------------------------------------------------------
#
# the rdf raptor parser ----> must be 2.X
#
# ----------------------------------------------------------------------------------------------------------------------
cdef extern from "raptor2/raptor2.h" nogil:
    ctypedef struct raptor_world:
        pass

    ctypedef struct raptor_parser:
        pass

    ctypedef struct raptor_serializer:
        pass

    ctypedef struct raptor_locator:
        pass

    ctypedef struct raptor_uri:
        pass
    
    ctypedef struct raptor_sequence:
        pass

    ctypedef enum raptor_term_type:
        RAPTOR_TERM_TYPE_UNKNOWN
        RAPTOR_TERM_TYPE_URI
        RAPTOR_TERM_TYPE_LITERAL
        RAPTOR_TERM_TYPE_BLANK

    ctypedef struct raptor_term_literal_value:
        unsigned char *string
        unsigned int string_len
        raptor_uri *datatype
        unsigned char *language
        unsigned char language_len

    ctypedef struct raptor_term_blank_value:
        unsigned char *string
        unsigned int string_len

    ctypedef union raptor_term_value:
        raptor_uri *uri
        raptor_term_literal_value literal
        raptor_term_blank_value blank

    ctypedef struct raptor_term:
        raptor_world* world
        int usage
        raptor_term_type type
        raptor_term_value value

    ctypedef struct raptor_statement:
        raptor_world* world
        int usage
        raptor_term* subject
        raptor_term* predicate
        raptor_term* object
        raptor_term* graph

    ctypedef struct raptor_iostream:
        pass

    ctypedef struct raptor_stringbuffer:
        pass

    ctypedef int (*raptor_iostream_init_func) (void *context)
    ctypedef void (*raptor_iostream_finish_func) (void *context)
    ctypedef int (*raptor_iostream_write_byte_func) (void *context, int byte)
    ctypedef int (*raptor_iostream_write_bytes_func) (void *context, void *ptr, size_t size, size_t nmemb)
    ctypedef int (*raptor_iostream_write_end_func) (void *context)
    ctypedef int (*raptor_iostream_read_bytes_func) (void *context, void *ptr, size_t size, size_t nmemb)
    ctypedef int (*raptor_iostream_read_eof_func) (void *context)

    ctypedef void* (*raptor_data_malloc_handler)(size_t size)

    ctypedef struct raptor_iostream_handler:
        int version
        # V1 functions
        raptor_iostream_init_func         init
        raptor_iostream_finish_func       finish
        raptor_iostream_write_byte_func   write_byte
        raptor_iostream_write_bytes_func  write_bytes
        raptor_iostream_write_end_func    write_end
        #  V2 functions
        raptor_iostream_read_bytes_func   read_bytes
        raptor_iostream_read_eof_func     read_eof

    ctypedef int (*raptor_data_compare_handler)(void *data1, void *data2)
    ctypedef void (*raptor_statement_handler)(void *user_data, raptor_statement *statement)

    # library
    raptor_world* raptor_new_world()
    int raptor_world_open(raptor_world *world)
    void raptor_free_world(raptor_world *world)

    # parser
    raptor_parser* raptor_new_parser(raptor_world *world, char *name)
    raptor_parser* raptor_new_parser_for_content(raptor_world *world, raptor_uri *uri, char *mime_type, unsigned char *buffer, size_t len, unsigned char *identifier)
    void raptor_free_parser(raptor_parser *parser)
    void raptor_parser_set_statement_handler(raptor_parser *parser, void *user_data, raptor_statement_handler handler)
    int raptor_parser_parse_chunk(raptor_parser *rdf_parser, unsigned char *buffer, size_t len, int is_end)
    int raptor_parser_parse_file(raptor_parser *rdf_parser, raptor_uri *uri, raptor_uri *base_uri)
    int raptor_parser_parse_start(raptor_parser *rdf_parser, raptor_uri *uri)

    # serializer
    raptor_serializer* raptor_new_serializer(raptor_world *world, char *name)
    void raptor_free_serializer(raptor_serializer *rdf_serializer)
    int raptor_serializer_start_to_filename(raptor_serializer *rdf_serializer, char *filename)
    int raptor_serializer_start_to_string(raptor_serializer *rdf_serializer, raptor_uri *uri, void **string_p, size_t *length_p)
    int raptor_serializer_start_to_file_handle(raptor_serializer *rdf_serializer, raptor_uri *uri, FILE *fh)
    int raptor_serializer_serialize_statement(raptor_serializer *rdf_serializer, raptor_statement *statement)
    int raptor_serializer_serialize_end(raptor_serializer *rdf_serializer)

    # uri
    raptor_uri* raptor_new_uri(raptor_world *world, unsigned char *uri_string)
    raptor_uri* raptor_new_uri_from_counted_string(raptor_world *world, unsigned char *uri_string, size_t length)
    void raptor_free_uri(raptor_uri *uri)
    raptor_uri* raptor_uri_copy(raptor_uri *uri)
    unsigned char* raptor_uri_filename_to_uri_string(char *filename)
    unsigned char* raptor_uri_as_string(raptor_uri *uri)
    unsigned char* raptor_uri_to_string(raptor_uri *uri)
    unsigned char* raptor_uri_as_counted_string(raptor_uri *uri, size_t *len_p)

    # memory
    void raptor_free_memory(void *ptr)

    # sequence
    void raptor_free_sequence(raptor_sequence *seq)
    void* raptor_sequence_delete_at(raptor_sequence *seq, int idx)
    int raptor_sequence_size(raptor_sequence *seq)
    int raptor_sequence_set_at(raptor_sequence *seq, int idx, void *data)
    int raptor_sequence_push(raptor_sequence *seq, void *data)
    int raptor_sequence_shift(raptor_sequence *seq, void *data)
    void* raptor_sequence_get_at(raptor_sequence *seq, int idx)
    void* raptor_sequence_pop(raptor_sequence *seq)
    void* raptor_sequence_unshift(raptor_sequence *seq)
    void  raptor_sequence_sort(raptor_sequence *seq, raptor_data_compare_handler compare)
    int raptor_sequence_print(raptor_sequence *seq, FILE *fh)
    int raptor_sequence_join(raptor_sequence *dest, raptor_sequence *src)

    # iostream
    raptor_iostream* raptor_new_iostream_from_handler(raptor_world* world, void *user_data, const raptor_iostream_handler* handler)
    raptor_iostream* raptor_new_iostream_to_sink(raptor_world* world)
    raptor_iostream* raptor_new_iostream_to_filename(raptor_world* world, char *filename)
    raptor_iostream* raptor_new_iostream_to_file_handle(raptor_world* world, FILE *handle)
    raptor_iostream* raptor_new_iostream_to_string(raptor_world* world, void **string_p, size_t *length_p, raptor_data_malloc_handler malloc_handler)
    raptor_iostream* raptor_new_iostream_from_sink(raptor_world* world)
    raptor_iostream* raptor_new_iostream_from_filename(raptor_world* world, char *filename)
    raptor_iostream* raptor_new_iostream_from_file_handle(raptor_world* world, FILE *handle)
    raptor_iostream* raptor_new_iostream_from_string(raptor_world* world, void *string, size_t length)
    void raptor_free_iostream(raptor_iostream *iostr)
    int raptor_iostream_write_bytes(void *ptr, size_t size, size_t nmemb, raptor_iostream *iostr)
    int raptor_iostream_write_byte(int byte, raptor_iostream *iostr)
    int raptor_iostream_write_end(raptor_iostream *iostr)
    int raptor_iostream_string_write(void *string, raptor_iostream *iostr)
    int raptor_iostream_counted_string_write(void *string, size_t len, raptor_iostream *iostr)
    unsigned long raptor_iostream_tell(raptor_iostream *iostr)
    int raptor_iostream_decimal_write(int integer, raptor_iostream* iostr)
    int raptor_iostream_hexadecimal_write(unsigned int integer, int width, raptor_iostream* iostr)
    int raptor_stringbuffer_write(raptor_stringbuffer *sb, raptor_iostream* iostr)
    int raptor_uri_write(raptor_uri *uri, raptor_iostream *iostr)
    int raptor_iostream_read_bytes(void *ptr, size_t size, size_t nmemb, raptor_iostream* iostr)
    int raptor_iostream_read_eof(raptor_iostream *iostr)
    int raptor_string_ntriples_write(unsigned char *string, size_t len, const char delim, raptor_iostream *iostr)
    int raptor_bnodeid_ntriples_write(unsigned char *bnodeid, size_t len, raptor_iostream *iostr)
    int raptor_string_python_write(unsigned char *string, size_t len, const char delim, int flags, raptor_iostream *iostr)
    int raptor_statement_ntriples_write(raptor_statement *statement, raptor_iostream* iostr, int write_graph_term)


