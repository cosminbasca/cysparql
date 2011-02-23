__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

from setuptools import setup
from setuptools.extension import Extension
from Cython.Distutils import build_ext
from libutil import get_lib_dir, get_include_dir

__version__ = (0,1,4)
str_ver = lambda : '%d.%d.%d'%(__version__[0],__version__[1],__version__[2])

setup(
    name ='cysparql',
    version = str_ver(),
    description = 'rasqal cython wrapper',
    author = 'Cosmin Basca',
    author_email = 'basca@ifi.uzh.ch',
    cmdclass = {'build_ext': build_ext},
    packages = ["cysparql"],
    ext_modules = [
                   Extension('cysparql.crasqal',['cysparql/crasqal.pyx',
                                                 'cysparql/crasqal.pxd',
                                                ],
                             libraries 		    = ['raptor', 'rasqal'],
                             library_dirs 	    = get_lib_dir(),
                             include_dirs       = get_include_dir(),
                             extra_compile_args = ['-fPIC']),
                   ],
    install_requires = ['cython>=0.14'],
    #scripts = [], # no scripts
)