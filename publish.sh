#!/bin/bash -ex

# Dependencies: awscli

VERSION=$(npm run -s v)

echo $VERSION > /tmp/lambci.txt

aws s3api put-object --bucket intercom-operator --key fn/operator-build-${VERSION}.zip --body lambda.zip --acl public-read
