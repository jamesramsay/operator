WITH "months" AS (
  -- Create sequence of dates to analyze
  SELECT CAST("date_column" AS DATE) "sample_date"
  FROM (VALUES
    (SEQUENCE(FROM_ISO8601_DATE('2016-04-01'), 
              FROM_ISO8601_DATE('2017-03-01'), 
              INTERVAL '1' MONTH)
  )) AS t1(date_array)
  CROSS JOIN UNNEST(date_array) AS t2(date_column)),

"monthly_users" AS (
  -- Memberships for each date
  SELECT
    user_id,
    sample_date
  FROM historical_segment_memberships

  -- Select only relevant samples
  JOIN months ON months.sample_date = date_trunc('day', historical_segment_memberships._observed_at)

  -- Allow filtering using segment name
  JOIN segments ON segments.id = historical_segment_memberships.segment_id

  -- Filters
  WHERE segments.name = 'Active'),

"lag_lead" AS (
  -- Calculate the previous and next month a user was also in the segment
  SELECT
    user_id,
    sample_date,
    lag(sample_date, 1) OVER (PARTITION BY user_id ORDER BY user_id, sample_date) lag,
    lead(sample_date, 1) OVER (PARTITION BY user_id ORDER BY user_id, sample_date) lead
  FROM monthly_users),

"lag_lead_diff" AS (
  SELECT
    user_id,
    sample_date,
    lag,
    lead,
    date_diff('month', lag, sample_date) lag_size,
    date_diff('month', sample_date, lead) lead_size
  FROM lag_lead),

"lag_lead_enums" AS (
  SELECT
    user_id,
    sample_date,
  
    CASE WHEN lag IS NULL THEN 'NEW'
      WHEN lag_size = 1 THEN 'ACTIVE'
      WHEN lag_size > 1 THEN 'RETURN'
    END AS this_month_value,
  
    CASE WHEN (lead_size > 1 OR lead_size IS NULL) THEN 'CHURN'
      ELSE NULL
    END AS next_month_churn
  FROM lag_lead_diff),
  
"lag_lead_agg" AS (
  SELECT
    sample_date,
    this_month_value,
    next_month_churn,
    COUNT(DISTINCT user_id) count
  FROM lag_lead_enums
  GROUP BY sample_date, this_month_value, next_month_churn
)
  
SELECT
  sample_date,
  this_month_value,
  SUM(count)
FROM lag_lead_agg
GROUP BY sample_date, this_month_value
UNION
SELECT
  date_add('month', 1, sample_date) sample_date,
  'CHURN',
  count
FROM lag_lead_agg
WHERE next_month_churn IS NOT NULL
ORDER BY sample_date

