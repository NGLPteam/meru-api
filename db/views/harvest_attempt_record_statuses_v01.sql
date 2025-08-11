WITH stats AS (
  SELECT
    harvest_attempt_id,
    COUNT(DISTINCT harvest_record_id) AS total_records,
    COUNT(DISTINCT harvest_record_id) FILTER (WHERE current_state NOT IN ('success', 'upserted', 'extracted')) AS total_records_waiting_for_extraction,
    COUNT(DISTINCT harvest_record_id) FILTER (WHERE current_state NOT IN ('success', 'upserted')) AS total_records_waiting_for_upsert,
    COUNT(DISTINCT harvest_record_id) FILTER (WHERE current_state = 'success') AS total_records_success,
    jsonb_build_object(
      'min', MIN(extraction_duration) FILTER (WHERE extraction_duration <> 0.0),
      'max', MAX(extraction_duration) FILTER (WHERE extraction_duration <> 0.0),
      'avg', AVG(extraction_duration) FILTER (WHERE extraction_duration <> 0.0),
      'stddev', stddev_samp(extraction_duration) FILTER (WHERE extraction_duration <> 0.0),
      'sum', SUM(extraction_duration) FILTER (WHERE extraction_duration <> 0.0)
    ) AS extraction_stats,
    stddev_samp(extraction_duration) FILTER (WHERE extraction_duration <> 0.0) AS extraction_duration_stddev,
    AVG(extraction_duration) FILTER (WHERE extraction_duration <> 0.0) AS extraction_duration_average
  FROM harvest_attempt_record_links
  LEFT OUTER JOIN harvest_attempt_record_link_transitions AS mrt
    ON harvest_attempt_record_links.id = mrt.harvest_attempt_record_link_id AND mrt.most_recent = TRUE
  LEFT JOIN LATERAL (
    SELECT COALESCE(mrt.to_state, 'pending') AS current_state
  ) deets ON true
  GROUP BY harvest_attempt_id
)
SELECT
  harvest_attempt_id,
  stats.total_records,
  stats.total_records_waiting_for_extraction,
  stats.total_records_waiting_for_upsert,
  stats.total_records_success,
  stats.extraction_stats,
  stats.extraction_duration_average,
  stats.extraction_duration_stddev,
  LEAST(
    CASE
    WHEN stats.total_records > 0
    THEN stats.total_records_success::decimal / stats.total_records::decimal
    ELSE
      0.0
    END::decimal,
    1.0
  ) AS completion
  FROM stats
