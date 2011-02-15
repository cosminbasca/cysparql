__author__ = 'basca'

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
  