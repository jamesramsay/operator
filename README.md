# Operator

> Analyze your Intercom data using SQL

[![Launch CloudFormation
Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=operator&templateURL=https://operator-stack.s3.amazonaws.com/templates/operator.template)

---

Analyze Intercom data over time using SQL with:

- time series data about segment and tag membership
- query using SQL
- no maintenance of webservers or databases
- all data stored as [`ndjson` (newline delimited json)](http://ndjson.org) in S3

---

## What is Operator?

Operator is a package you can upload to [AWS Lambda](https://aws.amazon.com/lambda/) that is triggered on a schedule to collect segment and tag information about users and companies from [Intercom](https://intercom.com), allowing you to analyse usage in new ways.

## Prerequisites

- Intercom [Access Token](https://developers.intercom.com/reference#personal-access-tokens-1)
- [Amazon AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)

## Installation

Todo


