__author__ = 'basca'

from cysparql import *

w = RasqalWorld()
tlit = QueryLiteral.new_typed_literal(w, LiteralType.BOOLEAN, "1")
print tlit
tlit.debug()
print LiteralType.BOOLEAN
print tlit.literal_type_label
print LiteralType.reverse_mapping[tlit.literal_type]
