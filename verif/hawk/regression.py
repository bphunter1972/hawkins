#!/usr/bin/env python2.7

"A very rudimentary regression program"

from __future__ import print_function
import subprocess
import os

########################################################################################
def get_tests():
    tests = os.listdir('tests')
    tests = [os.path.basename(it) for it in tests]
    tests = [os.path.splitext(it)[0] for it in tests]
    tests = [it for it in tests if it != 'base_test']
    return tests

########################################################################################
def check(test_name):
    filename = os.path.join('sim', test_name, 'logfile')
    with open(filename) as logfile:
        num_issues = 0
        start_looking = False
        for line in logfile:
            if not start_looking and line.strip() == '--- UVM Report Summary ---':
                start_looking = True
            if not start_looking:
                continue
            if line.startswith('UVM_WARNING') or line.startswith('UVM_ERROR') or line.startswith('UVM_FATAL'):
                num_issues += int(line.split()[2])
        if num_issues:
            print("FAILED with {} issues.".format(num_issues))
        else:
            print("PASSED")

########################################################################################
if __name__ == '__main__':
    tests = get_tests()

    for idx, test in enumerate(tests):
        cmd = 'runme.py TEST={}'.format(test)
        if idx:
            cmd += ' COMPILE=0'
        print("Running: {}".format(cmd), end='...')
        p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
        stdout, stderr = p.communicate()
        check(test)
