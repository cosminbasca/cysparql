from pprint import pformat
from hashlib import sha1
from cysparql.pattern import TriplePatternSequence
from cysparql.query import Query
from cysparql.term import QueryVar

__author__ = 'basca'


class EncodedQuery(object):
    def __init__(self, query, pretty=False, variables_only=False):
        if isinstance(query, basestring):
            query = Query(query, pretty=pretty)
        if not isinstance(query, Query):
            raise ValueError('query must be an instance of cysparql.Query!')
        self._variables_only = variables_only
        self._query = query
        self._variables = self._query.variables
        self._triple_patterns = self._query.triple_patterns
        self._terms = {}
        self._limit = query.limit

        self._encoded_variables = {var: (-1 * (i + 1)) for i, (name, var) in enumerate(self._variables.iteritems())}
        self._projections = [var for var in self._query.projections]
        self._encoded_projections = [self._encoded_variables[var] for var in self._projections]
        self._inv_encoded_variables = {v: k for k, v in self._encoded_variables.items()}
        self._encoded_triple_patterns = self.encode(self._triple_patterns)

    @property
    def unique_id(self):
        return self._query.unique_id

    def encode_string(self, str_obj):
        enc_str = str(str_obj) if self._variables_only else sha1(str_obj).hexdigest()
        self._terms[enc_str] = str_obj
        return enc_str

    def encode(self, obj):
        encoded_obj = None
        if isinstance(obj, (list, tuple, TriplePatternSequence)):
            encoded_obj = tuple(
                [(self._encoded_variables.get(s, str(s) if isinstance(s, QueryVar) else self.encode_string(s)),
                  self._encoded_variables.get(p, str(p) if isinstance(p, QueryVar) else self.encode_string(p)),
                  self._encoded_variables.get(o, str(o) if isinstance(o, QueryVar) else self.encode_string(o)), )
                 for s, p, o, c in obj])
        elif isinstance(obj, QueryVar):
            encoded_obj = self._encoded_variables.get(obj, None)
        elif isinstance(obj, basestring):
            # assume it's the name of a variable
            for name, variable in self._variables:
                if name == obj:
                    encoded_obj = variable
                    break

        if not encoded_obj:
            raise ValueError("{0} could not be encoded".format(obj))
        return encoded_obj

    def decode_variables(self, *enc_vars):
        return [self.decode(enc_var) for enc_var in enc_vars]

    def encode_variables(self, *variables):
        def encode_var(evar):
            if isinstance(evar, QueryVar):
                return self.encoded_variables[evar]
            elif isinstance(evar, basestring):
                return self.encoded_variables[self.query.variables[evar]]

        return [encode_var(var) for var in variables]

    def decode(self, obj):
        decoded_obj = None
        if isinstance(obj, (int, long)):
            decoded_obj = self._inv_encoded_variables[obj]
        elif isinstance(obj, (list, tuple)):
            def decode_term(term):
                dec_term = self._inv_encoded_variables.get(term, None)
                if not dec_term:
                    return self._terms[term]
                return dec_term

            decoded_obj = tuple([(decode_term(s), decode_term(p), decode_term(o),) for s, p, o in obj])
        elif isinstance(obj, basestring):
            return self._terms[obj]

        if not decoded_obj:
            raise ValueError("{0} could not be decoded".format(obj))
        return decoded_obj

    @property
    def variables(self):
        return self._variables

    @property
    def triple_patterns(self):
        return self._triple_patterns

    @property
    def encoded_variables(self):
        return self._encoded_variables

    @property
    def encoded_triple_patterns(self):
        return self._encoded_triple_patterns

    @property
    def query(self):
        return self._query

    @property
    def projections(self):
        return self._projections

    @property
    def encoded_projections(self):
        return self._encoded_projections

    @property
    def limit(self):
        return self._limit

    @limit.setter
    def limit(self, value):
        self._limit = value

    def __str__(self):
        return """
----------------------------------------------------------------------------------------------------------------
 ENCODED QUERY
 encoded variables: \n\t{0}\n
 encoded bgp: \n\t{1}\n
 sparql: \n{2}
----------------------------------------------------------------------------------------------------------------
        """.strip().format('\n\t'.join([
            '{0} : {1}'.format(var, var_id)
            for var, var_id in self._encoded_variables.iteritems()]),
                           '\n\t'.join([
                               'pattern {0}: {1}'.format(i, tp)
                               for i, tp in enumerate(self.encoded_triple_patterns)]),
                           str(self._query))

    def sparql(self):
        return str(self._query)


    @staticmethod
    def extract_variables(bgp):
        return list({term for tp in bgp for term in tp if isinstance(term, (QueryVar, int, long, float))})

    def convert_to_sparql(self, bgp):
        decoded_triple_patterns = self.decode(bgp)

        def as_bgp(triple_patterns):
            return ['%s %s %s' % (tp[0].n3(), tp[1].n3(), tp[2].n3()) for tp in triple_patterns]

        return 'SELECT {0} \nWHERE {{ \n{1} \n}}'.format(
            ' '.join([var.n3() for var in self.extract_variables(decoded_triple_patterns)]),
            ' .\n'.join(as_bgp(decoded_triple_patterns)))

    def __getstate__(self):
        return self.sparql()

    def __setstate__(self, state):
        self.__init__(state)
