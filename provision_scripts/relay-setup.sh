#!/bin/bash

sed -i "" 's/10.10.10.5/10.10.11.5/' config/dir-sot.yaml
sed -i "" 's/10.10.10.5/10.10.11.5/' config/git-sot.yaml
sed -i "" 's/10.10.10.5/10.10.11.5/' local/sites/test-site/env.yml
