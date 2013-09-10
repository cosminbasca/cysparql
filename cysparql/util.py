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


def enum(*sequential, **named):
    """taken from: http://stackoverflow.com/questions/36932/how-can-i-represent-an-enum-in-python"""
    enums = dict(zip(sequential, range(len(sequential))), **named)
    reverse = dict((value, key) for key, value in enums.iteritems())
    enums['reverse_mapping'] = reverse
    return type('Enum', (), enums)