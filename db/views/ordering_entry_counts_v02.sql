SELECT
  ordering_id,
  COUNT(*) FILTER (WHERE ev.active) AS visible_count,
  COUNT(*) AS entries_count
FROM ordering_entries oe
LEFT OUTER JOIN entity_visibilities ev USING (entity_type, entity_id)
GROUP BY ordering_id
