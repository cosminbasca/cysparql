from collections import namedtuple
from util import all_terms, is_valid_url
from term import QueryVar
from copy import copy
import networkx as nx
from rdflib.term import URIRef, Literal, BNode
import os

__author__ = 'basca'

#-----------------------------------------------------------------------------------------------------------------------
#
# tango colors
#
#-----------------------------------------------------------------------------------------------------------------------
TangoColor = namedtuple('TangoColor', ['light', 'normal', 'dark'])

Butter = TangoColor(light='#fce94f', normal='#edd400', dark='#c4a000')
Orange = TangoColor(light='#fcaf3e', normal='#f57900', dark='#ce5c00')
Chocolate = TangoColor(light='#e9b96e', normal='#c17d11', dark='#8f5902')
Chameleon = TangoColor(light='#8ae234', normal='#73d216', dark='#4e9a06')
SkyBlue = TangoColor(light='#729fcf', normal='#3465a4', dark='#204a87')
Plum = TangoColor(light='#ad7fa8', normal='#75507b', dark='#5c3566')
ScarletRed = TangoColor(light='#ef2929', normal='#cc0000', dark='#a40000')
Aluminium1 = TangoColor(light='#eeeeec', normal='#d3d7cf', dark='#babdb6')
Aluminium2 = TangoColor(light='#888a85', normal='#555753', dark='#2e3436')

#-----------------------------------------------------------------------------------------------------------------------
#
# pretty printing draw primitives
#
#-----------------------------------------------------------------------------------------------------------------------
def word_wrap(line, sep=':', length=20):
    words = line.split(sep)
    current = words[0]
    lines = []
    for w in words[1:]:
        if len(current) + len(w) + 1 > length:
            lines.append(current)
            current = w
        else:
            current += ':%s' % w
    return '\n'.join(lines)


def pretty_uri_n3(value, simplistic=False):
    if simplistic:
        return None, ':'.join(all_terms(value.label))
    else:
        return '<%s>' % value if isinstance(value, basestring) else value.n3()


def pretty_n3(value, prefixes=None, simplistic=False, prefixed_as_tuple=False):
    if isinstance(value, QueryVar):
        return value.n3()
    elif isinstance(value, URIRef):
        if prefixes:
            _prefixes = []
            for pkey, prefix in prefixes.items():
                if prefix in value:
                    _prefixes.append((len(prefix), pkey, prefix))
            if _prefixes:
                _prefixes.sort(key=lambda item: item[0], reverse=True)
                l,pkey,prefix = _prefixes[0]
                if prefixed_as_tuple:
                    return value, value.replace(prefix, '%s:'%pkey)
                return value.replace(prefix, '' if simplistic else '%s:'%pkey)
            return pretty_uri_n3(value, simplistic=simplistic)
        else:
            return value.n3()
    elif isinstance(value, (BNode, Literal)):
        return value.n3()
    elif isinstance(value, basestring):
        if is_valid_url(value):
            return pretty_uri_n3(value, simplistic=simplistic)
        return '"%s"'%value


# noinspection PyCallingNonCallable,PyBroadException
def plot_query(query, qname, location=None, highlight=None, highlight_color=ScarletRed.light,
               highlight_alpha=0.7, alpha=0.7, suffix=None, show=False, ext='pdf', prefixes=None,
               aspect_ratio=(2.7 / 4.0), scale=1.9, show_predicates=False):
    if highlight is None:
        highlight = []
    elif isinstance(highlight, tuple):
        highlight = [highlight]

    try:
        from matplotlib import use; use('TkAgg')
        from matplotlib import pyplot as plt
        from matplotlib.path import Path
        from matplotlib import patches as mpatches
        from matplotlib import text

        w, h = plt.figaspect(aspect_ratio)
        figure = plt.figure(figsize=(scale * w, scale * h), dpi=200)
        ax = figure.add_subplot(111, aspect='auto')

        Rbox = mpatches.BoxStyle.Round(pad=0.3)
        RboxPath = Rbox(-1.5, -0.2, 3.0, 0.4, 1.0)

        # nodes - VARS
        hl_variables = set([s for s, o in highlight if isinstance(s, QueryVar)] +
                           [o for s, o in highlight if isinstance(o, QueryVar)])
        variables = set([s for s, p, o, c in query.triple_patterns if isinstance(s, QueryVar)] +
                        [o for s, p, o, c in query.triple_patterns if isinstance(o, QueryVar)]) - hl_variables
        # nodes - LITERALS
        hl_literals = set([s for s, o in highlight if not isinstance(s, QueryVar)] +
                          [o for s, o in highlight if not isinstance(o, QueryVar)])
        literals = set([s for s, p, o, c in query.triple_patterns if not isinstance(s, QueryVar)] +
                       [o for s, p, o, c in query.triple_patterns if not isinstance(o, QueryVar)]) - hl_literals
        # edges - BOUND
        hl_ebound = set([(s, o) for s, p, o, c in query.triple_patterns if
                         not isinstance(p, QueryVar) and ((s, o) in highlight or (o, s) in highlight)])
        ebound = set([(s, o) for s, p, o, c in query.triple_patterns if not isinstance(p, QueryVar)]) - hl_ebound
        # edges - UNBOUND
        hl_eunbound = set([(s, o) for s, p, o, c in query.triple_patterns if
                           isinstance(p, QueryVar) and ((s, o) in highlight or (o, s) in highlight)])
        eunbound = set([(s, o) for s, p, o, c in query.triple_patterns if isinstance(p, QueryVar)]) - hl_eunbound

        _variables_cfg = dict(node_size=5000, node_color=Aluminium1.light, node_shape='o', alpha=alpha)
        _hl_variables_cfg = copy(_variables_cfg)
        _hl_variables_cfg['node_color'] = highlight_color
        _hl_variables_cfg['alpha'] = highlight_alpha
        _literals_cfg = dict(node_size=5000, node_color=Aluminium1.light, node_shape=RboxPath, alpha=alpha)
        _hl_literals_cfg = copy(_literals_cfg)
        _hl_literals_cfg['node_color'] = highlight_color
        _hl_literals_cfg['alpha'] = highlight_alpha
        _ebound_cfg = dict(width=2, edge_color=Aluminium2.normal, style='solid', alpha=alpha)
        _hl_ebound_cfg = copy(_ebound_cfg)
        _hl_ebound_cfg['edge_color'] = highlight_color
        _hl_ebound_cfg['alpha'] = highlight_alpha
        _eunbound_cfg = dict(width=2, edge_color=Aluminium2.normal, style='dashed', alpha=alpha)
        _hl_eunbound_cfg = copy(_eunbound_cfg)
        _hl_eunbound_cfg['edge_color'] = highlight_color
        _hl_eunbound_cfg['alpha'] = highlight_alpha

        _variables_font_cfg = dict(font_size=14, font_color=Aluminium2.dark, font_family='sans-serif',
                                   font_weight='bold', alpha=1.0)
        _literals_font_cfg = dict(font_size=14, font_color=Aluminium2.dark, font_family='sans-serif',
                                  font_weight='bold', alpha=1.0)
        _predicates_font_cfg = dict(font_size=14, font_color=Aluminium2.dark, font_family='sans-serif',
                                    font_weight='bold', alpha=1.0)

        G = query.graph
        pos = nx.spring_layout(G, iterations=200)

        current_label = 1
        legend_labels = {}
        literal_labels = {}
        for n in literals | hl_literals:
            label = pretty_n3(n, prefixes=prefixes, simplistic=True, prefixed_as_tuple=True)
            if isinstance(label, tuple):
                _n, _l = label
                if _n:
                    label = _l
                    legend_labels[label] = _n
                else:
                    label = 'LABEL_%s' % current_label
                    current_label += 1
                    legend_labels[label] = _l
            literal_labels[n] = label

        nx.draw_networkx_edges(G, pos, edgelist=ebound, ax=ax, **_ebound_cfg)
        nx.draw_networkx_edges(G, pos, edgelist=hl_ebound, ax=ax, **_hl_ebound_cfg)
        nx.draw_networkx_edges(G, pos, edgelist=eunbound, ax=ax, **_eunbound_cfg)
        nx.draw_networkx_edges(G, pos, edgelist=hl_eunbound, ax=ax, **_hl_eunbound_cfg)

        nx.draw_networkx_nodes(G, pos, nodelist=list(variables), ax=ax, **_variables_cfg)
        nx.draw_networkx_nodes(G, pos, nodelist=list(hl_variables), ax=ax, **_hl_variables_cfg)
        nx.draw_networkx_nodes(G, pos, nodelist=list(literals), ax=ax, **_literals_cfg)
        nx.draw_networkx_nodes(G, pos, nodelist=list(hl_literals), ax=ax, **_hl_literals_cfg)

        nx.draw_networkx_labels(G, pos, labels=dict(
            [(n, pretty_n3(n, prefixes=prefixes, simplistic=True)) for n in variables | hl_variables]),
                                ax=ax, **_variables_font_cfg)
        # nx.draw_networkx_labels(G, pos, labels=dict([ (n, n3(n, prefixes=prefixes, simplistic=True)) for n in literals | hl_literals]),
        #                         ax=ax, **_literals_font_cfg)
        nx.draw_networkx_labels(G, pos, labels=literal_labels,
                                ax=ax, **_literals_font_cfg)
        if show_predicates:
            nx.draw_networkx_edge_labels(G, pos, edge_labels=dict(
                [((s, o), pretty_n3(p, prefixes=prefixes, simplistic=True)) for s, p, o, c in query.triple_patterns]),
                                         ax=ax, label_pos=0.5, **_predicates_font_cfg)

        ax.axis('off')
        if legend_labels:
            proxy = mpatches.Rectangle((0, 0), 1, 1, fc="w", alpha=0.0)
            ax.legend(
                [proxy for k, v in legend_labels.items()],
                ['%s :   %s' % (k, v) for k, v in legend_labels.items()],
                prop=dict(
                    family=_literals_font_cfg['font_family'],
                    weight=_literals_font_cfg['font_weight'],
                    size=_literals_font_cfg['font_size'],
                ),
                frameon=False,
            )

        figname = "query_%s%s.%s" % (qname, '_%s' % suffix if suffix else '', ext)
        figpath = os.path.join(location, figname) if location and os.path.isdir(location) else figname
        if not show:
            plt.savefig(figpath,
                        transparent=False,
                        bbox_inches='tight',
                        pad_inches=.01)
        else:
            plt.show()
    except Exception:
        # import traceback
        # print traceback.format_exc()
        return False