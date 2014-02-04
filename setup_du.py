__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

import os
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from setup_util import get_include_dir, get_lib_dir

def extension(name, libs, language='c', options=[], c_sources=[]):
    extension_name = 'cysparql.%s'%name
    extension_path = 'cysparql/%s.pyx'%('/'.join(name.split('.')))
    return Extension(extension_name,
                     [extension_path,] + c_sources,
                     language           = language,
                     libraries          = list(libs),
                     library_dirs 	    = get_lib_dir(),
                     include_dirs       = get_include_dir(),
                     extra_compile_args = ['-fPIC']+options)
setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        extension('world',      ['raptor2', 'rasqal'], options=['-w']),
        extension('sequence',   ['raptor2', 'rasqal'], options=['-w']),
        extension('term',       ['raptor2', 'rasqal'], options=['-w']),
        extension('filter',     ['raptor2', 'rasqal'], options=['-w']),
        extension('pattern',    ['raptor2', 'rasqal'], options=['-w']),
        extension('varstable',  ['raptor2', 'rasqal'], options=['-w']),
        extension('graph',      ['raptor2', 'rasqal'], options=['-w']),
        extension('query',      ['raptor2', 'rasqal'], options=['-w']),
    ],
)
