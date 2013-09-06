__author__ = 'Cosmin Basca'
__email__ = 'basca@ifi.uzh.ch; cosmin.basca@gmail.com'

import os
from setuptools import setup
from setuptools.extension import Extension
from Cython.Distutils import build_ext
from setup_util import get_lib_dir, get_include_dir

str_version = None
execfile('cysparql/__version__.py')

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
private_deps = []

pip_deps = [
    'cython>=0.19.1',
    'rdflib>=3.2.1',
    'pytools>=2013.5.6',
    'pandas>=0.12.0'
]

manual_deps = []

setup(
    name ='cysparql',
    version = str_version,
    description = 'cython wrapper of rasqal - an efficient and fast native C SPARQL parser',
    author = 'Cosmin Basca',
    author_email = 'basca@ifi.uzh.ch',
    cmdclass = {'build_ext': build_ext},
    packages = ["cysparql"],
    package_dir = {"cysparql":"cysparql"},
    ext_modules = [
            extension('sequence',   ['raptor2', 'rasqal'], options=['-w']),
            extension('term',       ['raptor2', 'rasqal'], options=['-w']),
            extension('filter',     ['raptor2', 'rasqal'], options=['-w']),
            extension('pattern',    ['raptor2', 'rasqal'], options=['-w']),
            extension('query',      ['raptor2', 'rasqal'], options=['-w']),
    ],
    install_requires = manual_deps + pip_deps + private_deps,
    include_package_data = True,
    zip_safe = False,
    # scripts = [
    #     # 'scripts/cytt_importer.py',
    # ],
)