__rasqal_warning_level__ = 50

def disable_rasqal_warnings():
    global __rasqal_warning_level__
    __rasqal_warning_level__ = 0

def set_rasqal_warning_level(wlevel):
    global __rasqal_warning_level__
    __rasqal_warning_level__ = wlevel

def get_rasqal_warning_level():
    global __rasqal_warning_level__
    return __rasqal_warning_level__