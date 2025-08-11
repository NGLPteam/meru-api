WITH stats AS (
  SELECT
    harvest_attempt_id,
    COUNT(DISTINCT harvest_entity_id) AS total_entities,
    COUNT(DISTINCT harvest_entity_id) FILTER (WHERE assets) AS total_entities_with_assets,
    COUNT(DISTINCT harvest_entity_id) FILTER (WHERE current_state NOT IN ('success', 'upserted')) AS total_entities_waiting_for_upsert,
    COUNT(DISTINCT harvest_entity_id) FILTER (WHERE assets AND current_state NOT IN ('success', 'assets_fetched')) AS total_entities_waiting_for_assets,
    COUNT(DISTINCT harvest_entity_id) FILTER (WHERE current_state = 'success') AS total_entities_success,
    jsonb_build_object(
      'min', MIN(upsert_duration) FILTER (WHERE upsert_duration <> 0.0),
      'max', MAX(upsert_duration) FILTER (WHERE upsert_duration <> 0.0),
      'avg', AVG(upsert_duration) FILTER (WHERE upsert_duration <> 0.0),
      'stddev', stddev_samp(upsert_duration) FILTER (WHERE upsert_duration <> 0.0),
      'sum', SUM(upsert_duration) FILTER (WHERE upsert_duration <> 0.0)
    ) AS upsert_stats,
    jsonb_build_object(
      'min', MIN(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0),
      'max', MAX(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0),
      'avg', AVG(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0),
      'stddev', stddev_samp(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0),
      'sum', SUM(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0)
    ) AS assets_stats,
    stddev_samp(upsert_duration) FILTER (WHERE upsert_duration <> 0.0) AS upsert_duration_stddev,
    stddev_samp(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0) AS assets_duration_stddev,
    AVG(upsert_duration) FILTER (WHERE upsert_duration <> 0.0) AS upsert_duration_average,
    AVG(assets_duration) FILTER (WHERE assets AND assets_duration <> 0.0) AS assets_duration_average
  FROM harvest_attempt_entity_links
  LEFT OUTER JOIN harvest_attempt_entity_link_transitions AS mrt
    ON harvest_attempt_entity_links.id = mrt.harvest_attempt_entity_link_id AND mrt.most_recent = TRUE
  LEFT JOIN LATERAL (
    SELECT COALESCE(mrt.to_state, 'pending') AS current_state
  ) deets ON true
  GROUP BY harvest_attempt_id
)
SELECT
  harvest_attempt_id,
  stats.total_entities,
  stats.total_entities_with_assets,
  stats.total_entities_waiting_for_upsert,
  stats.total_entities_waiting_for_assets,
  stats.total_entities_success,
  stats.upsert_stats,
  stats.assets_stats,
  stats.upsert_duration_average,
  stats.upsert_duration_stddev,
  stats.assets_duration_average,
  stats.assets_duration_stddev,
  eta.upsert_estimate,
  eta.assets_estimate,
  CASE
  WHEN stats.total_entities_waiting_for_upsert > 0
    THEN CURRENT_TIMESTAMP + eta.upsert_estimate
  ELSE NULL
  END AS upsert_eta,
  CASE
  WHEN stats.total_entities_waiting_for_assets > 0
    THEN CURRENT_TIMESTAMP + eta.upsert_estimate + eta.assets_estimate
  ELSE NULL
  END AS assets_eta,
  LEAST(
    CASE
    WHEN stats.total_entities > 0
    THEN stats.total_entities_success::decimal / stats.total_entities::decimal
    ELSE
      0.0
    END::decimal,
    1.0
  ) AS completion
  FROM stats
  LEFT JOIN LATERAL (
    SELECT
      COALESCE(
        make_interval(secs => stats.total_entities_waiting_for_upsert * upsert_duration_average),
        INTERVAL '0 seconds'
      ) AS upsert_estimate,
      COALESCE(
        make_interval(secs => stats.total_entities_waiting_for_assets * assets_duration_average),
        INTERVAL '0 seconds'
      ) AS assets_estimate
  ) eta ON TRUE
