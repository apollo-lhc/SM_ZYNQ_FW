#!/bin/env python

import yaml

import requests #interact with github.com
import json # parse github return

def GetReleaseFiles(host, project,repo, release):
  GIT_API_URL="https://api."+host+"/repos/"+project+"/"+repo+"/releases"
  response=requests.get(GIT_API_URL)
  ReleaseJSON=json.loads(response.text)
  for remoteRelease in ReleaseJSON:
    if remoteRelease["name"] == release:
      for asset in remoteRelease["assets"]:
        if asset["name"].find("dtsi") != -1:
          assetData = requests.get(asset["url"],headers = {"Accept": "application/octet-stream"})
          filename="hw_remote/"+asset["name"].replace("dtsi.","")
          open(filename,'wb').write(assetData.content)
        



CMFile=open("CM.yaml")

remotes=yaml.load(CMFile)

for remote in remotes:
  print remote
  GetReleaseFiles(remotes[remote]['host'],
                  remotes[remote]['project'],
                  remotes[remote]['repo'],
                  remotes[remote]['release'])

 
