-- REPORT: Monthly active users
--
-- Assumes only one dump per day. More frequent dmps will require distinct user_id before aggregation.

-- Generate a table of dates to join against
WITH "months" AS (
  SELECT CAST("date_column" AS DATE) "sample_date"
  FROM (VALUES
    (SEQUENCE(FROM_ISO8601_DATE('2016-05-01'), 
              FROM_ISO8601_DATE('2017-05-01'), 
              INTERVAL '1' MONTH)
  )) AS t1(date_array)
  CROSS JOIN UNNEST(date_array) AS t2(date_column)
)

SELECT
  sample_date,
  COUNT(1)
FROM historical_segment_memberships

-- Join with the generated sample dates
JOIN months ON months.sample_date = date_trunc('day', historical_segment_memberships._observed_at)

-- For convenient filtering by segment name rather than id, join with segments
JOIN segments ON segments.id = historical_segment_memberships.segment_id

WHERE segments.name = 'Active'
GROUP BY sample_date
ORDER BY sample_date;

