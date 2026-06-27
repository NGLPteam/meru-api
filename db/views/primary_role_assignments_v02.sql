SELECT DISTINCT ON (ag.subject_id, ag.subject_type)
  ag.subject_id,
  ag.subject_type,
  ag.role_id
  FROM (SELECT DISTINCT subject_id, subject_type, role_id FROM access_grants) ag
  INNER JOIN roles r ON r.id = ag.role_id
  ORDER BY 1, 2, r.primacy, r.priority DESC, r.kind
