#!/bin/bash

sed -i "" 's/10.10.10.9/10.10.11.9/' config/local-server.yaml
sed -i "" 's/domain: foo.bar.com/gateway: 10.10.10.8/' local/sites/test-site/env.yml
sed -i "" 's/10.10.10.9/10.10.11.9/' local/sites/test-site/env.yml
