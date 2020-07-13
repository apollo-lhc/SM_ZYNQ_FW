#################################################################
## Script based on original script written by Matthias Wittgen ##
#################################################################

import os
import sys
import subprocess
import logging
import shutil
import argparse
import crypt
import augeas

dirname, filename = os.path.split(os.path.abspath(__file__))

dnf_conf=dirname+'/dnf.conf'
print(dnf_conf)
qemu_bins=dirname
etc=dirname

def run_dnf(rootfs,inst,what):
    cmd=[ "dnf", "-y", "--skip-broken" ,"--nodocs", "-c",dnf_conf, "--releasever=7", "--forcearch="+arch, "--repo=centos-base,centos-updates,centos-extras,"+epel,"--verbose", "--installroot="+rootfs, inst ] + what
    print(cmd)
    try:
        process=subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=False)
        while process.poll() is None:
            output = process.stdout.readline()
            if output:
                print(output.strip().decode('utf-8'))
    except:
        return



parser = argparse.ArgumentParser(description='Tool to cross-install a root filesystem for Centos Linux ARM')

FORMAT = '%(levelname)s : %(message)s'
 
parser.add_argument('-v','--verbose',action='store_true',
                    help='verbose output')
parser.add_argument('-r','--root',nargs=1,
                    help='directory of new rootfs')
parser.add_argument('-a','--arch',nargs=1,
                    help='architecture of target')
parser.add_argument('-e','--extra',nargs=1,
                    help='file with a list of extra packages to be installed')
args = vars(parser.parse_args())
if args['verbose']:
    logging.basicConfig(format=FORMAT,stream=sys.stdout, level=logging.DEBUG)

if args['root'] is not None:
    rootdir=args['root'][0]
    print (rootdir)
else:
    print("Use --root=<dir> to set new rootfs directory")
    exit(-1)
if args['arch'] is not None:
    arch=args['arch'][0]
    print("Building for ",arch)
else:
    print("Use --arch=<arch> to specify build architecture")
    exit(-1)
if arch not in ["armv7hl","aarch64"]:
   print("Invalid CPU architecture")
   exit(-1)
if args['extra'] is not None:
	text_file = open(args['extra'][0],"r")
	lines=[]
	for x in text_file:
		x=x.replace("\n", "")
		lines.append(x)
	
	text_file.close()	
if(os.getuid()!=0):
    print ("Program must to run as superuser")
    print ("Relaunching as: sudo "," ".join(sys.argv))
    os.execvp("sudo",[
    "sudo",
    "PATH="+os.getenv("PATH"),
    "LD_LIBRARY_PATH="+os.getenv("LD_LIBRARY_PATH"),
    "PYTHONPATH="+os.getenv("PYTHONPATH"),	
    ]+sys.argv)
    exit(0)

if arch == "armv7hl":
	print ("Using qemu-arm-static")
	#shutil.copy(qemu_bins+"/qemu-arm-static",rootdir+"/usr/local/bin/qemu-arm-static")
elif arch == "aarch64":
	print ("Using qemu-aarch64-static")
	#shutil.copy(qemu_bins+"/qemu-aarch64-static",rootdir+"/usr/local/bin/qemu-aarch64-static")

if arch == "aarch64":
	epel="arm64-epel"
elif arch == "armv7hl":
	epel="arm-epel"

run_dnf(rootdir,"clean",["all"])
run_dnf(rootdir,"update",[" "])
print ("Running dnf: group install")
run_dnf(rootdir,"groupinstall",['Minimal Install'])
if args['extra'] is not None:
	print("Installing user defined packages...")
	run_dnf(rootdir,"install",lines)
print ("Running dnf: remove")
run_dnf(rootdir,"remove",["NetworkManager","firewalld","iptables","iw*firmware*","alsa*","linux-firmware","--setopt=tsflags=noscripts","--enable centos-sclo-rh-testing"])
#I guess network manager also removes this? 
run_dnf(rootdir,"install",["dhclient","emacs"])
			    
rootpwd=crypt.crypt("centos", crypt.mksalt(crypt.METHOD_SHA512))
aug=augeas.Augeas(root=rootdir)
aug.set("/files/etc/shadow/root/password",rootpwd)
aug.set("/files/etc/sysconfig/selinux/SELINUX","disabled")
aug.save()
aug.close()
#os.makedirs(rootdir+"/etc/sysconfig/network-scripts/ifcfg-eth0")
#shutil.copy(etc+"/ifcfg-eth0",rootdir+"/etc/sysconfig/network-scripts/ifcfg-eth0")
shutil.copy(etc+"/ifcfg-eth0",rootdir+"/etc/sysconfig/network-scripts/")
if arch=="armv7hl":
    os.remove(rootdir+"/etc/yum.repos.d/CentOS-armhfp-kernel.repo")

