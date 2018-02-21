CREATE DATABASE IF NOT EXISTS `OPERATOR_DB`;

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.events (
  `event_name` string,
  `created_at` timestamp,
  `user_id` string,
  `intercom_user_id` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/events/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.historical_segment_memberships (
  `user_id` string,
  `segment_id` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/historical_segment_memberships/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.historical_segments (
  `id` string,
  `name` string,
  `type` string,
  `created_at` timestamp,
  `updated_at` timestamp,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/historical_segments/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.historical_tag_memberships (
  `user_id` string,
  `tag_id` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/historical_tag_memberships/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.historical_tags (
  `id` string,
  `name` string,
  `type` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/historical_tags/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.historical_users (
  `id` string,
  `type` string,
  `created_at` timestamp,
  `signed_up_at` timestamp,
  `updated_at` timestamp,
  `user_id` string,
  `email` string,
  `last_request_at` timestamp,
  `session_count` int,
  `unsubscribed_from_emails` boolean,
  `user_agent_data` string,
  `last_seen_ip` string,
  `pseudonym` string,
  `anonymous` boolean,
  `name` string,
  `location_data` struct<type:string,
                         city_name:string,
                         continent_code:string,
                         country_code:string,
                         latitude:double,
                         longitude:double,
                         postal_code:string,
                         region_name:string,
                         timezone:string
                         >
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/historical_users/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.segment_memberships (
  `user_id` string,
  `segment_id` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/segment_memberships/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.segments (
  `id` string,
  `name` string,
  `type` string,
  `created_at` timestamp,
  `updated_at` timestamp,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/segments/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.tag_memberships (
  `user_id` string,
  `tag_id` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/tag_memberships/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.tags (
  `id` string,
  `name` string,
  `type` string,
  `_observed_at` timestamp
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/tags/';

CREATE EXTERNAL TABLE IF NOT EXISTS `OPERATOR_DB`.users (
  `id` string,
  `type` string,
  `created_at` timestamp,
  `signed_up_at` timestamp,
  `updated_at` timestamp,
  `user_id` string,
  `email` string,
  `last_request_at` timestamp,
  `session_count` int,
  `unsubscribed_from_emails` boolean,
  `user_agent_data` string,
  `last_seen_ip` string,
  `pseudonym` string,
  `anonymous` boolean,
  `name` string,
  `location_data` struct<type:string,
                         city_name:string,
                         continent_code:string,
                         country_code:string,
                         latitude:double,
                         longitude:double,
                         postal_code:string,
                         region_name:string,
                         timezone:string
                         >
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://OPERATOR_BUCKET/users/';
