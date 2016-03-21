#!/usr/bin/env python2.7

"A very rudimentary program to launch compiles and simulations"

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
    'GUI'  : False,
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
    if cmd_args['COMPILE'] in ('0', 'False'):
        cmd_args['COMPILE'] = False

    return cmd_args

########################################################################################
def clean():
    import shutil

    dirs = ['csrc', 'simv.daidir', 'sim']
    files = ['novas_dump.log', 'simv', 'tr_db.log', 'ucli.key', 'vc_hdrs.h']

    for dirname in dirs:
        try:
            shutil.rmtree(dirname)
        except OSError:
            pass
        else:
            print("Removed {}".format(dirname))

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

    load_modules = ['synopsys-vcs_mx/K-2015.09-SP1', 'synopsys-verdi/K-2015.09-SP1']
    mod_load = '; '.join(['module load {}'.format(it) for it in load_modules])

    if cmd_args['COMPILE']:
        cmd = 'qrsh -q verilog -l lic_cmp_vcs=1 "{}; vcs -CFLAGS \'-DVCS\' -full64 -o simv -kdb -lca -debug_all -f vcs.flist"'.format(mod_load)
        p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=subprocess.STDOUT, shell=True)
        stdout, stderr = p.communicate()

    cmd = 'qrsh -q verilog -l lic_sim_vcs=1 "{}; simv -l sim/{TEST}/logfile +UVM_TESTNAME={TEST}_test_c {SIMARGS}"'.format(mod_load, **cmd_args)
    if cmd_args['FSDB']:
        cmd += ' +fsdb_trace=1 +fsdb_outfile=sim/{TEST}/waves.fsdb'.format(**cmd_args)
    if cmd_args['DBG']:
        cmd += ' +UVM_VERBOSITY={DBG}'.format(**cmd_args)
    if cmd_args['GUI']:
        cmd += ' -verdi'
    p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=subprocess.STDOUT, shell=True)
    stdout, stderr = p.communicate()
