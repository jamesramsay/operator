#!/bin/bash -ex

# TODO: add ap-southeast-2
REGIONS="\
  ap-northeast-1 \
  ap-northeast-2 \
  ap-south-1 \
  ap-southeast-1 \
  ca-central-1 \
  eu-central-1 \
  eu-west-1 \
  eu-west-2 \
  sa-east-1 \
  us-east-2 \
  us-west-1 \
  us-west-2 \
"
VERSION=$(npm run -s v)

echo $VERSION > /tmp/operator.txt

aws s3api put-object --bucket intercom-operator --key fn/operator-build-${VERSION}.zip --body lambda.zip --acl public-read

aws s3api copy-object --copy-source intercom-operator/fn/operator-build-${VERSION}.zip --bucket intercom-operator --key fn/operator-build-latest.zip --acl public-read &

aws s3api put-object --bucket intercom-operator --key fn/latest.txt --body /tmp/operator.txt --acl public-read &

for region in $REGIONS; do
  aws s3api copy-object --region $region --copy-source intercom-operator/fn/operator-build-${VERSION}.zip --bucket operator-${region} --key fn/operator-build-${VERSION}.zip --acl public-read && \
  aws s3api copy-object --region $region --copy-source operator-${region}/fn/operator-build-${VERSION}.zip --bucket operator-${region} --key fn/operator-build-latest.zip --acl public-read &
done

for job in $(jobs -p); do
  wait $job
done

rm /tmp/operator.txt
