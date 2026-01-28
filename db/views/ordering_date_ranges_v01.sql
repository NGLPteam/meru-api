SELECT DISTINCT ON (oe.ordering_id)
  oe.ordering_id AS ordering_id,
  first_value(pd.normalized) OVER w AS oldest_published,
  last_value(pd.normalized) OVER w AS latest_published
  FROM ordering_entries oe
  INNER JOIN named_variable_dates pd ON
    pd.entity_type = oe.entity_type
    AND
    pd.entity_id = oe.entity_id
    AND
    pd.path = '$published$'
    AND
    pd.precision IS NOT NULL
    AND
    pd.value IS NOT NULL
  WINDOW w AS (
    PARTITION BY oe.ordering_id
    ORDER BY
      pd.value ASC,
      pd.precision DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  )
;
