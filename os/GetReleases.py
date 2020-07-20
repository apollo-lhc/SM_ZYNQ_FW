#!/bin/env python

import yaml

import requests #interact with github.com
import json # parse github return

CMFile=open("CM.yaml")

remotes=yaml.load(CMFile)
print remotes
for remote in remotes:
  print remote["repo"]

 
