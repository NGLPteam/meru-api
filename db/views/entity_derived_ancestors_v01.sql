SELECT
  ent.entity_type,
  ent.entity_id,
  sva.name,
  anc.ancestor_type,
  anc.ancestor_id,
  anc.ancestor_schema_version_id,
  ent.depth AS origin_depth,
  anc.ancestor_depth,
  ent.depth - anc.ancestor_depth AS relative_depth
  FROM schema_version_ancestors sva
  INNER JOIN entities ent USING (schema_version_id)
  LEFT JOIN LATERAL (
    SELECT
      x.entity_type AS ancestor_type,
      x.entity_id AS ancestor_id,
      x.schema_version_id AS ancestor_schema_version_id,
      x.depth AS ancestor_depth
    FROM entities x
    WHERE
      x.link_operator IS NULL
      AND
      x.depth < ent.depth
      AND
      ent.auth_path <@ x.auth_path
      AND
      x.schema_version_id = sva.target_version_id
    ORDER BY x.depth DESC
    LIMIT 1
  ) anc ON true
  WHERE
    ent.link_operator IS NULL
    AND
    anc.ancestor_id IS NOT NULL
;
