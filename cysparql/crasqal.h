#ifndef __PYX_HAVE__cysparql__crasqal
#define __PYX_HAVE__cysparql__crasqal
#ifdef __cplusplus
#define __PYX_EXTERN_C extern "C"
#else
#define __PYX_EXTERN_C extern
#endif

/* "cysparql/crasqal.pyx":53
 * # Enums - CONSTANTS
 * #-----------------------------------------------------------------------------------------------------------------------
 * ctypedef public enum Selectivity:             # <<<<<<<<<<<<<<
 *     SELECTIVITY_UNDEFINED = -2
 *     SELECTIVITY_ALL_TRIPLES = -1
 */

typedef enum {
  SELECTIVITY_UNDEFINED = -2,
  SELECTIVITY_ALL_TRIPLES = -1,
  SELECTIVITY_NO_TRIPLES = 0
} Selectivity;

/* "cysparql/crasqal.pyx":58
 *     SELECTIVITY_NO_TRIPLES = 0
 * 
 * ctypedef public enum GraphPatternOperator:             # <<<<<<<<<<<<<<
 *     OPERATOR_UNKNOWN = RASQAL_GRAPH_PATTERN_OPERATOR_UNKNOWN
 *     OPERATOR_BASIC = RASQAL_GRAPH_PATTERN_OPERATOR_BASIC
 */

typedef enum {

  /* "cysparql/crasqal.pyx":70
 *     OPERATOR_SERVICE = RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE
 *     OPERATOR_MINUS = RASQAL_GRAPH_PATTERN_OPERATOR_MINUS
 *     OPERATOR_LAST = RASQAL_GRAPH_PATTERN_OPERATOR_LAST             # <<<<<<<<<<<<<<
 * 
 * #-----------------------------------------------------------------------------------------------------------------------
 */
  OPERATOR_UNKNOWN = RASQAL_GRAPH_PATTERN_OPERATOR_UNKNOWN,
  OPERATOR_BASIC = RASQAL_GRAPH_PATTERN_OPERATOR_BASIC,
  OPERATOR_OPTIONAL = RASQAL_GRAPH_PATTERN_OPERATOR_OPTIONAL,
  OPERATOR_UNION = RASQAL_GRAPH_PATTERN_OPERATOR_UNION,
  OPERATOR_GROUP = RASQAL_GRAPH_PATTERN_OPERATOR_GROUP,
  OPERATOR_GRAPH = RASQAL_GRAPH_PATTERN_OPERATOR_GRAPH,
  OPERATOR_FILTER = RASQAL_GRAPH_PATTERN_OPERATOR_FILTER,
  OPERATOR_LET = RASQAL_GRAPH_PATTERN_OPERATOR_LET,
  OPERATOR_SELECT = RASQAL_GRAPH_PATTERN_OPERATOR_SELECT,
  OPERATOR_SERVICE = RASQAL_GRAPH_PATTERN_OPERATOR_SERVICE,
  OPERATOR_MINUS = RASQAL_GRAPH_PATTERN_OPERATOR_MINUS,
  OPERATOR_LAST = RASQAL_GRAPH_PATTERN_OPERATOR_LAST
} GraphPatternOperator;

#ifndef __PYX_HAVE_API__cysparql__crasqal

#endif

PyMODINIT_FUNC initcrasqal(void);

#endif
