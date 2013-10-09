import networkx as nx
from collections import namedtuple

__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# tango colors
#
#-----------------------------------------------------------------------------------------------------------------------
TangoColor = namedtuple('TangoColor', ['light', 'normal', 'dark'])

Butter      = TangoColor(light='#fce94f', normal='#edd400', dark='#c4a000')
Orange      = TangoColor(light='#fcaf3e', normal='#f57900', dark='#ce5c00')
Chocolate   = TangoColor(light='#e9b96e', normal='#c17d11', dark='#8f5902')
Chameleon   = TangoColor(light='#8ae234', normal='#73d216', dark='#4e9a06')
SkyBlue     = TangoColor(light='#729fcf', normal='#3465a4', dark='#204a87')
Plum        = TangoColor(light='#ad7fa8', normal='#75507b', dark='#5c3566')
ScarletRed  = TangoColor(light='#ef2929', normal='#cc0000', dark='#a40000')
Aluminium1  = TangoColor(light='#eeeeec', normal='#d3d7cf', dark='#babdb6')
Aluminium2  = TangoColor(light='#888a85', normal='#555753', dark='#2e3436')

#-----------------------------------------------------------------------------------------------------------------------
#
# draw primitives
#
#-----------------------------------------------------------------------------------------------------------------------
