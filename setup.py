#!/usr/bin/env python

try:
    from setuptools import setup
except ImportError:
    from ez_setup import use_setuptools

    use_setuptools()
    from setuptools import setup

from setuptools.extension import Extension
from Cython.Distutils import build_ext
import os


def get_lib_dir(default='/usr/lib:/usr/local/lib'):
    libpath = os.environ.get('DYLD_LIBRARY_PATH', None)
    libpath = libpath if libpath else os.environ.get('LD_LIBRARY_PATH', None)
    libpath = libpath if libpath else default
    return [p for p in libpath.split(':') if p]


def get_include_dir(default='/usr/local/include:/usr/include'):
    incpath = os.environ.get('C_INCLUDE_PATH', None)
    incpath = incpath if incpath else default
    return [p for p in incpath.split(':') if p]


NAME = 'cysparql'


def extension(name, libs, language='c', options=None, c_sources=None):
    if not c_sources: c_sources = []
    if not options: options = []
    extension_name = '{0}.{1}'.format(NAME, name)
    extension_path = '{0}/{1}.pyx'.format(NAME, '/'.join(name.split('.')))
    return Extension(extension_name, [extension_path, ] + c_sources, language=language, libraries=list(libs),
                     library_dirs=get_lib_dir(), include_dirs=get_include_dir(), extra_compile_args=['-fPIC'] + options)


str_version = None
execfile('{0}/__version__.py'.format(NAME))

# Load up the description from README
with open('README') as f:
    DESCRIPTION = f.read()

pip_deps = [
    'cython>=0.20.2',
    'rdflib>=4.1.2',
    'numpy>=1.8.1',
    'networkx>=1.9',
]

manual_deps = []

setup(
    name=NAME,
    version=str_version,
    author='Cosmin Basca',
    author_email='cosmin.basca@gmail.com; basca@ifi.uzh.ch',
    # url=None,
    description='A Cython wrapper of rasqal - an efficient and fast native C SPARQL parser',
    long_description=DESCRIPTION,
    cmdclass={'build_ext': build_ext},
    ext_modules=[
        extension('world', ['raptor2', 'rasqal'], options=['-w']),
        extension('sequence', ['raptor2', 'rasqal'], options=['-w']),
        extension('term', ['raptor2', 'rasqal'], options=['-w']),
        extension('filter', ['raptor2', 'rasqal'], options=['-w']),
        extension('pattern', ['raptor2', 'rasqal'], options=['-w']),
        extension('varstable', ['raptor2', 'rasqal'], options=['-w']),
        extension('graph', ['raptor2', 'rasqal'], options=['-w']),
        extension('query', ['raptor2', 'rasqal'], options=['-w']),
    ],
    classifiers=[
        'Intended Audience :: Developers',
        # 'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Cython',
        'Programming Language :: C',
        'Topic :: Software Development'
    ],
    packages=[NAME,
              '{0}/test'.format(NAME),
    ],
    package_data={
        NAME: ['*.json'],
    },
    install_requires=manual_deps + pip_deps,
    entry_points={
        'console_scripts': ['sparql_info = {0}.cli:sparql_info'.format(NAME)]
    }
)
