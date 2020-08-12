#!/bin/env python
import argparse

from git import Repo #interact with local git repo
import re #decode local repo
import requests #interact with github.com
import json # parse github return
import os
import yaml

#find files
from os import listdir
from os.path import isfile, join

token=""

def GetFilesToSend(path,match):
    files=dict()
    for f in listdir(path):
        if isfile(join(path,f)):
            if f.find(match) >= 0:
                if f.find("~") == -1:
                    files[f]=join(path,f)
    return files


def releaseFile(releaseJSON,localFile,uploadFile):
    global token
    url=releaseJSON["upload_url"].replace("{?name,label}","?name="+uploadFile)
    uploadFile=open(localFile)
    response=requests.post(url,data=uploadFile,headers = {"Authorization": "token "+token,"Content-Type": "application/octet-stream"})    
    uploadFile.close()
    if response.status_code != 201:
        raise Exception('Error ({0}:{1}) while uploading {2}\n{3}'.format(response.status_code,response.reason,localFile,response.text))


def main(kernel_path,image_path):

    
    #get the token for remote write access to the repo
    global token
    token=os.getenv("GH_TOKEN")
    if token == None:
        print "Missing github oath token"
        quit()
      
    
    #############################################################################
    # Load local repo and 
    #############################################################################

    #open current path as repo
    localRepo = Repo("./")
    localRepoRemote=localRepo.remotes.origin.url
    #get remote info
    host=   re.search('(\@|https:\/\/)(.*):',localRepoRemote).group(2)           #match git@HOST:XXXXX or https://HOST:XXXX
    project=re.search('(\@|https:\/\/).*:(.*)\/',localRepoRemote).group(2)       #match XXXXhost:PROJECT/XXXXX
    repo=   re.search('(\@|https:\/\/).*:.*\/(.*).git',localRepoRemote).group(2) #match XXXXhost:project/REPO.git
    
    print "Repo is "+host+"/"+project+"/"+repo
    
    #get branch and check that it is a release branch
    branch=localRepo.active_branch.name
    #check if this is named release
    if branch.find("release-v") >= 0:
        releaseVersion=branch[branch.find("release-v") + len("release-v"):]
    elif branch.find("hotfix-v") >= 0 :
        releaseVersion=branch[branch.find("hotfix-v") + len("hotfix-v"):]
    else:
        print "Not on a release or hotfix branch!"
        quit()
    print "Release:"+ releaseVersion
    
    
    #############################################################################
    # Create a new release remotely
    #############################################################################
    
    #Create the new release
    GIT_API_URL="https://api."+host+"/repos/"+project+"/"+repo+"/releases"
    
    createReleaseData='\
        {\
    	"tag_name": "v'+releaseVersion+'",\
    	"target_commitish": "'+branch+'",\
    	"name": "v'+releaseVersion+'",\
    	"body": "v '+releaseVersion+' release of '+repo+'",\
    	"draft": false,\
    	"prerelease": false\
    	}'
    
    response=requests.post(GIT_API_URL,data=createReleaseData,headers = {"Authorization": "token "+token})
    if response.status_code != 201:
        print "Error: Creation failed with {0}".format(response.status_code)
        quit()
    else:
        print "Created draft release v{0}".format(releaseVersion)
    ReleaseJSON=json.loads(response.text)


    #############################################################################
    # Upload files to the release
    #############################################################################
    
    ##Upload files and finalize the release
    try:
        #########################################################################
        # BOOT.BIN image.ub
        #########################################################################
        print "========================================"
        print "Processing boot and kernel files"
        print "========================================"
        filePath=kernel_path+"/zynq_os/images/linux/"

        uploadFile="BOOT.BIN"
        print "  Uploading: " + filePath+uploadFile + " to  "+uploadFile+"\n" 
        releaseFile(ReleaseJSON,filePath+uploadFile,uploadFile)

        uploadFile="image.ub"
        print "  Uploading: " + filePath+uploadFile + " to  "+uploadFile+"\n" 
        releaseFile(ReleaseJSON,filePath+uploadFile,uploadFile)
        

        #########################################################################
        # os image
        #########################################################################
        print ""
        print "========================================"
        print "Processing os image"
        print "========================================"

        filePath=image_path

        uploadFile="SD_p2.tar.gz"
        print "  Uploading: " + filePath+uploadFile + " to  "+uploadFile+"\n" 
        releaseFile(ReleaseJSON,filePath+uploadFile,uploadFile)


        #########################################################################
        # FW files
        #########################################################################                
        print
        print "========================================"
        print "Processing bit files"
        print "========================================"
        bitFiles=GetFilesToSend('bit/','top')
        printPadding=0
        for file in bitFiles:
            if(len(bitFiles[file])>printPadding):
                printPadding=len(bitFiles[file])+1
        for file in bitFiles:
            print "  Uploading: " + (bitFiles[file]).ljust(printPadding) + " to  "+file
            releaseFile(ReleaseJSON,bitFiles[file],file)
            
                        

    
    except Exception as e:
        requests.delete(ReleaseJSON["url"],headers={"Authorization": "token "+token})
        requests.delete("https://api."+host+"/repos/"+project+"/"+repo+"/git/refs/tags/"+ReleaseJSON["tag_name"],headers={"Authorization": "token "+token})
        print "Error! Deleting partial release"
        print e


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build address table.")
    parser.add_argument("--kernel_path","-k"      ,help="path for BOOT.BIN and image.ub (kernel, fsbl, fw)")
    parser.add_argument("--image_path","-i"      ,help="path for OS image")
    args=parser.parse_args()
    main(args.kernel_path,args.image_path)
