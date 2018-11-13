#!/usr/local/bin/perl
#

#use strict;
use Inline::Python;

# Inline::Python::py_eval('import sys');
# Inline::Python::py_eval('print (sys.version)');

use Inline Python => <<'END';

def doSomething(a):
    dog=str(a, "utf-8")

#    print (dog)

    return dog + "else"

END

print doSomething("something") . "\n";


