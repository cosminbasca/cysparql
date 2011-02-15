__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from libutil import get_include_dir, get_lib_dir

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
                   Extension('cysparql.crasqal',['cysparql/crasqal.pyx',
                                                 'cysparql/crasqal.pxd',
                                                ],
                             libraries 		    = ['raptor', 'rasqal'],
                             library_dirs 	    = get_lib_dir(),
                             include_dirs       = get_include_dir(),
                             extra_compile_args = ['-fPIC']),
                   ],
)