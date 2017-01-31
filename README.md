# Operator

> Analyze and backup your Intercom data

Analyze Intercom data over time using SQL. Operator helps you capture regular (daily, weekly etc) snapshots of your Intercom data which can then be queried.

## Todo

- implement lambda function to dump the data
- cloudformation to deploy the lambda function
- cloudformation to create S3 bucket
- handle failures (retry/email?)

## AWS

Resources required:

- AWS bucket for each intercom instance (e.g. `operator-INTERCOM_APPID`)
- Lambda function

Example IAM Policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::operator-XXXXXXXX",
                "arn:aws:s3:::operator-XXXXXXXX/*"
            ]
        }
    ]
}
```

