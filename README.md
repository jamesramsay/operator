<img align="right" src="http://l.jwr.vc/d3rQ+" width="220px" height="283px" />

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

The fastest way to install Operator is to [spin up a CloudFormation
stack](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=operator&templateURL=https://operator-stack.s3.amazonaws.com/templates/operator.template).

As part of the setup you can supply your Intercom access token.

### 1. Create Intercom access token

You can create a token using the Intercom Developer Hub following these
[instructions](https://developers.intercom.com/docs/personal-access-tokens).

Operator only needs read access to your data, but unfortunately Intercom doesn't permit specifying read-only permissions
for access tokens. Furthermore, to list users and companies **Extended Scope** is required.

### 2. Launch the Operator CloudFormation stack

You can either [use the direct
link](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=operator&templateURL=https://operator-stack.s3.amazonaws.com/templates/operator.template)
or navigate in your AWS Console to `Services > CloudFormation`, choose 'Create Stack' and upload `operator.template`
from the root of this repository, or use the [S3 Link](https://operator-stack.s3.amazonaws.com/templates/operator.template).

Then click 'Next' where you can enter a stack name (`operator` is a good default), API token, and a name for the S3 bucket
where your Intercom data will be stored (`intercom-APPID` where `APPID` is substituted with the unique id for your
Intercom account).

Click 'Next', and then 'Next' again on the Options step (leaving the default options selected), to get to the final Review
step.

Check the acknowledgment checkbox and click 'Create' to start the resource creation process.

Once your stack is created, you are ready to start analyzing your Intercom data!

Initially no data will have been collected yet. It will happen automatically once per day. If you want to start
exploring immediately you can trigger the Lambda function by navigating in you AWS Console to `Services > Lambda`,
choose the Operator function and click 'Test'.

### 3. Create an Athena database and tables

Coming soon.

## Analysis recipes

Coming soon.
