#!/bin/env python

import argparse
import yaml

import requests #interact with github.com
import json # parse github return

import os #for mkdir
import shutil

token=""


def RecreateDir(dir):
  try:
    os.mkdir(dir)
  except OSError:
    #remote files in this folder
    for filename in os.listdir(dir):
      file_path = os.path.join(dir, filename)
      try:
        if os.path.isfile(file_path) or os.path.islink(file_path):
          os.unlink(file_path)
        elif os.path.isdir(file_path):
          shutil.rmtree(file_path)
      except Exception as e:
        print('Failed to delete %s. Reason: %s' % (file_path, e))

def GetReleaseFiles(name,host, project,repo, release):
  global token
  GIT_API_URL="https://api."+host+"/repos/"+project+"/"+repo+"/releases"
  response=requests.get(GIT_API_URL,headers = {"Authorization": "token "+token})
  ReleaseJSON=json.loads(response.text)
  foundDTISSlaveFile = False
  foundTableSlaveFile = False

  #clear/create new folders
  addressTableDir="os/address_table/"+name+"_modules/"
  dtsiDir="kernel/hw_"+name+"/"
  RecreateDir(addressTableDir)
  RecreateDir(dtsiDir)
  

  #download the dtsi related files
  for remoteRelease in ReleaseJSON:
    if remoteRelease["name"] == release:
      for asset in remoteRelease["assets"]:

        #========================================================================
        # kernel path (dtsi related files)
        #========================================================================
        if asset["name"].find("dtsi") != -1:
          assetData = requests.get(asset["url"],headers = {"Authorization": "token "+token,"Accept": "application/octet-stream"})
          #check which kind of file this is and rename it
          if asset["name"].find("slaves.yaml") != -1:
            #yaml file, rename file in loca path
            foundDTSISlaveFile=True
            filename="kernel/"+name+"_slaves.yaml"
          else:
            #dtsi file, rename path to kernel/hw_NAME/*
            filename=dtsiDir+asset["name"].replace("dtsi.","")
          print "Downloading",asset["name"],"to",filename
          outFile = open(filename,'wb')
          outFile.write(assetData.content)
          outFile.close()

        #========================================================================
        # os path (address table related files)
        #========================================================================
        if asset["name"].find("address_table") != -1:
          assetData = requests.get(asset["url"],headers = {"Authorization": "token "+token,"Accept": "application/octet-stream"})
          if asset["name"].find("slaves.yaml") != -1:
            #yaml file, rename file in loca path
            foundTableSlaveFile=True
            filename="os/"+name+"_slaves.yaml"
          else:
            filename=addressTableDir+asset["name"].replace("address_table.modules.","")
          print "Downloading",asset["name"],"to",filename
          outFile = open(filename,'wb')
          outFile.write(assetData.content)
          outFile.close()

        #========================================================================
        # svf files
        #========================================================================
        if asset["name"].find("svf") != -1:
          assetData = requests.get(asset["url"],headers = {"Authorization": "token "+token,"Accept": "application/octet-stream"})                    
          filename="bit/top_"+name+".svf"
          print "Downloading",asset["name"],"to",filename
          outFile = open(filename,'wb')
          outFile.write(assetData.content)
          outFile.close()



def main(CMFilename):

  #get the token for remote write access to the repo
  global token
  token=os.getenv("GH_TOKEN")
  if token == None:
      print "Missing github oath token"
      quit()


  #load the remote slaves list yaml
  CMFile=open(args.CM)
  remotes=yaml.load(CMFile)
  for remote in remotes:
    print "Processing",remote
    GetReleaseFiles(remote,
                    remotes[remote]['host'],
                    remotes[remote]['project'],
                    remotes[remote]['repo'],
                    remotes[remote]['release'])


if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Pull all remote files for final build.")
  parser.add_argument("--CM",help="YAML file storing the remote slaves",default="CM.yaml")
  args = parser.parse_args()
  main(args.CM)

