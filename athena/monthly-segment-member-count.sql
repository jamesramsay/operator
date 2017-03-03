-- REPORT: Monthly active users
--
-- Assumes only one dump per day. More frequent dmps will require distinct user_id before aggregation.

WITH "months" AS (
  SELECT CAST("date_column" AS DATE) "sample_date"
  FROM (VALUES
    (SEQUENCE(FROM_ISO8601_DATE('2016-04-01'), 
              FROM_ISO8601_DATE('2017-03-01'), 
              INTERVAL '1' MONTH)
  )) AS t1(date_array)
  CROSS JOIN UNNEST(date_array) AS t2(date_column)
)

SELECT
  sample_date,
  COUNT(1)
FROM segment_memberships

-- Select only relevant samples
JOIN months ON months.sample_date = date_trunc('day', segment_memberships._observed_at)

-- Allow filtering using segment name
JOIN segments ON segments.segment_id = segment_memberships.segment_id

-- Filters
WHERE segments.name = 'Active'
GROUP BY sample_date
ORDER BY sample_date;
