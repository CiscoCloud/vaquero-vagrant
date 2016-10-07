#!/bin/bash
TOKEN=$1
grep -rl '<GIT_TOKEN>' config | xargs sed -i '' "s/<GIT_TOKEN>/$TOKEN/g"
