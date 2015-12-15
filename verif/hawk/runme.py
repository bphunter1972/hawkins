#!/usr/bin/env python

from __future__ import print_function
import subprocess
import sys
import os

DEFAULTS = {
    'TEST' : 'basic',
    'FSDB' : '0',
    'COMPILE' : True,
    'SIMARGS' : '+UVM_NO_RELNOTES',
    'DBG'  : 0,
    'CLEAN': False,
}

########################################################################################
def parse_args():
    cmd_args = DEFAULTS

    for arg in sys.argv:
        try:
            var, val = arg.split('=')
        except ValueError:
            continue
        else:
            if var in cmd_args:
                cmd_args[var] = val
    return cmd_args

########################################################################################
def clean():
    import shutil

    dirs = ['csrc', 'simv.daidir', 'sim']
    files = ['novas_dump.log', 'simv', 'tr_db.log', 'ucli.key', 'vc_hdrs.h']

    for d in dirs:
        try:
            shutil.rmtree(d)
        except OSError:
            pass
        else:
            print("Removed {}".format(d))

    for f in files:
        try:
            os.remove(f)
        except OSError:
            pass
        else:
            print("Removed {}".format(f))
            
########################################################################################
if __name__ == '__main__':
    cmd_args = parse_args()

    if cmd_args['CLEAN']:
        clean()

    # make sim dir
    sim_dir = 'sim/{TEST}'.format(**cmd_args)
    if not os.path.exists(sim_dir):
        os.makedirs(sim_dir)

    if cmd_args['COMPILE']:
        cmd = 'qrsh -q verilog -l lic_cmp_vcs=1 "runmod -m synopsys-vcs_mx/J-2014.12-SP2 vcs -CFLAGS \'-DVCS\' -full64 -o simv -f vcs.flist"'
        p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=subprocess.STDOUT, shell=True)
        stdout, stderr = p.communicate()

    cmd = 'qrsh -q verilog -l lic_sim_vcs=1 simv -l sim/{TEST}/logfile +UVM_TESTNAME={TEST}_test_c {SIMARGS}'.format(**cmd_args)
    if cmd_args['FSDB']:
        cmd += ' +fsdb_trace=1 +fsdb_outfile=sim/{TEST}/waves.fsdb'.format(**cmd_args)
    if cmd_args['DBG']:
        cmd += ' +UVM_VERBOSITY={DBG}'.format(**cmd_args)
    p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=subprocess.STDOUT, shell=True)
    stdout, stderr = p.communicate()
