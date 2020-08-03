#!/bin/env python

import yaml

import requests #interact with github.com
import json # parse github return

def GetReleaseFiles(name,host, project,repo, release):
  GIT_API_URL="https://api."+host+"/repos/"+project+"/"+repo+"/releases"
  response=requests.get(GIT_API_URL)
  ReleaseJSON=json.loads(response.text)
  foundDTISSlaveFile = False
  foundTableSlaveFile = False
  #download the dtsi related files
  for remoteRelease in ReleaseJSON:
    if remoteRelease["name"] == release:
      for asset in remoteRelease["assets"]:


        #========================================================================
        # kernel path (dtsi related files)
        #========================================================================
        if asset["name"].find("dtsi") != -1:
          assetData = requests.get(asset["url"],headers = {"Accept": "application/octet-stream"})
          #check which kind of file this is and rename it
          if asset["name"].find("slaves.yaml"):
            #yaml file, rename file in loca path
            foundDTSISlaveFile=True
            filename="kernel/"+name+"_slaves.yaml"
          else:
            #dtsi file, rename path to kernel/hw_NAME/*
            filename="kernel/hw_"+name+"/"+asset["name"].replace("dtsi.","")
          file = open(filename,'wb').write(assetData.content)
          close(file)

        #========================================================================
        # os path (address table related files)
        #========================================================================
        if asset["name"].find("address_table") != -1:
          assetData = requests.get(asset["url"],headers = {"Accept": "application/octet-stream"})
          if asset["name"].find("slaves.yaml"):
            #yaml file, rename file in loca path
            foundTableSlaveFile=True
            filename="os/"+name+"_slaves.yaml"
          else:
            #dtsi file, rename path to kernel/hw_NAME/*
            filename="os/address_table/"+name+"_modules/"+asset["name"].replace("address_table.modules","")
          file = open(filename,'wb').write(assetData.content)
          close(file)



def main(CMFilename):

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
  parser.add_argument("--CM",      ,help="YAML file storing the remote slaves",default=CM.yaml)
  args = parser.parse_args()
  main(args.CM)

