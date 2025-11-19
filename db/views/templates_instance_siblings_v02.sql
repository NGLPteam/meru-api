SELECT
  source.template_instance_type,
  source.template_instance_id,
  sibling.template_instance_type AS sibling_instance_type,
  sibling.template_instance_id AS sibling_instance_id,
  sibling.position AS position,
  CASE WHEN sibling.position > source.position THEN 'next'::sibling_kind ELSE 'prev'::sibling_kind END AS kind,
  COALESCE(
    sibling.config @> '{"dark": true}',
    false
  ) AS dark,
  sibling.config,
  sibling.layout_kind,
  sibling.template_kind,
  sibling.width,
  sibling.hidden
  FROM templates_instance_digests AS source
  INNER JOIN templates_instance_digests AS sibling USING (layout_instance_type, layout_instance_id)
  WHERE source.template_instance_id <> sibling.template_instance_id
