#!/usr/bin/env python

import subprocess
import sys

if __name__ == '__main__':

    cmd = 'qrsh -q verilog -l lic_cmp_vcs=1 "runmod -m synopsys-vcs_mx/J-2014.12-SP2 vcs -full64 -o simv -f vcs.flist"'
    p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=subprocess.STDOUT, shell=True)
    stdout, stderr = p.communicate()

    cmd = 'qrsh -q verilog -l lic_sim_vcs=1 simv +UVM_TESTNAME=basic_test_c +UVM_NO_RELNOTES'
    p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=subprocess.STDOUT, shell=True)
    stdout, stderr = p.communicate()
    print("Done!")
