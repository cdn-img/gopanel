#! /usr/bin/python
"""Run to test the system python"""
import doctest
import pytz
import pytz.tzinfo
import sys

errors = 0
tests = 0
for mod in [pytz, pytz.tzinfo]: 
    mod_errors, mod_tests = doctest.testmod(mod)
    errors += mod_errors
    tests += mod_tests

if not errors:
    print("Ran %s tests successfully." % tests)
sys.exit(errors)
