SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: custom_numeric; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.custom_numeric (provider = icu, locale = 'en-u-kn-true');


--
-- Name: COLLATION custom_numeric; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLLATION public.custom_numeric IS 'A custom collation that supports lexically ordering by integral values found within the string, so that 1, 2, 10 orders correctly.';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: intarray; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: access_management; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.access_management AS ENUM (
    'global',
    'contextual',
    'forbidden'
);


--
-- Name: analytics_context; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.analytics_context AS ENUM (
    'admin',
    'frontend'
);


--
-- Name: asset_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.asset_kind AS ENUM (
    'unknown',
    'image',
    'video',
    'audio',
    'pdf',
    'document',
    'archive'
);


--
-- Name: blurb_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.blurb_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: child_entity_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.child_entity_kind AS ENUM (
    'collection',
    'item'
);


--
-- Name: collection_link_operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collection_link_operator AS ENUM (
    'contains',
    'references'
);


--
-- Name: collection_linked_item_operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collection_linked_item_operator AS ENUM (
    'contains',
    'references'
);


--
-- Name: contributor_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.contributor_kind AS ENUM (
    'person',
    'organization'
);


--
-- Name: contributor_list_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.contributor_list_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: contributor_list_filter; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.contributor_list_filter AS ENUM (
    'all',
    'authors'
);


--
-- Name: date_precision; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.date_precision AS ENUM (
    'none',
    'year',
    'month',
    'day'
);


--
-- Name: descendant_list_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.descendant_list_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: descendant_list_selection_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.descendant_list_selection_mode AS ENUM (
    'dynamic',
    'named',
    'manual',
    'property'
);


--
-- Name: descendant_list_variant; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.descendant_list_variant AS ENUM (
    'cards',
    'compact',
    'grid',
    'promos',
    'summary',
    'tree'
);


--
-- Name: detail_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.detail_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: detail_variant; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.detail_variant AS ENUM (
    'full',
    'summary',
    'columns'
);


--
-- Name: entity_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entity_visibility AS ENUM (
    'visible',
    'hidden',
    'limited'
);


--
-- Name: frontend_revalidation_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.frontend_revalidation_kind AS ENUM (
    'entity',
    'instance'
);


--
-- Name: full_text_weight; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.full_text_weight AS "char" DEFAULT 'D'::"char"
	CONSTRAINT valid_full_text_weight CHECK ((VALUE = ANY (ARRAY['A'::"char", 'B'::"char", 'C'::"char", 'D'::"char"])));


--
-- Name: harvest_message_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_message_level AS ENUM (
    'fatal',
    'error',
    'warn',
    'info',
    'debug',
    'trace'
);


--
-- Name: harvest_metadata_format; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_metadata_format AS ENUM (
    'jats',
    'mets',
    'mods',
    'oaidc',
    'esploro',
    'pressbooks'
);


--
-- Name: harvest_metadata_mapping_field; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_metadata_mapping_field AS ENUM (
    'relation',
    'title',
    'identifier'
);


--
-- Name: harvest_modification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_modification_status AS ENUM (
    'unharvested',
    'pristine',
    'modified'
);


--
-- Name: harvest_protocol; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_protocol AS ENUM (
    'unknown',
    'oai',
    'pressbooks'
);


--
-- Name: harvest_record_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_record_status AS ENUM (
    'pending',
    'active',
    'skipped',
    'deleted'
);


--
-- Name: harvest_schedule_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_schedule_mode AS ENUM (
    'manual',
    'scheduled'
);


--
-- Name: harvest_source_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.harvest_source_status AS ENUM (
    'active',
    'inactive'
);


--
-- Name: hero_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.hero_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: hero_template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.hero_template_kind AS ENUM (
    'hero'
);


--
-- Name: initial_ordering_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.initial_ordering_kind AS ENUM (
    'selected',
    'derived'
);


--
-- Name: item_link_operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.item_link_operator AS ENUM (
    'contains',
    'references'
);


--
-- Name: jsonb_auth_path_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.jsonb_auth_path_state AS (
	path public.ltree,
	granted boolean
);


--
-- Name: layout_definition_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.layout_definition_kind AS ENUM (
    'root',
    'leaf'
);


--
-- Name: layout_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.layout_kind AS ENUM (
    'hero',
    'list_item',
    'main',
    'navigation',
    'metadata',
    'supplementary'
);


--
-- Name: link_list_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.link_list_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: link_list_selection_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.link_list_selection_mode AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: link_list_variant; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.link_list_variant AS ENUM (
    'cards',
    'compact',
    'grid',
    'promos',
    'summary',
    'tree'
);


--
-- Name: link_operator; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.link_operator AS ENUM (
    'contains',
    'references'
);


--
-- Name: list_entity_context; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.list_entity_context AS ENUM (
    'full',
    'abbr',
    'none'
);


--
-- Name: list_item_selection_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.list_item_selection_mode AS ENUM (
    'dynamic',
    'named',
    'manual',
    'property'
);


--
-- Name: list_item_template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.list_item_template_kind AS ENUM (
    'list_item'
);


--
-- Name: main_template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.main_template_kind AS ENUM (
    'detail',
    'descendant_list',
    'link_list',
    'page_list',
    'contributor_list',
    'ordering',
    'blurb'
);


--
-- Name: metadata_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.metadata_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: metadata_template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.metadata_template_kind AS ENUM (
    'metadata'
);


--
-- Name: navigation_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.navigation_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: navigation_template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.navigation_template_kind AS ENUM (
    'navigation'
);


--
-- Name: ordering_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ordering_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: page_list_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.page_list_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: parsed_semver; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.parsed_semver AS (
	major integer,
	minor integer,
	patch integer,
	pre public.citext,
	build public.citext
);


--
-- Name: permalinkable_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.permalinkable_kind AS ENUM (
    'community',
    'collection',
    'item'
);


--
-- Name: permission_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.permission_kind AS ENUM (
    'contextual',
    'global'
);


--
-- Name: request_query_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_query_kind AS ENUM (
    'query',
    'mutation',
    'subscription',
    'other'
);


--
-- Name: role_identifier; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.role_identifier AS ENUM (
    'admin',
    'manager',
    'editor',
    'reader'
);


--
-- Name: role_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.role_kind AS ENUM (
    'system',
    'custom'
);


--
-- Name: role_primacy; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.role_primacy AS ENUM (
    'high',
    'default',
    'low'
);


--
-- Name: schema_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.schema_kind AS ENUM (
    'community',
    'collection',
    'item'
);


--
-- Name: schema_property_function; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.schema_property_function AS ENUM (
    'content',
    'metadata',
    'presentation',
    'sorting',
    'unspecified'
);


--
-- Name: schema_property_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.schema_property_kind AS ENUM (
    'simple',
    'complex',
    'reference',
    'group'
);


--
-- Name: schema_property_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.schema_property_type AS ENUM (
    'group',
    'asset',
    'assets',
    'boolean',
    'contributor',
    'contributors',
    'controlled_vocabulary',
    'controlled_vocabularies',
    'date',
    'email',
    'entities',
    'entity',
    'float',
    'full_text',
    'integer',
    'markdown',
    'multiselect',
    'select',
    'string',
    'tags',
    'timestamp',
    'unknown',
    'url',
    'variable_date'
);


--
-- Name: selection_source_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.selection_source_mode AS ENUM (
    'self',
    'ancestor',
    'parent'
);


--
-- Name: semantic_version; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.semantic_version AS public.citext DEFAULT '0.0.0'::public.citext
	CONSTRAINT semver_format_applies CHECK ((VALUE OPERATOR(public.~) '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'::public.citext));


--
-- Name: sibling_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sibling_kind AS ENUM (
    'prev',
    'next'
);


--
-- Name: supplementary_background; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.supplementary_background AS ENUM (
    'none',
    'light',
    'dark'
);


--
-- Name: supplementary_template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.supplementary_template_kind AS ENUM (
    'supplementary'
);


--
-- Name: template_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.template_kind AS ENUM (
    'hero',
    'list_item',
    'navigation',
    'metadata',
    'supplementary',
    'detail',
    'descendant_list',
    'link_list',
    'page_list',
    'contributor_list',
    'ordering',
    'blurb'
);


--
-- Name: template_slot_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.template_slot_kind AS ENUM (
    'block',
    'inline'
);


--
-- Name: template_width; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.template_width AS ENUM (
    'full',
    'half'
);


--
-- Name: underlying_data_format; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.underlying_data_format AS ENUM (
    'xml',
    'json'
);


--
-- Name: variable_precision_date; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.variable_precision_date AS (
	value date,
	"precision" public.date_precision
);


--
-- Name: variable_precision(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.variable_precision(date) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 IS NOT NULL THEN ROW($1, 'day')::public.variable_precision_date
ELSE
  ROW(NULL, 'none')::public.variable_precision_date
END;
$_$;


--
-- Name: CAST (date AS public.variable_precision_date); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (date AS public.variable_precision_date) WITH FUNCTION public.variable_precision(date) AS ASSIGNMENT;


--
-- Name: calculate_role_kind(public.role_identifier); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_role_kind(public.role_identifier) RETURNS public.role_kind
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 IS NOT NULL THEN 'system'
ELSE
  'custom'
END::public.role_kind;
$_$;


--
-- Name: CAST (public.role_identifier AS public.role_kind); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.role_identifier AS public.role_kind) WITH FUNCTION public.calculate_role_kind(public.role_identifier) AS ASSIGNMENT;


--
-- Name: calculate_role_primacy(public.role_identifier); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_role_primacy(public.role_identifier) RETURNS public.role_primacy
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE $1
WHEN 'admin'::public.role_identifier THEN 'high'
WHEN 'reader'::public.role_identifier THEN 'low'
ELSE
  'default'
END::public.role_primacy;
$_$;


--
-- Name: CAST (public.role_identifier AS public.role_primacy); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.role_identifier AS public.role_primacy) WITH FUNCTION public.calculate_role_primacy(public.role_identifier) AS ASSIGNMENT;


--
-- Name: vpdate_value(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_value(public.variable_precision_date) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT public.vpdate_value_for($1.value, $1.precision);
$_$;


--
-- Name: CAST (public.variable_precision_date AS date); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.variable_precision_date AS date) WITH FUNCTION public.vpdate_value(public.variable_precision_date) AS ASSIGNMENT;


--
-- Name: variable_daterange(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.variable_daterange(public.variable_precision_date) RETURNS daterange
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1.value IS NOT NULL THEN
  CASE $1.precision
  WHEN 'day' THEN daterange($1.value, $1.value, '[]')
  WHEN 'month' THEN daterange(
    date_trunc('month', $1.value)::date,
    (date_trunc('month', $1.value) + INTERVAL '1 month')::date,
    '[)')
  WHEN 'year' THEN daterange(
    date_trunc('year', $1.value)::date,
    (date_trunc('year', $1.value) + INTERVAL '1 year')::date,
    '[)')
  ELSE
    NULL
  END
ELSE
  NUll
END;
$_$;


--
-- Name: CAST (public.variable_precision_date AS daterange); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.variable_precision_date AS daterange) WITH FUNCTION public.variable_daterange(public.variable_precision_date) AS ASSIGNMENT;


--
-- Name: _jsonb_auth_path_acc(public.jsonb_auth_path_state[], public.ltree, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._jsonb_auth_path_acc(public.jsonb_auth_path_state[], public.ltree, boolean) RETURNS public.jsonb_auth_path_state[]
    LANGUAGE sql IMMUTABLE
    AS $_$ SELECT $1 || ($2, $3)::jsonb_auth_path_state; $_$;


--
-- Name: _jsonb_auth_path_final(public.jsonb_auth_path_state[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._jsonb_auth_path_final(public.jsonb_auth_path_state[]) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $_$ SELECT jsonb_set_agg(to_jsonb(x.granted), string_to_array(x.path::text, '.')) FROM ( SELECT y.path, bool_or(y.granted) AS granted FROM unnest($1) AS y(path, granted) GROUP BY y.path ) x $_$;


--
-- Name: array_distinct(anycompatiblearray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.array_distinct(anycompatiblearray) RETURNS anycompatiblearray
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT array_agg(DISTINCT x) FILTER (WHERE x IS NOT NULL) FROM unnest($1) t(x);
$_$;


--
-- Name: calculate_action(public.ltree, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_action(action public.ltree, value jsonb) RETURNS TABLE(action public.ltree, allowed boolean)
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
  $1 AS action,
  $2 = 'true'::jsonb AS allowed
  WHERE jsonb_typeof($2) = 'boolean';
$_$;


--
-- Name: calculate_actions(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_actions(jsonb) RETURNS TABLE(action public.ltree, allowed boolean)
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
WITH RECURSIVE flattened (scope, value) AS (
  SELECT
    grid.scope::public.ltree AS scope,
    grid.value AS value
    FROM jsonb_each($1) AS grid(scope, value)
    WHERE jsonb_typeof($1) = 'object'
  UNION ALL
  SELECT
    flattened.scope OPERATOR(public.||) COALESCE(grid.scope, '') AS scope,
    grid.value AS value
  FROM
    flattened, jsonb_each(flattened.value) AS grid(scope, value)
  WHERE jsonb_typeof(flattened.value) = 'object'
), actions AS (
  SELECT action.action, action.allowed
  FROM
    flattened,
    public.calculate_action(flattened.scope, flattened.value) AS action(action, allowed)
  WHERE jsonb_typeof(flattened.value) = 'boolean'
) SELECT DISTINCT ON (action) action, allowed FROM actions WHERE action IS NOT NULL;
$_$;


--
-- Name: calculate_allowed_actions(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_allowed_actions(jsonb) RETURNS public.ltree[]
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT COALESCE(
  array_agg(action ORDER BY action) FILTER (WHERE allowed),
  '{}'::public.ltree[]
) FROM public.calculate_actions($1) AS t(action, allowed)
$_$;


--
-- Name: calculate_role_priority(public.role_identifier); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_role_priority(public.role_identifier) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE $1
WHEN 'admin' THEN 40000
WHEN 'manager' THEN 20000
WHEN 'editor' THEN -20000
WHEN 'reader' THEN -40000
END;
$_$;


--
-- Name: calculate_role_priority(public.role_identifier, smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_role_priority(public.role_identifier, smallint) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 IS NULL AND $2 IS NULL THEN NULL
WHEN $1 IS NOT NULL THEN public.calculate_role_priority($1)
ELSE
  $2::int
END;
$_$;


--
-- Name: calculate_visibility_range(public.entity_visibility, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_visibility_range(public.entity_visibility, after timestamp with time zone, until timestamp with time zone) RETURNS tstzrange
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 = 'limited' AND ($2 IS NOT NULL OR $3 IS NOT NULL)
THEN tstzrange($2, $3, '[)')
ELSE
  NULL
END;
$_$;


--
-- Name: date_precision_cmp(public.date_precision, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.date_precision_cmp(public.date_precision, public.date_precision) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT
CASE
WHEN OPERATOR(public.?-) $1 AND OPERATOR(public.?-) $2 THEN 0
-- none-valued dates sort to the end of the set
WHEN OPERATOR(public.?-) $1 AND OPERATOR(public.?^) $2 THEN 1
WHEN OPERATOR(public.?^) $2 AND OPERATOR(public.?-) $2 THEN -1
ELSE
  enum_cmp($1, $2)
END;
$_$;


--
-- Name: derive_contributor_affiliation(public.contributor_kind, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.derive_contributor_affiliation(kind public.contributor_kind, properties jsonb) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
  NULLIF(
    TRIM(
      CASE kind
      WHEN 'person' THEN
        jsonb_extract_path_text($2, 'person', 'affiliation')
      WHEN 'organization' THEN
        jsonb_extract_path_text($2, 'organization', 'legal_name')
      ELSE
        NULL
      END
    ),
    ''
  );
$_$;


--
-- Name: derive_contributor_name(public.contributor_kind, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.derive_contributor_name(kind public.contributor_kind, properties jsonb) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
  NULLIF(
    TRIM(
      CASE kind
      WHEN 'person' THEN
        CONCAT(
          jsonb_extract_path_text($2, 'person', 'given_name'),
          ' ',
          jsonb_extract_path_text($2, 'person', 'family_name')
        )
      WHEN 'organization' THEN
        jsonb_extract_path_text($2, 'organization', 'legal_name')
      ELSE
        NULL
      END
    ),
    ''
  );
$_$;


--
-- Name: derive_contributor_sort_name(public.contributor_kind, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.derive_contributor_sort_name(kind public.contributor_kind, properties jsonb) RETURNS public.citext
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
  NULLIF(
    TRIM(
      CASE kind
      WHEN 'person' THEN
        CONCAT_WS(', ',
          NULLIF(TRIM(jsonb_extract_path_text($2, 'person', 'family_name')), ''),
          NULLIF(TRIM(jsonb_extract_path_text($2, 'person', 'given_name')), '')
        )
      WHEN 'organization' THEN
        jsonb_extract_path_text($2, 'organization', 'legal_name')
      ELSE
        NULL
      END
    ),
    ''
  );
$_$;


--
-- Name: extract_doi_from_data(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.extract_doi_from_data(jsonb) RETURNS public.citext
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT ($1 ->> 'doi')::public.citext WHERE $1 @> jsonb_build_object('ok', true);
$_$;


--
-- Name: generate_boolean_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_boolean_value(public.schema_property_type, jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'boolean' THEN public.jsonb_to_boolean($2) ELSE NULL END;
$_$;


--
-- Name: generate_date_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_date_value(public.schema_property_type, jsonb) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'date' THEN public.jsonb_to_date($2) ELSE NULL END;
$_$;


--
-- Name: generate_email_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_email_value(public.schema_property_type, jsonb) RETURNS public.citext
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'email' THEN public.jsonb_to_citext($2) ELSE NULL END;
$_$;


--
-- Name: generate_float_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_float_value(public.schema_property_type, jsonb) RETURNS numeric
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'float' THEN public.jsonb_to_numeric($2) ELSE NULL END;
$_$;


--
-- Name: generate_integer_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_integer_value(public.schema_property_type, jsonb) RETURNS bigint
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'integer' THEN public.jsonb_to_bigint($2) ELSE NULL END;
$_$;


--
-- Name: generate_string_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_string_value(public.schema_property_type, jsonb) RETURNS public.citext
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'string' THEN public.jsonb_to_citext($2) ELSE NULL END;
$_$;


--
-- Name: generate_timestamp_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_timestamp_value(public.schema_property_type, jsonb) RETURNS timestamp with time zone
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'timestamp' THEN public.jsonb_to_timestamptz($2) ELSE NULL END;
$_$;


--
-- Name: generate_variable_date_value(public.schema_property_type, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_variable_date_value(public.schema_property_type, jsonb) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = 'variable_date' THEN public.jsonb_to_variable_precision_date($2) ELSE NULL END;
$_$;


--
-- Name: immutable_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.immutable_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT public.unaccent('public.unaccent'::regdictionary, $1);
$_$;


--
-- Name: FUNCTION immutable_unaccent(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.immutable_unaccent(text) IS 'An expression-indexable version of unaccent that uses the default dictionary.';


--
-- Name: is_hero_template_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_hero_template_kind(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 = ANY(enum_range(NULL::hero_template_kind)::text[]);
$_$;


--
-- Name: is_hero_template_kind(public.template_kind); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_hero_template_kind(public.template_kind) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1::text = ANY(enum_range(NULL::hero_template_kind)::text[]);
$_$;


--
-- Name: is_list_item_template_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_list_item_template_kind(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 = ANY(enum_range(NULL::list_item_template_kind)::text[]);
$_$;


--
-- Name: is_list_item_template_kind(public.template_kind); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_list_item_template_kind(public.template_kind) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1::text = ANY(enum_range(NULL::list_item_template_kind)::text[]);
$_$;


--
-- Name: is_main_template_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_main_template_kind(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 = ANY(enum_range(NULL::main_template_kind)::text[]);
$_$;


--
-- Name: is_main_template_kind(public.template_kind); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_main_template_kind(public.template_kind) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1::text = ANY(enum_range(NULL::main_template_kind)::text[]);
$_$;


--
-- Name: is_metadata_template_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_metadata_template_kind(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 = ANY(enum_range(NULL::metadata_template_kind)::text[]);
$_$;


--
-- Name: is_metadata_template_kind(public.template_kind); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_metadata_template_kind(public.template_kind) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1::text = ANY(enum_range(NULL::metadata_template_kind)::text[]);
$_$;


--
-- Name: is_navigation_template_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_navigation_template_kind(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 = ANY(enum_range(NULL::navigation_template_kind)::text[]);
$_$;


--
-- Name: is_navigation_template_kind(public.template_kind); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_navigation_template_kind(public.template_kind) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1::text = ANY(enum_range(NULL::navigation_template_kind)::text[]);
$_$;


--
-- Name: is_none(public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_none(public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT $1 IS NULL OR $1 = 'none';
$_$;


--
-- Name: is_supplementary_template_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_supplementary_template_kind(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 = ANY(enum_range(NULL::supplementary_template_kind)::text[]);
$_$;


--
-- Name: is_supplementary_template_kind(public.template_kind); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_supplementary_template_kind(public.template_kind) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1::text = ANY(enum_range(NULL::supplementary_template_kind)::text[]);
$_$;


--
-- Name: is_valid_semver(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_valid_semver(jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
CASE jsonb_typeof($1)
WHEN 'string' THEN public.is_valid_semver($1 #>> '{}')
ELSE
  FALSE
END;
$_$;


--
-- Name: is_valid_semver(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_valid_semver(text) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 ~ '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$';
$_$;


--
-- Name: is_valued(public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_valued(public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT $1 IS NOT NULL AND $1 <> 'none';
$_$;


--
-- Name: jsonb_bool_or_rec(jsonb, boolean, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_bool_or_rec(jsonb, boolean, text[]) RETURNS jsonb
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT public.jsonb_set_rec($1, to_jsonb(public.jsonb_extract_boolean($1, $3) OR $2), $3);
$_$;


--
-- Name: jsonb_extract_boolean(jsonb, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_extract_boolean(jsonb, text[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE jsonb_typeof($1 #> $2) WHEN 'boolean' THEN ($1 #> $2)::boolean ELSE FALSE END;
$_$;


--
-- Name: jsonb_extract_strings(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_extract_strings(jsonb) RETURNS SETOF text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
WITH RECURSIVE extracted_objects(path, value) AS (
  SELECT
    key AS path,
    value
  FROM pg_catalog.jsonb_each(jsonb_build_object('input', $1)) AS t(key, value)
  UNION ALL
  SELECT
  path || '.' || COALESCE(obj_key, (arr_key- 1)::text),
  COALESCE(obj_value, arr_value)
  FROM extracted_objects
  LEFT JOIN LATERAL
  jsonb_each(case jsonb_typeof(value) when 'object' then value end)
  AS o(obj_key, obj_value)
  ON jsonb_typeof(value) = 'object'
  LEFT JOIN LATERAL
  jsonb_array_elements(CASE jsonb_typeof(value) WHEN 'array' THEN value END)
  WITH ORDINALITY AS a(arr_value, arr_key)
  ON jsonb_typeof(value) = 'array'
  WHERE obj_key IS NOT NULL or arr_key IS NOT NULL
)
SELECT
  value #>> '{}'
FROM extracted_objects
  WHERE jsonb_typeof(value) = 'string'
;
$_$;


--
-- Name: jsonb_set_rec(jsonb, jsonb, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_set_rec(jsonb, jsonb, text[]) RETURNS jsonb
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
  SELECT CASE
  WHEN array_length($3, 1) > 1 and ($1 #> $3[:array_upper($3, 1) - 1]) is null
  THEN public.jsonb_set_rec($1, jsonb_build_object($3[array_upper($3, 1)], $2), $3[:array_upper($3, 1) - 1])
  ELSE jsonb_set($1, $3, $2, true)
  END
$_$;


--
-- Name: jsonb_to_bigint(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_bigint(jsonb) RETURNS bigint
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'number' THEN COALESCE(public.try_cast_bigint($1 #>> '{}'), CAST(CAST($1 #>> '{}' AS numeric) AS bigint)) ELSE NULL END;
$_$;


--
-- Name: jsonb_to_boolean(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_boolean(jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'boolean' THEN CAST($1 #>> '{}' AS boolean) ELSE NULL END;
$_$;


--
-- Name: jsonb_to_citext(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_citext(jsonb) RETURNS public.citext
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'string' THEN CAST($1 #>> '{}' AS public.citext) ELSE NULL END;
$_$;


--
-- Name: jsonb_to_date(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_date(jsonb) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'string' THEN public.try_cast_date($1 #>> '{}') ELSE NULL END;
$_$;


--
-- Name: jsonb_to_numeric(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_numeric(jsonb) RETURNS numeric
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'number' THEN CAST ($1 #>> '{}' AS numeric) ELSE NULL END;
$_$;


--
-- Name: jsonb_to_text(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_text(jsonb) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'string' THEN $1 #>> '{}' ELSE NULL END;
$_$;


--
-- Name: jsonb_to_text_array(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_text_array(jsonb) RETURNS text[]
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT array_agg(x.elm ORDER BY x.idx)
FROM jsonb_array_elements_text($1) WITH ORDINALITY AS x(elm, idx)
WHERE jsonb_typeof($1) = 'array';
$_$;


--
-- Name: jsonb_to_timestamptz(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_timestamptz(jsonb) RETURNS timestamp with time zone
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'string' THEN public.try_cast_timestamptz($1 #>> '{}') ELSE NULL END;
$_$;


--
-- Name: jsonb_to_variable_precision_date(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsonb_to_variable_precision_date(jsonb) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN jsonb_typeof($1) = 'string' THEN public.try_cast_variable_precision_date($1 #>> '{}') ELSE NULL END;
$_$;


--
-- Name: ltree_generations(public.ltree, public.ltree, public.ltree); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ltree_generations(public.ltree, public.ltree, public.ltree) RETURNS bigint
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT public.nlevel(
  public.subltree(
    $1,
    public.index($1, $2),
    public.index($1, $3, public.index($1, $2))
  )
);
$_$;


--
-- Name: normalize_whitespace(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.normalize_whitespace(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT TRIM(
  regexp_replace($1, '[\s\u00a0\u180e\u2007\u200b-\u200f\u202f\u2060\ufeff]+', ' ', 'g')
);
$_$;


--
-- Name: parse_semver(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.parse_semver(text) RETURNS public.parsed_semver
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT (a[1], a[2], a[3], a[4], a[5])::public.parsed_semver
FROM (
  SELECT
  '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
  AS pat
) p
LEFT JOIN LATERAL (
  SELECT regexp_matches($1, p.pat) AS a
) match ON true
WHERE match.a IS NOT NULL;
$_$;


--
-- Name: parsed_to_semver(public.parsed_semver); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.parsed_to_semver(public.parsed_semver) RETURNS public.semantic_version
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CONCAT(
  COALESCE($1.major, 0)::text,
  '.',
  COALESCE($1.minor, 0)::text,
  '.',
  COALESCE($1.patch, 0)::text,
  (
    '-' || $1.pre
  ),
  (
    '+' || $1.build
  )
);
$_$;


--
-- Name: prevent_column_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_column_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  protected_column text := COALESCE(TG_ARGV[0], 'UNKNOWN');
BEGIN
  RAISE EXCEPTION 'attempted to update protected column %.%', TG_TABLE_NAME, protected_column;
END;
$$;


--
-- Name: record_is_skipped(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.record_is_skipped(jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT public.jsonb_extract_boolean($1, '{active}');
$_$;


--
-- Name: to_schema_kind(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_schema_kind(text) RETURNS public.schema_kind
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN $1 = ANY(enum_range(NULL::public.schema_kind)::text[]) THEN $1::public.schema_kind ELSE NULL END;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: schema_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_definition_id uuid NOT NULL,
    current boolean DEFAULT false NOT NULL,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "position" integer,
    collected_reference_paths text[] DEFAULT '{}'::text[] NOT NULL,
    scalar_reference_paths text[] DEFAULT '{}'::text[] NOT NULL,
    text_reference_paths text[] DEFAULT '{}'::text[] NOT NULL,
    name text GENERATED ALWAYS AS ((configuration ->> 'name'::text)) STORED NOT NULL,
    kind public.schema_kind GENERATED ALWAYS AS (public.to_schema_kind((configuration ->> 'kind'::text))) STORED NOT NULL,
    number public.semantic_version GENERATED ALWAYS AS ((configuration ->> 'version'::text)) STORED NOT NULL,
    namespace text GENERATED ALWAYS AS ((configuration ->> 'namespace'::text)) STORED NOT NULL,
    identifier text GENERATED ALWAYS AS ((configuration ->> 'identifier'::text)) STORED NOT NULL,
    declaration text GENERATED ALWAYS AS ((((((configuration ->> 'namespace'::text) || ':'::text) || (configuration ->> 'identifier'::text)) || ':'::text) || (configuration ->> 'version'::text))) STORED NOT NULL,
    parsed public.parsed_semver GENERATED ALWAYS AS (public.parse_semver((configuration ->> 'version'::text))) STORED NOT NULL,
    ordering_identifiers text[] GENERATED ALWAYS AS (public.jsonb_to_text_array(jsonb_path_query_array(configuration, '$."orderings"[*]."id"'::jsonpath))) STORED,
    enforces_parent boolean DEFAULT false NOT NULL,
    enforces_children boolean DEFAULT false NOT NULL,
    enforced_parent_declarations text[] DEFAULT '{}'::text[] NOT NULL,
    enforced_child_declarations text[] DEFAULT '{}'::text[] NOT NULL,
    has_ancestors boolean DEFAULT false NOT NULL,
    ancestor_names text[] DEFAULT '{}'::text[] NOT NULL,
    enforced_parent_kinds public.schema_kind[] DEFAULT '{community,collection,item}'::public.schema_kind[] NOT NULL,
    enforced_child_kinds public.child_entity_kind[] DEFAULT '{collection,item}'::public.child_entity_kind[] NOT NULL,
    CONSTRAINT configuration_has_identifier CHECK (((configuration ? 'identifier'::text) AND (jsonb_typeof((configuration -> 'identifier'::text)) = 'string'::text))),
    CONSTRAINT configuration_has_name CHECK (((configuration ? 'name'::text) AND (jsonb_typeof((configuration -> 'name'::text)) = 'string'::text))),
    CONSTRAINT configuration_has_namespace CHECK (((configuration ? 'namespace'::text) AND (jsonb_typeof((configuration -> 'namespace'::text)) = 'string'::text))),
    CONSTRAINT configuration_is_valid_kind CHECK (((configuration ? 'kind'::text) AND ((configuration ->> 'kind'::text) = ANY ((enum_range(NULL::public.schema_kind))::text[])))),
    CONSTRAINT configured_version_is_semantic CHECK (public.is_valid_semver((configuration -> 'version'::text)))
);


--
-- Name: to_header(public.schema_versions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_header(public.schema_versions) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT jsonb_build_object('id', $1.id, 'namespace', $1.namespace, 'identifier', $1.identifier, 'version', $1.number);
$_$;


--
-- Name: to_prefix_search(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_prefix_search(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT LOWER(regexp_replace($1, '[^[:alnum:]]', '', 'g'));
$_$;


--
-- Name: to_prefix_search(public.citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_prefix_search(public.citext) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT to_prefix_search($1::text);
$_$;


--
-- Name: to_unaccented_tsv(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_unaccented_tsv(jsonb) RETURNS tsvector
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT pg_catalog.to_tsvector('pg_catalog.simple'::regconfig, COALESCE(pg_catalog.STRING_AGG(public.immutable_unaccent(str), ' '), ''))
FROM public.jsonb_extract_strings($1) AS t(str);
$_$;


--
-- Name: to_unaccented_tsv(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_unaccented_tsv(text) RETURNS tsvector
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT pg_catalog.to_tsvector('pg_catalog.simple'::regconfig, COALESCE(public.immutable_unaccent($1), ''));
$_$;


--
-- Name: to_unaccented_weighted_tsv(jsonb, "char"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_unaccented_weighted_tsv(jsonb, "char") RETURNS tsvector
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT pg_catalog.setweight(public.to_unaccented_tsv($1), $2);
$_$;


--
-- Name: to_unaccented_weighted_tsv(text, "char"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_unaccented_weighted_tsv(text, "char") RETURNS tsvector
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT pg_catalog.setweight(public.to_unaccented_tsv($1), $2);
$_$;


--
-- Name: try_cast_bigint(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_bigint(text) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
BEGIN
  BEGIN
    RETURN CAST($1 AS bigint);
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
END;
$_$;


--
-- Name: try_cast_date(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_date(text, format text DEFAULT 'YYYY-MM-DD'::text) RETURNS date
    LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
BEGIN
  BEGIN
    RETURN to_date($1, $2);
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
END;
$_$;


--
-- Name: try_cast_timestamptz(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_timestamptz(text) RETURNS timestamp with time zone
    LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
BEGIN
  BEGIN
    RETURN CAST($1 AS timestamptz);
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
END;
$_$;


--
-- Name: try_cast_variable_precision_date(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_cast_variable_precision_date(text) RETURNS public.variable_precision_date
    LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
BEGIN
  BEGIN
    RETURN CAST($1 AS public.variable_precision_date);
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
END;
$_$;


--
-- Name: user_role_priority(text[], jsonb, public.ltree[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_role_priority(roles text[], metadata jsonb, allowed_actions public.ltree[]) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $$
SELECT
  CASE
  WHEN metadata @> jsonb_build_object('testing', true) THEN -1000
  ELSE
    0
  END
  +
  CASE
  WHEN 'global_admin' = ANY (roles) THEN 900
  ELSE
    0
  END;
$$;


--
-- Name: variable_precision(date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.variable_precision(date, public.date_precision) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 IS NOT NULL AND $2 IS NOT NULL AND $2 <> 'none'::public.date_precision THEN
ROW(public.vpdate_value_for($1, $2), $2)::public.variable_precision_date
ELSE
  ROW(NULL, 'none')::public.variable_precision_date
END;
$_$;


--
-- Name: FUNCTION variable_precision(date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.variable_precision(date, public.date_precision) IS 'Construct a variable precision date from args';


--
-- Name: variable_precision(public.date_precision, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.variable_precision(public.date_precision, date) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT public.variable_precision($2, $1);
$_$;


--
-- Name: FUNCTION variable_precision(public.date_precision, date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.variable_precision(public.date_precision, date) IS 'Construct a variable precision date from args';


--
-- Name: variable_precision_for(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.variable_precision_for(public.variable_precision_date) RETURNS public.date_precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 IS NOT NULL AND $1.value IS NOT NULL AND $1.precision IS NOT NULL THEN $1.precision
ELSE
  'none'::public.date_precision
END;
$_$;


--
-- Name: vpd_greatest(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpd_greatest(public.variable_precision_date, public.variable_precision_date) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
CASE
WHEN $1 -||- $2 THEN
  CASE
  WHEN $1 ?- $2 THEN $1
  WHEN ?- $1 AND ?^ $2 THEN $2
  WHEN ?^ $1 AND ?- $2 THEN $1
  ELSE
    $1
  END
WHEN ($2).value > ($1).value THEN $2
ELSE
  $1
END;
$_$;


--
-- Name: vpd_least(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpd_least(public.variable_precision_date, public.variable_precision_date) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
CASE
WHEN $1 -||- $2 THEN
  CASE
  WHEN $1 ?- $2 THEN $1
  WHEN ?- $1 AND ?^ $2 THEN $2
  WHEN ?^ $1 AND ?- $2 THEN $1
  ELSE
    $1
  END
WHEN ($2).value < ($1).value THEN $2
ELSE
  $1
END;
$_$;


--
-- Name: vpdate_cmp(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp(public.variable_precision_date, public.variable_precision_date) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
CASE
-- if either are none, we short-circuit and cmp by precision
WHEN $1 -||- $2 THEN $1 ~>? $2
WHEN date_cmp(~^ $1, ~^ $2) < 0 THEN -1
WHEN date_cmp(~^ $1, ~^ $2) > 0 THEN 1
ELSE
  -- assume dates are the same, cmp by precision
  $1 ~>? $2
END;
$_$;


--
-- Name: FUNCTION vpdate_cmp(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_cmp(public.variable_precision_date, public.variable_precision_date) IS 'Base comparison function for operator class. First sort none-valued to the end of the set, then by date, then by precision.';


--
-- Name: vpdate_cmp_any_none(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_any_none(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT OPERATOR(public.?-) $1 OR OPERATOR(public.?-) $2;
$_$;


--
-- Name: vpdate_cmp_both_none(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_both_none(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT OPERATOR(public.?-) $1 AND OPERATOR(public.?-) $2;
$_$;


--
-- Name: vpdate_cmp_both_valued(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_both_valued(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT OPERATOR(public.?^) $1 AND OPERATOR(public.?^) $2;
$_$;


--
-- Name: vpdate_cmp_precision(public.date_precision, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_precision(public.date_precision, public.variable_precision_date) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT public.date_precision_cmp($1, OPERATOR(public.~>) $2);
$_$;


--
-- Name: vpdate_cmp_precision(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_precision(public.variable_precision_date, public.date_precision) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT public.date_precision_cmp(OPERATOR(public.~>) $1, $2);
$_$;


--
-- Name: vpdate_cmp_precision(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_precision(public.variable_precision_date, public.variable_precision_date) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT public.date_precision_cmp(OPERATOR(public.~>) $1, OPERATOR(public.~>) $2);
$_$;


--
-- Name: vpdate_cmp_xor_valued(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_cmp_xor_valued(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT
CASE
WHEN OPERATOR(public.?-) $1 THEN OPERATOR(public.?^) $2
WHEN OPERATOR(public.?^) $1 THEN OPERATOR(public.?-) $2
ELSE
  FALSE
END;
$_$;


--
-- Name: vpdate_contained_by(date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contained_by(date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 <@ @& $2;
$_$;


--
-- Name: vpdate_contained_by(daterange, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contained_by(daterange, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 <@ @& $2;
$_$;


--
-- Name: vpdate_contained_by(public.variable_precision_date, daterange); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contained_by(public.variable_precision_date, daterange) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 <@ $2;
$_$;


--
-- Name: vpdate_contained_by(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contained_by(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 <@ @& $2;
$_$;


--
-- Name: vpdate_contains(daterange, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contains(daterange, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 @> @& $2;
$_$;


--
-- Name: vpdate_contains(public.variable_precision_date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contains(public.variable_precision_date, date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 @> $2;
$_$;


--
-- Name: vpdate_contains(public.variable_precision_date, daterange); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contains(public.variable_precision_date, daterange) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 @> $2;
$_$;


--
-- Name: vpdate_contains(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_contains(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 @> @& $2;
$_$;


--
-- Name: vpdate_eq(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_eq(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT vpdate_cmp($1, $2) = 0;
$_$;


--
-- Name: FUNCTION vpdate_eq(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_eq(public.variable_precision_date, public.variable_precision_date) IS 'Equality function. Implementation for =(variable_precision_date, variable_precision_date)';


--
-- Name: vpdate_ge(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_ge(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT vpdate_cmp($1, $2) >= 0;
$_$;


--
-- Name: FUNCTION vpdate_ge(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_ge(public.variable_precision_date, public.variable_precision_date) IS 'Implementation for >=(variable_precision_date, variable_precision_date)';


--
-- Name: vpdate_gt(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_gt(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT vpdate_cmp($1, $2) > 0;
$_$;


--
-- Name: FUNCTION vpdate_gt(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_gt(public.variable_precision_date, public.variable_precision_date) IS 'Implementation for >(variable_precision_date, variable_precision_date)';


--
-- Name: vpdate_has_value(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_has_value(public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT $1 IS NOT NULL AND OPERATOR(public.~>) $1 <> 'none'::public.date_precision;
$_$;


--
-- Name: vpdate_is_none(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_is_none(public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT $1 IS NULL OR OPERATOR(public.~>) $1 = 'none'::public.date_precision;
$_$;


--
-- Name: vpdate_le(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_le(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT vpdate_cmp($1, $2) <= 0;
$_$;


--
-- Name: FUNCTION vpdate_le(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_le(public.variable_precision_date, public.variable_precision_date) IS 'Implementation for <=(variable_precision_date, variable_precision_date)';


--
-- Name: vpdate_lt(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_lt(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT vpdate_cmp($1, $2) < 0;
$_$;


--
-- Name: FUNCTION vpdate_lt(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_lt(public.variable_precision_date, public.variable_precision_date) IS 'Implementation for <(variable_precision_date, variable_precision_date)';


--
-- Name: vpdate_neq(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_neq(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT vpdate_cmp($1, $2) <> 0;
$_$;


--
-- Name: FUNCTION vpdate_neq(public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_neq(public.variable_precision_date, public.variable_precision_date) IS 'Inequality function. Implementation for <>(variable_precision_date, variable_precision_date), and by proxy, !=';


--
-- Name: vpdate_normalize(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_normalize(public.variable_precision_date) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $_$
SELECT CASE
WHEN $1 IS NULL OR $1.precision = 'none'::public.date_precision THEN ROW(NULL, 'none')::public.variable_precision_date
ELSE
  public.variable_precision($1.value, $1.precision)
END;
$_$;


--
-- Name: vpdate_nullif_none(public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_nullif_none(public.variable_precision_date) RETURNS public.variable_precision_date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT CASE WHEN OPERATOR(public.?^) $1 THEN OPERATOR(public.@) $1 ELSE NULL END;
$_$;


--
-- Name: FUNCTION vpdate_nullif_none(public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.vpdate_nullif_none(public.variable_precision_date) IS 'Normalize and nullify none-valued variable precision dates';


--
-- Name: vpdate_overlaps(daterange, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_overlaps(daterange, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 && @& $2;
$_$;


--
-- Name: vpdate_overlaps(public.variable_precision_date, daterange); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_overlaps(public.variable_precision_date, daterange) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 && $2;
$_$;


--
-- Name: vpdate_overlaps(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_overlaps(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT @& $1 && @& $2;
$_$;


--
-- Name: vpdate_precision_eq(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_eq(public.variable_precision_date, public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT OPERATOR(public.~>) $1 = $2;
$_$;


--
-- Name: vpdate_precision_eq(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_eq(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT ~> $1 = ~> $2;
$_$;


--
-- Name: vpdate_precision_ge(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_ge(public.variable_precision_date, public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 OPERATOR(public.~>?) $2 >= 0;
$_$;


--
-- Name: vpdate_precision_ge(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_ge(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 ~>? $2 >= 0;
$_$;


--
-- Name: vpdate_precision_gt(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_gt(public.variable_precision_date, public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 OPERATOR(public.~>?) $2 > 0;
$_$;


--
-- Name: vpdate_precision_gt(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_gt(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 ~>? $2 > 0;
$_$;


--
-- Name: vpdate_precision_le(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_le(public.variable_precision_date, public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 OPERATOR(public.~>?) $2 <= 0;
$_$;


--
-- Name: vpdate_precision_le(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_le(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 ~>? $2 <= 0;
$_$;


--
-- Name: vpdate_precision_lt(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_lt(public.variable_precision_date, public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 OPERATOR(public.~>?) $2 < 0;
$_$;


--
-- Name: vpdate_precision_lt(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_lt(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT $1 ~>? $2 < 0;
$_$;


--
-- Name: vpdate_precision_neq(public.variable_precision_date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_neq(public.variable_precision_date, public.date_precision) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT OPERATOR(public.~>) $1 <> $2;
$_$;


--
-- Name: vpdate_precision_neq(public.variable_precision_date, public.variable_precision_date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_precision_neq(public.variable_precision_date, public.variable_precision_date) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT ~> $1 <> ~> $2;
$_$;


--
-- Name: vpdate_value_for(date, public.date_precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vpdate_value_for(date, public.date_precision) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
SELECT
CASE $2
WHEN 'day' THEN $1
WHEN 'month' THEN date_trunc('month', $1)::date
WHEN 'year' THEN date_trunc('year', $1)::date
ELSE
  NUll
END;
$_$;


--
-- Name: array_accum(anycompatiblearray); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.array_accum(anycompatiblearray) (
    SFUNC = array_cat,
    STYPE = anycompatiblearray,
    INITCOND = '{}'
);


--
-- Name: array_accum_distinct(anycompatiblearray); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.array_accum_distinct(anycompatiblearray) (
    SFUNC = array_cat,
    STYPE = anycompatiblearray,
    INITCOND = '{}',
    FINALFUNC = public.array_distinct
);


--
-- Name: jsonb_auth_path(public.ltree, boolean); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.jsonb_auth_path(public.ltree, boolean) (
    SFUNC = public._jsonb_auth_path_acc,
    STYPE = public.jsonb_auth_path_state[],
    INITCOND = '{}',
    FINALFUNC = public._jsonb_auth_path_final
);


--
-- Name: jsonb_bool_or(boolean, text[]); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.jsonb_bool_or(boolean, text[]) (
    SFUNC = public.jsonb_bool_or_rec,
    STYPE = jsonb,
    INITCOND = '{}'
);


--
-- Name: jsonb_set_agg(jsonb, text[]); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.jsonb_set_agg(jsonb, text[]) (
    SFUNC = public.jsonb_set_rec,
    STYPE = jsonb,
    INITCOND = '{}'
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.> (
    FUNCTION = public.vpdate_gt,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.<=),
    NEGATOR = OPERATOR(public.<),
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: max(public.variable_precision_date); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.max(public.variable_precision_date) (
    SFUNC = public.vpd_greatest,
    STYPE = public.variable_precision_date,
    FINALFUNC = public.vpdate_nullif_none,
    MSFUNC = public.vpd_greatest,
    MINVFUNC = public.vpd_least,
    MSTYPE = public.variable_precision_date,
    SORTOP = OPERATOR(public.>),
    PARALLEL = safe
);


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.< (
    FUNCTION = public.vpdate_lt,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.>),
    NEGATOR = OPERATOR(public.>=),
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: OPERATOR < (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.< (public.variable_precision_date, public.variable_precision_date) IS 'A > B based on value then precision';


--
-- Name: min(public.variable_precision_date); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.min(public.variable_precision_date) (
    SFUNC = public.vpd_least,
    STYPE = public.variable_precision_date,
    FINALFUNC = public.vpdate_nullif_none,
    MSFUNC = public.vpd_least,
    MINVFUNC = public.vpd_greatest,
    MSTYPE = public.variable_precision_date,
    SORTOP = OPERATOR(public.<),
    PARALLEL = safe
);


--
-- Name: tsvector_agg(tsvector); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.tsvector_agg(tsvector) (
    SFUNC = tsvector_concat,
    STYPE = tsvector,
    INITCOND = ''
);


--
-- Name: #; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.# (
    FUNCTION = public.vpdate_nullif_none,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: OPERATOR # (NONE, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.# (NONE, public.variable_precision_date) IS 'Normalize a variable precision date, but return null if it is none. Intended for ordering so we can easily always sort nulls to last';


--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.&& (
    FUNCTION = public.vpdate_overlaps,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.&&)
);


--
-- Name: OPERATOR && (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.&& (public.variable_precision_date, public.variable_precision_date) IS 'overlaps';


--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.&& (
    FUNCTION = public.vpdate_overlaps,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = daterange,
    COMMUTATOR = OPERATOR(public.&&)
);


--
-- Name: OPERATOR && (public.variable_precision_date, daterange); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.&& (public.variable_precision_date, daterange) IS 'overlaps';


--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.&& (
    FUNCTION = public.vpdate_overlaps,
    LEFTARG = daterange,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.&&)
);


--
-- Name: OPERATOR && (daterange, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.&& (daterange, public.variable_precision_date) IS 'overlaps';


--
-- Name: +; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.+ (
    FUNCTION = public.variable_precision,
    LEFTARG = date,
    RIGHTARG = public.date_precision,
    COMMUTATOR = OPERATOR(public.+)
);


--
-- Name: OPERATOR + (date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.+ (date, public.date_precision) IS 'Construct a variable precision date';


--
-- Name: +; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.+ (
    FUNCTION = public.variable_precision,
    LEFTARG = public.date_precision,
    RIGHTARG = date,
    COMMUTATOR = OPERATOR(public.+)
);


--
-- Name: OPERATOR + (public.date_precision, date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.+ (public.date_precision, date) IS 'Construct a variable precision date';


--
-- Name: -||-; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.-||- (
    FUNCTION = public.vpdate_cmp_any_none,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.-||-),
    NEGATOR = OPERATOR(public.?^)
);


--
-- Name: OPERATOR -||- (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.-||- (public.variable_precision_date, public.variable_precision_date) IS 'Check if any date is none-valued';


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<= (
    FUNCTION = public.vpdate_le,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.>=),
    NEGATOR = OPERATOR(public.>),
    RESTRICT = scalarlesel,
    JOIN = scalarlejoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<> (
    FUNCTION = public.vpdate_neq,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.<>),
    NEGATOR = OPERATOR(public.=),
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<@ (
    FUNCTION = public.vpdate_contained_by,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.@>)
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<@ (
    FUNCTION = public.vpdate_contained_by,
    LEFTARG = date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.@>)
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<@ (
    FUNCTION = public.vpdate_contained_by,
    LEFTARG = daterange,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.@>)
);


--
-- Name: OPERATOR <@ (daterange, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.<@ (daterange, public.variable_precision_date) IS 'contained by';


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<@ (
    FUNCTION = public.vpdate_contained_by,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = daterange,
    COMMUTATOR = OPERATOR(public.@>)
);


--
-- Name: OPERATOR <@ (public.variable_precision_date, daterange); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.<@ (public.variable_precision_date, daterange) IS 'contained by';


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.= (
    FUNCTION = public.vpdate_eq,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.=),
    NEGATOR = OPERATOR(public.<>),
    MERGES,
    HASHES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.>= (
    FUNCTION = public.vpdate_ge,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.<=),
    NEGATOR = OPERATOR(public.<),
    RESTRICT = scalargesel,
    JOIN = scalargejoinsel
);


--
-- Name: ?!; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?! (
    FUNCTION = public.vpdate_precision_neq,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?!),
    NEGATOR = OPERATOR(public.?=),
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: OPERATOR ?! (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?! (public.variable_precision_date, public.variable_precision_date) IS 'A.precision <> B.precision';


--
-- Name: ?!; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?! (
    FUNCTION = public.vpdate_precision_neq,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision,
    NEGATOR = OPERATOR(public.?=),
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: OPERATOR ?! (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?! (public.variable_precision_date, public.date_precision) IS 'A.precision <> B';


--
-- Name: ?-; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?- (
    FUNCTION = public.is_none,
    RIGHTARG = public.date_precision,
    NEGATOR = OPERATOR(public.?^)
);


--
-- Name: OPERATOR ?- (NONE, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?- (NONE, public.date_precision) IS 'Check if the date precision is none-valued or null';


--
-- Name: ?-; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?- (
    FUNCTION = public.vpdate_is_none,
    RIGHTARG = public.variable_precision_date,
    NEGATOR = OPERATOR(public.?^)
);


--
-- Name: OPERATOR ?- (NONE, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?- (NONE, public.variable_precision_date) IS 'Check if the variable precision date is none-valued';


--
-- Name: ?-; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?- (
    FUNCTION = public.vpdate_cmp_both_none,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?-)
);


--
-- Name: OPERATOR ?- (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?- (public.variable_precision_date, public.variable_precision_date) IS 'Check if both dates are none-valued';


--
-- Name: ?<; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?< (
    FUNCTION = public.vpdate_precision_lt,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?>),
    NEGATOR = OPERATOR(public.?>=),
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: OPERATOR ?< (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?< (public.variable_precision_date, public.variable_precision_date) IS 'A.precision < B.precision, with none always pushed to the end';


--
-- Name: ?<; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?< (
    FUNCTION = public.vpdate_precision_lt,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision,
    COMMUTATOR = OPERATOR(public.?>),
    NEGATOR = OPERATOR(public.?>=),
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: OPERATOR ?< (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?< (public.variable_precision_date, public.date_precision) IS 'A.precision < B, with none always pushed to the end';


--
-- Name: ?<=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?<= (
    FUNCTION = public.vpdate_precision_le,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?>=),
    NEGATOR = OPERATOR(public.?>),
    RESTRICT = scalarlesel,
    JOIN = scalarlejoinsel
);


--
-- Name: OPERATOR ?<= (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?<= (public.variable_precision_date, public.variable_precision_date) IS 'A.precision <= B.precision, with none always pushed to the end';


--
-- Name: ?<=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?<= (
    FUNCTION = public.vpdate_precision_le,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision,
    COMMUTATOR = OPERATOR(public.?>=),
    NEGATOR = OPERATOR(public.?>),
    RESTRICT = scalarlesel,
    JOIN = scalarlejoinsel
);


--
-- Name: OPERATOR ?<= (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?<= (public.variable_precision_date, public.date_precision) IS 'A.precision <= B, with none always pushed to the end';


--
-- Name: ?=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?= (
    FUNCTION = public.vpdate_precision_eq,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?=),
    NEGATOR = OPERATOR(public.?!),
    MERGES,
    HASHES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: OPERATOR ?= (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?= (public.variable_precision_date, public.variable_precision_date) IS 'A.precision = B.precision';


--
-- Name: ?=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?= (
    FUNCTION = public.vpdate_precision_eq,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision,
    NEGATOR = OPERATOR(public.?!),
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: OPERATOR ?= (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?= (public.variable_precision_date, public.date_precision) IS 'A.precision = B';


--
-- Name: ?>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?> (
    FUNCTION = public.vpdate_precision_gt,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?<),
    NEGATOR = OPERATOR(public.?<=),
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: OPERATOR ?> (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?> (public.variable_precision_date, public.variable_precision_date) IS 'A.precision > B.precision, with none always pushed to the end';


--
-- Name: ?>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?> (
    FUNCTION = public.vpdate_precision_gt,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision,
    COMMUTATOR = OPERATOR(public.?<),
    NEGATOR = OPERATOR(public.?<=),
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: OPERATOR ?> (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?> (public.variable_precision_date, public.date_precision) IS 'A.precision > B, with none always pushed to the end';


--
-- Name: ?>=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?>= (
    FUNCTION = public.vpdate_precision_ge,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?<=),
    NEGATOR = OPERATOR(public.?<),
    RESTRICT = scalargesel,
    JOIN = scalargejoinsel
);


--
-- Name: OPERATOR ?>= (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?>= (public.variable_precision_date, public.variable_precision_date) IS 'A.precision >= B.precision, with none always pushed to the end';


--
-- Name: ?>=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?>= (
    FUNCTION = public.vpdate_precision_ge,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision,
    COMMUTATOR = OPERATOR(public.?<=),
    NEGATOR = OPERATOR(public.?<),
    RESTRICT = scalargesel,
    JOIN = scalargejoinsel
);


--
-- Name: OPERATOR ?>= (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?>= (public.variable_precision_date, public.date_precision) IS 'A.precision >= B, with none always pushed to the end';


--
-- Name: ?^; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?^ (
    FUNCTION = public.is_valued,
    RIGHTARG = public.date_precision,
    NEGATOR = OPERATOR(public.?-)
);


--
-- Name: OPERATOR ?^ (NONE, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?^ (NONE, public.date_precision) IS 'Check if the date precision refers to any real value';


--
-- Name: ?^; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?^ (
    FUNCTION = public.vpdate_has_value,
    RIGHTARG = public.variable_precision_date,
    NEGATOR = OPERATOR(public.?-)
);


--
-- Name: OPERATOR ?^ (NONE, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?^ (NONE, public.variable_precision_date) IS 'Check if the variable precision date has a value, aka it is not none-valued';


--
-- Name: ?^; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.?^ (
    FUNCTION = public.vpdate_cmp_both_valued,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.?^),
    NEGATOR = OPERATOR(public.-||-)
);


--
-- Name: OPERATOR ?^ (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.?^ (public.variable_precision_date, public.variable_precision_date) IS 'Check if both dates have values';


--
-- Name: @; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.@ (
    FUNCTION = public.vpdate_normalize,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: @&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.@& (
    FUNCTION = public.variable_daterange,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: OPERATOR @& (NONE, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.@& (NONE, public.variable_precision_date) IS 'Transform a variable date into a daterange';


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.@> (
    FUNCTION = public.vpdate_contains,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.<@)
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.@> (
    FUNCTION = public.vpdate_contains,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = date,
    COMMUTATOR = OPERATOR(public.<@)
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.@> (
    FUNCTION = public.vpdate_contains,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = daterange,
    COMMUTATOR = OPERATOR(public.<@)
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.@> (
    FUNCTION = public.vpdate_contains,
    LEFTARG = daterange,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.<@)
);


--
-- Name: ^^; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.^^ (
    FUNCTION = public.vpdate_cmp_xor_valued,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date,
    COMMUTATOR = OPERATOR(public.^^)
);


--
-- Name: OPERATOR ^^ (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.^^ (public.variable_precision_date, public.variable_precision_date) IS '?^ A XOR ?^ B';


--
-- Name: ~>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~> (
    FUNCTION = public.variable_precision_for,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: OPERATOR ~> (NONE, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.~> (NONE, public.variable_precision_date) IS 'Extract the normalized precision from a variable precision date. Guaranteed to be not-null';


--
-- Name: ~>?; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~>? (
    FUNCTION = public.date_precision_cmp,
    LEFTARG = public.date_precision,
    RIGHTARG = public.date_precision
);


--
-- Name: OPERATOR ~>? (public.date_precision, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.~>? (public.date_precision, public.date_precision) IS 'Compare date precisions with none-last logic';


--
-- Name: ~>?; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~>? (
    FUNCTION = public.vpdate_cmp_precision,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.date_precision
);


--
-- Name: OPERATOR ~>? (public.variable_precision_date, public.date_precision); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.~>? (public.variable_precision_date, public.date_precision) IS 'Compare variable precision dates by precision *only*';


--
-- Name: ~>?; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~>? (
    FUNCTION = public.vpdate_cmp_precision,
    LEFTARG = public.date_precision,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: OPERATOR ~>? (public.date_precision, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.~>? (public.date_precision, public.variable_precision_date) IS 'Compare variable precision dates by precision *only*';


--
-- Name: ~>?; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~>? (
    FUNCTION = public.vpdate_cmp_precision,
    LEFTARG = public.variable_precision_date,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: OPERATOR ~>? (public.variable_precision_date, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.~>? (public.variable_precision_date, public.variable_precision_date) IS 'Compare variable precision dates by precision *only*';


--
-- Name: ~^; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.~^ (
    FUNCTION = public.vpdate_value,
    RIGHTARG = public.variable_precision_date
);


--
-- Name: OPERATOR ~^ (NONE, public.variable_precision_date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON OPERATOR public.~^ (NONE, public.variable_precision_date) IS 'Extract the normalized date from a variable precision date';


--
-- Name: access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_grants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    accessible_type character varying NOT NULL,
    accessible_id uuid NOT NULL,
    role_id uuid NOT NULL,
    user_id uuid,
    auth_path public.ltree NOT NULL,
    community_id uuid,
    collection_id uuid,
    item_id uuid,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_group_id uuid,
    subject_type character varying NOT NULL,
    subject_id uuid NOT NULL
);


--
-- Name: authorizing_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authorizing_entities (
    auth_path public.ltree NOT NULL,
    entity_id uuid NOT NULL,
    scope public.ltree NOT NULL,
    hierarchical_type text NOT NULL,
    hierarchical_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: granted_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.granted_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    access_grant_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    user_id uuid NOT NULL,
    scope public.ltree NOT NULL,
    action public.ltree NOT NULL,
    role_id uuid NOT NULL,
    accessible_type text NOT NULL,
    accessible_id uuid NOT NULL,
    auth_path public.ltree NOT NULL,
    inferred boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: contextual_single_permissions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.contextual_single_permissions AS
 SELECT ent.hierarchical_id,
    ent.hierarchical_type,
    gp.user_id,
    gp.permission_id,
    gp.action,
    gp.access_grant_id,
    gp.role_id,
    info.directly_assigned
   FROM ((public.granted_permissions gp
     JOIN public.authorizing_entities ent ON (((gp.auth_path OPERATOR(public.=) ent.auth_path) AND (gp.scope OPERATOR(public.=) ent.scope))))
     LEFT JOIN LATERAL ( SELECT ((gp.accessible_type = ent.hierarchical_type) AND (gp.accessible_id = ent.hierarchical_id)) AS directly_assigned) info ON (true))
  WHERE ((NOT info.directly_assigned) OR (NOT gp.inferred));


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind public.permission_kind NOT NULL,
    path public.ltree NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scope public.ltree GENERATED ALWAYS AS (public.subpath(path, 0, '-1'::integer)) STORED,
    name public.ltree GENERATED ALWAYS AS (public.subpath(path, '-1'::integer, 1)) STORED,
    jsonb_path text[] GENERATED ALWAYS AS (string_to_array((path)::text, '.'::text)) STORED,
    self_prefixed boolean GENERATED ALWAYS AS ((path OPERATOR(public.~) 'self.*'::public.lquery)) STORED,
    infix public.ltree GENERATED ALWAYS AS (public.subpath(path, 1, 1)) STORED,
    suffix public.ltree GENERATED ALWAYS AS (public.subpath(path, 1, (public.nlevel(path) - 1))) STORED,
    head public.ltree GENERATED ALWAYS AS (public.subpath(path, 0, 1)) STORED,
    inheritance public.ltree[] DEFAULT '{}'::public.ltree[] NOT NULL
);


--
-- Name: access_grant_management_links; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.access_grant_management_links AS
 SELECT ag.id AS access_grant_id,
    csp.user_id
   FROM ((public.access_grants ag
     JOIN public.permissions mp ON ((mp.path OPERATOR(public.=) 'self.manage_access'::public.ltree)))
     JOIN public.contextual_single_permissions csp ON (((csp.hierarchical_type = (ag.accessible_type)::text) AND (csp.hierarchical_id = ag.accessible_id) AND (csp.permission_id = mp.id))));


--
-- Name: ahoy_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ahoy_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    visit_id uuid,
    user_id uuid,
    entity_type character varying,
    entity_id uuid,
    subject_type character varying,
    subject_id uuid,
    context public.analytics_context DEFAULT 'frontend'::public.analytics_context NOT NULL,
    name public.citext,
    properties jsonb,
    "time" timestamp without time zone
);


--
-- Name: ahoy_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ahoy_visits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    visit_token character varying,
    visitor_token character varying,
    user_id uuid,
    ip inet,
    user_agent text,
    referrer text,
    referring_domain text,
    landing_page text,
    browser text,
    os text,
    device_type text,
    country text,
    region text,
    city text,
    latitude double precision,
    longitude double precision,
    utm_source text,
    utm_medium text,
    utm_term text,
    utm_content text,
    utm_campaign text,
    app_version text,
    os_version text,
    platform text,
    started_at timestamp without time zone,
    country_code text,
    region_code text,
    postal_code text,
    geocoded_at timestamp without time zone
);


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    published_on date NOT NULL,
    header text NOT NULL,
    teaser text NOT NULL,
    body text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: asset_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_hierarchies (
    ancestor_id uuid NOT NULL,
    descendant_id uuid NOT NULL,
    generations integer NOT NULL
);


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    attachable_type character varying NOT NULL,
    attachable_id uuid NOT NULL,
    parent_id uuid,
    kind public.asset_kind DEFAULT 'unknown'::public.asset_kind NOT NULL,
    "position" integer,
    name public.citext,
    content_type public.citext,
    file_size bigint,
    alt_text text,
    caption text,
    attachment_data jsonb,
    alternatives_data jsonb,
    preview_data jsonb,
    properties jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    community_id uuid,
    collection_id uuid,
    item_id uuid,
    identifier text
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name public.citext NOT NULL,
    access_control_list jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    identifier public.role_identifier,
    custom_priority smallint,
    global_access_control_list jsonb DEFAULT '{}'::jsonb NOT NULL,
    primacy public.role_primacy GENERATED ALWAYS AS (public.calculate_role_primacy(identifier)) STORED NOT NULL,
    kind public.role_kind GENERATED ALWAYS AS (public.calculate_role_kind(identifier)) STORED NOT NULL,
    priority integer GENERATED ALWAYS AS (public.calculate_role_priority(identifier, custom_priority)) STORED NOT NULL,
    allowed_actions public.ltree[] GENERATED ALWAYS AS (public.calculate_allowed_actions(access_control_list)) STORED NOT NULL,
    global_allowed_actions public.ltree[] GENERATED ALWAYS AS (public.calculate_allowed_actions(global_access_control_list)) STORED NOT NULL,
    CONSTRAINT custom_roles_have_priority_set CHECK (
CASE kind
    WHEN 'custom'::public.role_kind THEN (custom_priority IS NOT NULL)
    ELSE true
END),
    CONSTRAINT system_roles_have_no_custom_priority CHECK (
CASE kind
    WHEN 'system'::public.role_kind THEN (custom_priority IS NULL)
    ELSE true
END)
);


--
-- Name: assignable_role_targets; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.assignable_role_targets AS
 SELECT source.id AS source_role_id,
    row_number() OVER target_w AS priority,
    target.id AS target_role_id,
    row_number() OVER source_w AS source_priority,
    source.name AS source_name,
    target.name AS target_name
   FROM (public.roles source
     JOIN public.roles target ON ((target.priority < source.priority)))
  WHERE (source.allowed_actions OPERATOR(public.~) '*.manage_access'::public.lquery)
  WINDOW source_w AS (ORDER BY source.primacy, source.priority DESC, source.kind, target.primacy, target.priority DESC, target.kind), target_w AS (PARTITION BY source.id ORDER BY target.primacy, target.priority DESC, target.kind)
  ORDER BY (row_number() OVER source_w)
  WITH NO DATA;


--
-- Name: collection_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_hierarchies (
    ancestor_id uuid NOT NULL,
    descendant_id uuid NOT NULL,
    generations integer NOT NULL
);


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    community_id uuid NOT NULL,
    schema_definition_id uuid NOT NULL,
    parent_id uuid,
    identifier public.citext NOT NULL,
    system_slug public.citext NOT NULL,
    title public.citext NOT NULL COLLATE public.custom_numeric,
    raw_doi public.citext,
    summary text DEFAULT ''::text,
    thumbnail_data jsonb,
    properties jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    auth_path public.ltree NOT NULL,
    hierarchical_depth integer GENERATED ALWAYS AS (public.nlevel(auth_path)) STORED,
    schema_version_id uuid NOT NULL,
    hero_image_data jsonb,
    subtitle text,
    issn text,
    has_doi boolean DEFAULT false NOT NULL,
    doi_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    doi public.citext GENERATED ALWAYS AS (public.extract_doi_from_data(doi_data)) STORED,
    harvest_modification_status public.harvest_modification_status DEFAULT 'unharvested'::public.harvest_modification_status NOT NULL,
    marked_for_purge boolean DEFAULT false NOT NULL,
    generation uuid,
    render_duration numeric,
    last_rendered_at timestamp without time zone
);


--
-- Name: audits_mismatched_collection_parents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.audits_mismatched_collection_parents AS
 SELECT DISTINCT ON (c.id) c.id AS collection_id,
    c.community_id AS invalid_community_id,
    anc.community_id AS valid_community_id
   FROM ((public.collections c
     JOIN public.collection_hierarchies hier ON ((hier.descendant_id = c.id)))
     JOIN public.collections anc ON ((hier.ancestor_id = anc.id)))
  WHERE ((c.parent_id IS NOT NULL) AND (anc.community_id <> c.community_id))
  ORDER BY c.id, hier.generations DESC;


--
-- Name: communities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.communities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    system_slug public.citext NOT NULL,
    "position" integer,
    title public.citext NOT NULL COLLATE public.custom_numeric,
    thumbnail_data jsonb,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    auth_path public.ltree NOT NULL,
    hierarchical_depth integer GENERATED ALWAYS AS (public.nlevel(auth_path)) STORED,
    schema_definition_id uuid NOT NULL,
    schema_version_id uuid NOT NULL,
    properties jsonb,
    hero_image_data jsonb,
    subtitle text,
    hero_image_layout text DEFAULT 'one_column'::text NOT NULL,
    logo_data jsonb,
    summary text,
    tagline text,
    identifier public.citext NOT NULL,
    marked_for_purge boolean DEFAULT false NOT NULL,
    generation uuid,
    render_duration numeric,
    last_rendered_at timestamp without time zone
);


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    hierarchical_type text NOT NULL,
    hierarchical_id uuid NOT NULL,
    system_slug public.citext NOT NULL,
    auth_path public.ltree NOT NULL,
    scope public.ltree NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    depth integer GENERATED ALWAYS AS (public.nlevel(auth_path)) STORED,
    schema_version_id uuid NOT NULL,
    link_operator public.link_operator,
    title public.citext DEFAULT ''::public.citext NOT NULL COLLATE public.custom_numeric,
    properties jsonb DEFAULT '{}'::jsonb NOT NULL,
    stale_at timestamp without time zone,
    refreshed_at timestamp without time zone,
    stale boolean GENERATED ALWAYS AS (((stale_at IS NOT NULL) AND ((refreshed_at IS NULL) OR (refreshed_at < stale_at)))) STORED NOT NULL,
    search_title text NOT NULL,
    "real" boolean GENERATED ALWAYS AS ((scope OPERATOR(public.=) ANY (ARRAY['communities'::public.ltree, 'collections'::public.ltree, 'items'::public.ltree]))) STORED NOT NULL
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    collection_id uuid NOT NULL,
    schema_definition_id uuid NOT NULL,
    parent_id uuid,
    identifier public.citext NOT NULL,
    system_slug public.citext NOT NULL,
    title public.citext NOT NULL COLLATE public.custom_numeric,
    raw_doi public.citext,
    summary text DEFAULT ''::text,
    thumbnail_data jsonb,
    properties jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    auth_path public.ltree NOT NULL,
    hierarchical_depth integer GENERATED ALWAYS AS (public.nlevel(auth_path)) STORED,
    schema_version_id uuid NOT NULL,
    hero_image_data jsonb,
    subtitle text,
    issn text,
    has_doi boolean DEFAULT false NOT NULL,
    doi_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    doi public.citext GENERATED ALWAYS AS (public.extract_doi_from_data(doi_data)) STORED,
    harvest_modification_status public.harvest_modification_status DEFAULT 'unharvested'::public.harvest_modification_status NOT NULL,
    marked_for_purge boolean DEFAULT false NOT NULL,
    generation uuid,
    render_duration numeric,
    last_rendered_at timestamp without time zone
);


--
-- Name: audits_mismatched_entity_schemas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.audits_mismatched_entity_schemas AS
 WITH actual AS (
         SELECT 'Community'::text AS hierarchical_type,
            communities.id AS hierarchical_id,
            communities.schema_version_id
           FROM public.communities
        UNION ALL
         SELECT 'Collection'::text AS hierarchical_type,
            collections.id AS hierarchical_id,
            collections.schema_version_id
           FROM public.collections
        UNION ALL
         SELECT 'Item'::text AS hierarchical_type,
            items.id AS hierarchical_id,
            items.schema_version_id
           FROM public.items
        )
 SELECT ent.id AS synced_entity_id,
    (ent.link_operator IS NULL) AS "real",
    ent.entity_id AS source_id,
    ent.entity_type AS source_type,
    ent.hierarchical_id,
    ent.hierarchical_type,
    ent.schema_version_id AS synced_schema_version_id,
    actual.schema_version_id AS actual_schema_version_id
   FROM (public.entities ent
     JOIN actual USING (hierarchical_type, hierarchical_id))
  WHERE (actual.schema_version_id <> ent.schema_version_id);


--
-- Name: item_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_hierarchies (
    ancestor_id uuid NOT NULL,
    descendant_id uuid NOT NULL,
    generations integer NOT NULL
);


--
-- Name: audits_mismatched_item_parents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.audits_mismatched_item_parents AS
 SELECT DISTINCT ON (c.id) c.id AS item_id,
    c.collection_id AS invalid_collection_id,
    anc.collection_id AS valid_collection_id
   FROM ((public.items c
     JOIN public.item_hierarchies hier ON ((hier.descendant_id = c.id)))
     JOIN public.items anc ON ((hier.ancestor_id = anc.id)))
  WHERE ((c.parent_id IS NOT NULL) AND (anc.collection_id <> c.collection_id))
  ORDER BY c.id, hier.generations DESC;


--
-- Name: collection_attributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_attributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    collection_id uuid NOT NULL,
    contributor_id uuid NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: collection_authorizations; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.collection_authorizations AS
 WITH RECURSIVE closure_tree(community_id, collection_id, auth_path) AS (
         SELECT coll.community_id,
            coll.id AS collection_id,
            (comm.auth_path OPERATOR(public.||) public.text2ltree((coll.system_slug)::text)) AS auth_path
           FROM (public.collections coll
             JOIN public.communities comm ON ((comm.id = coll.community_id)))
          WHERE (coll.parent_id IS NULL)
        UNION ALL
         SELECT coll.community_id,
            coll.id AS collection_id,
            (ct.auth_path OPERATOR(public.||) public.text2ltree((coll.system_slug)::text)) AS auth_path
           FROM (public.collections coll
             JOIN closure_tree ct ON ((ct.collection_id = coll.parent_id)))
        )
 SELECT closure_tree.community_id,
    closure_tree.collection_id,
    closure_tree.auth_path
   FROM closure_tree
  WITH NO DATA;


--
-- Name: collection_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_contributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contributor_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    kind public.citext,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    role_id uuid NOT NULL,
    inner_position bigint,
    outer_position bigint
);


--
-- Name: collection_linked_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_linked_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_id uuid NOT NULL,
    target_id uuid NOT NULL,
    operator public.collection_linked_item_operator NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: collection_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_id uuid NOT NULL,
    target_id uuid NOT NULL,
    operator public.collection_link_operator NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: community_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    community_id uuid NOT NULL,
    role_id uuid,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: contextual_permissions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.contextual_permissions AS
 SELECT ent.hierarchical_id,
    ent.hierarchical_type,
    gp.user_id,
    true AS has_any_role,
    bool_or(info.directly_assigned) AS has_direct_role,
    array_agg(DISTINCT gp.access_grant_id) AS access_grant_ids,
    array_agg(DISTINCT gp.role_id) AS role_ids,
    array_agg(DISTINCT gp.action) AS allowed_actions,
    public.jsonb_auth_path(gp.action, true) AS access_control_list,
    public.jsonb_auth_path(public.subpath(gp.action, 1, (public.nlevel(gp.action) - 1)), true) FILTER (WHERE (gp.action OPERATOR(public.~) 'self.*'::public.lquery)) AS grid,
    min(gp.created_at) AS created_at,
    max(gp.updated_at) AS updated_at
   FROM ((public.granted_permissions gp
     JOIN public.authorizing_entities ent ON (((gp.auth_path OPERATOR(public.=) ent.auth_path) AND (gp.scope OPERATOR(public.=) ent.scope))))
     LEFT JOIN LATERAL ( SELECT ((gp.accessible_type = ent.hierarchical_type) AND (gp.accessible_id = ent.hierarchical_id)) AS directly_assigned) info ON (true))
  WHERE ((NOT info.directly_assigned) OR (NOT gp.inferred))
  GROUP BY ent.hierarchical_id, ent.hierarchical_type, gp.user_id;


--
-- Name: contextually_assignable_roles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.contextually_assignable_roles AS
 SELECT DISTINCT ON (ent.hierarchical_id, ent.hierarchical_type, gp.user_id, ar.target_role_id) ent.hierarchical_id,
    ent.hierarchical_type,
    gp.user_id,
    ar.target_role_id AS role_id,
    ar.priority
   FROM (((( SELECT DISTINCT granted_permissions.user_id,
            granted_permissions.accessible_id,
            granted_permissions.accessible_type,
            granted_permissions.role_id,
            granted_permissions.auth_path,
            granted_permissions.scope,
            granted_permissions.inferred
           FROM public.granted_permissions
          WHERE (granted_permissions.action OPERATOR(public.=) 'self.manage_access'::public.ltree)) gp
     JOIN public.assignable_role_targets ar ON ((ar.source_role_id = gp.role_id)))
     JOIN public.authorizing_entities ent ON (((gp.auth_path OPERATOR(public.=) ent.auth_path) AND (gp.scope OPERATOR(public.=) ent.scope))))
     LEFT JOIN LATERAL ( SELECT ((gp.accessible_type = ent.hierarchical_type) AND (gp.accessible_id = ent.hierarchical_id)) AS directly_assigned) info ON (true))
  WHERE ((NOT info.directly_assigned) OR (NOT gp.inferred));


--
-- Name: contextually_assigned_access_grants; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.contextually_assigned_access_grants AS
 SELECT ent.hierarchical_id,
    ent.hierarchical_type,
    gp.user_id,
    gp.access_grant_id
   FROM ((public.granted_permissions gp
     JOIN public.authorizing_entities ent ON (((gp.auth_path OPERATOR(public.=) ent.auth_path) AND (gp.scope OPERATOR(public.=) ent.scope))))
     LEFT JOIN LATERAL ( SELECT ((gp.accessible_type = ent.hierarchical_type) AND (gp.accessible_id = ent.hierarchical_id)) AS directly_assigned) info ON (true))
  WHERE ((NOT info.directly_assigned) OR (NOT gp.inferred))
  GROUP BY ent.hierarchical_id, ent.hierarchical_type, gp.user_id, gp.access_grant_id;


--
-- Name: contextually_assigned_roles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.contextually_assigned_roles AS
 SELECT ent.hierarchical_id,
    ent.hierarchical_type,
    gp.user_id,
    gp.role_id
   FROM ((public.granted_permissions gp
     JOIN public.authorizing_entities ent ON (((gp.auth_path OPERATOR(public.=) ent.auth_path) AND (gp.scope OPERATOR(public.=) ent.scope))))
     LEFT JOIN LATERAL ( SELECT ((gp.accessible_type = ent.hierarchical_type) AND (gp.accessible_id = ent.hierarchical_id)) AS directly_assigned) info ON (true))
  WHERE ((NOT info.directly_assigned) OR (NOT gp.inferred))
  GROUP BY ent.hierarchical_id, ent.hierarchical_type, gp.user_id, gp.role_id;


--
-- Name: contribution_role_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contribution_role_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    controlled_vocabulary_id uuid NOT NULL,
    default_item_id uuid NOT NULL,
    other_item_id uuid,
    source_type character varying NOT NULL,
    source_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: item_attributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_attributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    item_id uuid NOT NULL,
    contributor_id uuid NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: named_variable_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.named_variable_dates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    schema_version_property_id uuid,
    path text NOT NULL,
    actual public.variable_precision_date DEFAULT '(,none)'::public.variable_precision_date NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actual_precision public.date_precision GENERATED ALWAYS AS ((OPERATOR(public.~>) actual)) STORED NOT NULL,
    "precision" public.date_precision GENERATED ALWAYS AS (
CASE
    WHEN (OPERATOR(public.?^) actual) THEN (OPERATOR(public.~>) actual)
    ELSE NULL::public.date_precision
END) STORED,
    coverage daterange GENERATED ALWAYS AS ((OPERATOR(public.@&) actual)) STORED,
    normalized public.variable_precision_date GENERATED ALWAYS AS ((OPERATOR(public.#) actual)) STORED,
    value date GENERATED ALWAYS AS ((OPERATOR(public.~^) actual)) STORED
);


--
-- Name: contributor_attributions; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.contributor_attributions AS
 WITH raw_attributions AS (
         SELECT att_1.id AS attribution_id,
            'CollectionAttribution'::text AS attribution_type,
            att_1.contributor_id,
            att_1.collection_id,
            NULL::uuid AS item_id,
            att_1.collection_id AS entity_id,
            'Collection'::text AS entity_type,
            'collection'::public.child_entity_kind AS kind,
            ent.title,
            att_1.created_at,
            att_1.updated_at
           FROM (public.collection_attributions att_1
             JOIN public.collections ent ON ((ent.id = att_1.collection_id)))
        UNION ALL
         SELECT att_1.id AS attribution_id,
            'ItemAttribution'::text AS attribution_type,
            att_1.contributor_id,
            NULL::uuid AS collection_id,
            att_1.item_id,
            att_1.item_id AS entity_id,
            'Item'::text AS entity_type,
            'item'::public.child_entity_kind AS kind,
            ent.title,
            att_1.created_at,
            att_1.updated_at
           FROM (public.item_attributions att_1
             JOIN public.items ent ON ((ent.id = att_1.item_id)))
        ), hydrated_attributions AS (
         SELECT raw.attribution_id,
            raw.attribution_type,
            raw.contributor_id,
            raw.collection_id,
            raw.item_id,
            raw.entity_id,
            raw.entity_type,
            raw.kind,
            raw.title,
            (nvd.value IS NOT NULL) AS has_published,
            nvd.normalized AS published,
            nvd.value AS published_on,
            raw.created_at,
            raw.updated_at
           FROM (raw_attributions raw
             LEFT JOIN public.named_variable_dates nvd USING (entity_id, entity_type))
          WHERE (nvd.path = '$published$'::text)
        )
 SELECT att.attribution_id,
    att.attribution_type,
    att.contributor_id,
    att.collection_id,
    att.item_id,
    att.entity_id,
    att.entity_type,
    att.kind,
    att.title,
    att.has_published,
    att.published,
    att.published_on,
    dense_rank() OVER publish_w AS published_rank,
    dense_rank() OVER title_w AS title_rank,
    att.created_at,
    att.updated_at
   FROM hydrated_attributions att
  WINDOW publish_w AS (PARTITION BY att.contributor_id ORDER BY COALESCE(att.published_on, (att.created_at)::date), att.title, att.created_at), title_w AS (PARTITION BY att.contributor_id ORDER BY att.title, att.created_at)
  WITH NO DATA;


--
-- Name: contributors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contributors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind public.contributor_kind NOT NULL,
    identifier public.citext NOT NULL,
    email public.citext,
    prefix text,
    suffix text,
    bio text,
    url text,
    image_data jsonb,
    properties jsonb,
    links jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    collection_contribution_count bigint DEFAULT 0 NOT NULL,
    item_contribution_count bigint DEFAULT 0 NOT NULL,
    contribution_count bigint GENERATED ALWAYS AS ((GREATEST(collection_contribution_count, (0)::bigint) + GREATEST(item_contribution_count, (0)::bigint))) STORED,
    name text GENERATED ALWAYS AS (public.derive_contributor_name(kind, properties)) STORED,
    sort_name public.citext GENERATED ALWAYS AS (public.derive_contributor_sort_name(kind, properties)) STORED,
    affiliation text GENERATED ALWAYS AS (public.derive_contributor_affiliation(kind, properties)) STORED,
    orcid public.citext,
    search_name text GENERATED ALWAYS AS (public.to_prefix_search(public.derive_contributor_name(kind, properties))) STORED,
    harvest_modification_status public.harvest_modification_status DEFAULT 'unharvested'::public.harvest_modification_status NOT NULL
);


--
-- Name: controlled_vocabularies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.controlled_vocabularies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    namespace text NOT NULL,
    identifier text NOT NULL,
    version public.semantic_version NOT NULL,
    provides text NOT NULL,
    name text NOT NULL,
    description text,
    items_count bigint DEFAULT 0 NOT NULL,
    item_identifiers text[] DEFAULT '{}'::text[] NOT NULL,
    item_set jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: controlled_vocabulary_item_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.controlled_vocabulary_item_hierarchies (
    ancestor_id uuid NOT NULL,
    descendant_id uuid NOT NULL,
    generations integer NOT NULL
);


--
-- Name: controlled_vocabulary_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.controlled_vocabulary_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    controlled_vocabulary_id uuid NOT NULL,
    parent_id uuid,
    "position" bigint,
    identifier text NOT NULL,
    label text NOT NULL,
    description text,
    url text,
    unselectable boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    priority bigint DEFAULT 0 NOT NULL,
    ranking bigint,
    tags public.citext[] DEFAULT '{}'::public.citext[] NOT NULL
);


--
-- Name: controlled_vocabulary_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.controlled_vocabulary_sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    controlled_vocabulary_id uuid,
    provides text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: schema_version_ancestors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_version_ancestors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    target_version_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_ancestors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.entity_ancestors AS
 SELECT DISTINCT ON (sva.name, ent.entity_id) ent.entity_type,
    ent.entity_id,
    sva.name,
    anc.entity_type AS ancestor_type,
    anc.entity_id AS ancestor_id,
    anc.schema_version_id AS ancestor_schema_version_id,
    ent.depth AS origin_depth,
    anc.depth AS ancestor_depth,
    (ent.depth - anc.depth) AS relative_depth
   FROM ((public.entities ent
     JOIN public.schema_version_ancestors sva USING (schema_version_id))
     JOIN public.entities anc ON (((ent.auth_path OPERATOR(public.<@) anc.auth_path) AND (anc.entity_id <> ent.entity_id) AND (anc.schema_version_id = sva.target_version_id))))
  ORDER BY sva.name, ent.entity_id, anc.depth DESC;


--
-- Name: item_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_contributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contributor_id uuid NOT NULL,
    item_id uuid NOT NULL,
    kind public.citext,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    role_id uuid NOT NULL,
    inner_position bigint,
    outer_position bigint
);


--
-- Name: entity_author_contributions; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.entity_author_contributions AS
 WITH raw_contributions AS (
         SELECT collection_contributions.id AS contribution_id,
            'CollectionContribution'::text AS contribution_type,
            collection_contributions.collection_id AS entity_id,
            'Collection'::text AS entity_type,
            collection_contributions.contributor_id,
            collection_contributions.inner_position,
            collection_contributions.outer_position,
            collection_contributions.created_at,
            collection_contributions.updated_at
           FROM public.collection_contributions
          WHERE (collection_contributions.role_id IN ( SELECT controlled_vocabulary_items.id
                   FROM public.controlled_vocabulary_items
                  WHERE ('author'::public.citext OPERATOR(public.=) ANY (controlled_vocabulary_items.tags))))
        UNION ALL
         SELECT item_contributions.id AS contribution_id,
            'ItemContribution'::text AS contribution_type,
            item_contributions.item_id AS entity_id,
            'Item'::text AS entity_type,
            item_contributions.contributor_id,
            item_contributions.inner_position,
            item_contributions.outer_position,
            item_contributions.created_at,
            item_contributions.updated_at
           FROM public.item_contributions
          WHERE (item_contributions.role_id IN ( SELECT controlled_vocabulary_items.id
                   FROM public.controlled_vocabulary_items
                  WHERE ('author'::public.citext OPERATOR(public.=) ANY (controlled_vocabulary_items.tags))))
        )
 SELECT DISTINCT ON (rc.entity_id, rc.contributor_id) rc.contribution_id,
    rc.contribution_type,
    rc.entity_id,
    rc.entity_type,
    rc.contributor_id,
    rc.inner_position,
    rc.outer_position,
    dense_rank() OVER w AS ranking,
    c.name AS contributor_name,
    c.sort_name AS contributor_sort_name,
    public.to_unaccented_weighted_tsv(c.name, 'B'::"char") AS document,
    rc.created_at,
    rc.updated_at
   FROM (raw_contributions rc
     JOIN public.contributors c ON ((c.id = rc.contributor_id)))
  WINDOW w AS (PARTITION BY rc.entity_id ORDER BY rc.outer_position, rc.inner_position, c.sort_name)
  WITH NO DATA;


--
-- Name: entity_breadcrumbs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.entity_breadcrumbs AS
 SELECT ent.entity_type,
    ent.entity_id,
    ent.system_slug AS entity_slug,
    crumb.entity_type AS crumb_type,
    crumb.entity_id AS crumb_id,
    crumb.schema_version_id,
    crumb.auth_path,
    crumb.system_slug,
    crumb.depth
   FROM (public.entities ent
     JOIN public.entities crumb ON (((ent.auth_path OPERATOR(public.<@) crumb.auth_path) AND (crumb.entity_id <> ent.entity_id))));


--
-- Name: entity_cached_ancestors; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.entity_cached_ancestors AS
 SELECT DISTINCT ON (sva.name, ent.entity_id) ent.entity_type,
    ent.entity_id,
    sva.name,
    anc.entity_type AS ancestor_type,
    anc.entity_id AS ancestor_id,
    anc.schema_version_id AS ancestor_schema_version_id,
    ent.depth AS origin_depth,
    anc.depth AS ancestor_depth,
    (ent.depth - anc.depth) AS relative_depth
   FROM ((public.entities ent
     JOIN public.schema_version_ancestors sva USING (schema_version_id))
     JOIN public.entities anc ON (((ent.auth_path OPERATOR(public.<@) anc.auth_path) AND (anc.entity_id <> ent.entity_id) AND (anc.schema_version_id = sva.target_version_id))))
  ORDER BY sva.name, ent.entity_id, anc.depth DESC
  WITH NO DATA;


--
-- Name: entity_composed_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_composed_texts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    document tsvector DEFAULT ''::tsvector NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_derived_layout_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_derived_layout_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_hierarchies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ancestor_type character varying NOT NULL,
    ancestor_id uuid NOT NULL,
    descendant_type character varying NOT NULL,
    descendant_id uuid NOT NULL,
    hierarchical_type character varying NOT NULL,
    hierarchical_id uuid NOT NULL,
    schema_definition_id uuid NOT NULL,
    schema_version_id uuid NOT NULL,
    link_operator public.link_operator,
    ancestor_scope public.ltree NOT NULL,
    descendant_scope public.ltree NOT NULL,
    auth_path public.ltree NOT NULL,
    ancestor_slug public.ltree NOT NULL,
    descendant_slug public.ltree NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    depth bigint GENERATED ALWAYS AS (public.nlevel(auth_path)) STORED NOT NULL,
    generations bigint GENERATED ALWAYS AS (public.ltree_generations(auth_path, ancestor_slug, descendant_slug)) STORED NOT NULL,
    title public.citext NOT NULL COLLATE public.custom_numeric
);


--
-- Name: entity_descendants; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.entity_descendants AS
 SELECT hier.ancestor_type AS parent_type,
    hier.ancestor_id AS parent_id,
    hier.hierarchical_type AS descendant_type,
    hier.hierarchical_id AS descendant_id,
    hier.schema_version_id,
    hier.link_operator,
    hier.auth_path,
    hier.descendant_scope AS scope,
    hier.title,
    hier.depth AS actual_depth,
    hier.generations AS relative_depth,
    hier.created_at,
    hier.updated_at
   FROM public.entity_hierarchies hier
  WHERE (hier.ancestor_id <> hier.descendant_id);


--
-- Name: orderings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orderings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    schema_version_id uuid NOT NULL,
    community_id uuid,
    collection_id uuid,
    item_id uuid,
    identifier public.citext NOT NULL,
    inherited_from_schema boolean DEFAULT false NOT NULL,
    definition jsonb DEFAULT '{}'::jsonb NOT NULL,
    disabled_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stale_at timestamp without time zone,
    refreshed_at timestamp without time zone,
    stale boolean GENERATED ALWAYS AS (((stale_at IS NOT NULL) AND ((refreshed_at IS NULL) OR (refreshed_at < stale_at)))) STORED NOT NULL,
    name text GENERATED ALWAYS AS ((definition ->> 'name'::text)) STORED,
    schema_position bigint,
    "position" bigint,
    pristine boolean DEFAULT false NOT NULL,
    paths text[] GENERATED ALWAYS AS (public.jsonb_to_text_array(jsonb_path_query_array(definition, '$."order"[*]."path"'::jsonpath))) STORED,
    hidden boolean GENERATED ALWAYS AS (COALESCE(public.jsonb_to_boolean((definition -> 'hidden'::text)), false)) STORED NOT NULL,
    constant boolean GENERATED ALWAYS AS (COALESCE(public.jsonb_to_boolean((definition -> 'constant'::text)), false)) STORED NOT NULL,
    disabled boolean GENERATED ALWAYS AS ((disabled_at IS NOT NULL)) STORED NOT NULL,
    handled_schema_definition_id uuid,
    CONSTRAINT enforce_ordering_identifier_parity CHECK (((identifier)::text = (definition ->> 'id'::text)))
);


--
-- Name: entity_inherited_orderings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.entity_inherited_orderings AS
 SELECT sv.id AS schema_version_id,
    ent.entity_id,
    ent.entity_type,
    ord.id AS ordering_id,
    svo.identifier,
    conditions.missing,
    conditions.modified,
    conditions.mismatch,
        CASE
            WHEN conditions.missing THEN 'missing'::text
            WHEN conditions.mismatch THEN 'mismatch'::text
            WHEN conditions.modified THEN 'modified'::text
            ELSE 'pristine'::text
        END AS status
   FROM ((((public.schema_versions sv
     CROSS JOIN LATERAL unnest(sv.ordering_identifiers) svo(identifier))
     JOIN public.entities ent ON (((ent.schema_version_id = sv.id) AND (ent.link_operator IS NULL))))
     LEFT JOIN public.orderings ord ON ((((ord.entity_type)::text = ent.entity_type) AND (ord.entity_id = ent.entity_id) AND ((ord.identifier)::text = svo.identifier))))
     LEFT JOIN LATERAL ( SELECT (ord.id IS NULL) AS missing,
            ((ord.id IS NOT NULL) AND (NOT ord.pristine)) AS modified,
            ((ord.id IS NOT NULL) AND (ord.schema_version_id IS DISTINCT FROM sv.id)) AS mismatch) conditions ON (true));


--
-- Name: entity_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_type character varying NOT NULL,
    source_id uuid NOT NULL,
    target_type character varying NOT NULL,
    target_id uuid NOT NULL,
    schema_version_id uuid NOT NULL,
    source_community_id uuid,
    source_collection_id uuid,
    source_item_id uuid,
    target_community_id uuid,
    target_collection_id uuid,
    target_item_id uuid,
    operator public.link_operator NOT NULL,
    auth_path public.ltree NOT NULL,
    scope public.ltree NOT NULL,
    system_slug public.citext NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: layouts_instance_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_instance_digests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_instance_type character varying NOT NULL,
    layout_instance_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_missing_layout_instances; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.entity_missing_layout_instances AS
 SELECT dld.entity_type,
    dld.entity_id,
    dld.layout_definition_type,
    dld.layout_definition_id,
    dld.layout_kind
   FROM (public.entity_derived_layout_definitions dld
     LEFT JOIN public.layouts_instance_digests lid USING (entity_type, entity_id, layout_definition_id))
  WHERE (lid.layout_definition_id IS NULL);


--
-- Name: templates_definition_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_definition_digests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    template_definition_type character varying NOT NULL,
    template_definition_id uuid NOT NULL,
    "position" bigint,
    layout_kind public.layout_kind NOT NULL,
    template_kind public.template_kind NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: templates_instance_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_instance_digests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    template_instance_type character varying NOT NULL,
    template_instance_id uuid NOT NULL,
    template_definition_type character varying NOT NULL,
    template_definition_id uuid NOT NULL,
    layout_instance_type character varying NOT NULL,
    layout_instance_id uuid NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    "position" bigint NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    template_kind public.template_kind NOT NULL,
    width public.template_width,
    generation uuid NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    render_duration numeric,
    last_rendered_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_missing_template_instances; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.entity_missing_template_instances AS
 SELECT dld.entity_type,
    dld.entity_id,
    dld.layout_definition_type,
    dld.layout_definition_id,
    tdd.template_definition_type,
    tdd.template_definition_id,
    dld.layout_kind,
    tdd.template_kind,
    tdd."position"
   FROM ((public.entity_derived_layout_definitions dld
     JOIN public.templates_definition_digests tdd USING (layout_definition_type, layout_definition_id, layout_kind))
     LEFT JOIN public.templates_instance_digests tid USING (entity_type, entity_id, layout_definition_id, template_definition_id))
  WHERE (tid.layout_definition_id IS NULL);


--
-- Name: entity_orderable_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_orderable_properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    schema_version_property_id uuid NOT NULL,
    type public.schema_property_type NOT NULL,
    path text NOT NULL,
    fixed_position bigint,
    raw_value jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    boolean_value boolean GENERATED ALWAYS AS (public.generate_boolean_value(type, raw_value)) STORED,
    date_value date GENERATED ALWAYS AS (public.generate_date_value(type, raw_value)) STORED,
    email_value public.citext GENERATED ALWAYS AS (public.generate_email_value(type, raw_value)) STORED,
    float_value numeric GENERATED ALWAYS AS (public.generate_float_value(type, raw_value)) STORED,
    integer_value bigint GENERATED ALWAYS AS (public.generate_integer_value(type, raw_value)) STORED,
    string_value public.citext GENERATED ALWAYS AS (public.generate_string_value(type, raw_value)) STORED COLLATE public.custom_numeric,
    timestamp_value timestamp with time zone GENERATED ALWAYS AS (public.generate_timestamp_value(type, raw_value)) STORED,
    variable_date_value public.variable_precision_date GENERATED ALWAYS AS (public.generate_variable_date_value(type, raw_value)) STORED
);


--
-- Name: entity_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_search_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    community_id uuid,
    collection_id uuid,
    item_id uuid,
    title public.citext NOT NULL,
    author_names jsonb DEFAULT '[]'::jsonb NOT NULL,
    schematic_texts jsonb DEFAULT '{}'::jsonb NOT NULL,
    document tsvector DEFAULT ''::tsvector NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_searchable_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_searchable_properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    schema_version_property_id uuid,
    type public.schema_property_type NOT NULL,
    path text NOT NULL,
    raw_value jsonb,
    boolean_value boolean,
    citext_value public.citext,
    date_value date,
    float_value numeric,
    integer_value bigint,
    text_value text,
    text_array_value text[] DEFAULT '{}'::text[] NOT NULL,
    timestamp_value timestamp without time zone,
    variable_date_value public.variable_precision_date DEFAULT '(,none)'::public.variable_precision_date,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: entity_visibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_visibilities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    visible_after_at timestamp with time zone,
    visible_until_at timestamp with time zone,
    hidden_at timestamp with time zone,
    visibility public.entity_visibility DEFAULT 'visible'::public.entity_visibility NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    visibility_range tstzrange GENERATED ALWAYS AS (public.calculate_visibility_range(visibility, visible_after_at, visible_until_at)) STORED
);


--
-- Name: fake_visitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fake_visitors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    ip inet NOT NULL,
    user_agent public.citext NOT NULL,
    sequence integer NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: frontend_revalidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frontend_revalidations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind public.frontend_revalidation_kind NOT NULL,
    manual boolean DEFAULT false NOT NULL,
    revalidated_at timestamp without time zone,
    entity_type character varying,
    entity_id uuid,
    params jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: global_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.global_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    guard boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    institution jsonb DEFAULT '{}'::jsonb NOT NULL,
    entities jsonb DEFAULT '{}'::jsonb NOT NULL,
    site jsonb DEFAULT '{}'::jsonb NOT NULL,
    theme jsonb DEFAULT '{}'::jsonb NOT NULL,
    logo_data jsonb,
    banner_data jsonb,
    CONSTRAINT ensure_global_configurations_singleton CHECK (guard)
);


--
-- Name: good_job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_batches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    description text,
    serialized_properties jsonb,
    on_finish text,
    on_success text,
    on_discard text,
    callback_queue_name text,
    callback_priority integer,
    enqueued_at timestamp(6) without time zone,
    discarded_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    jobs_finished_at timestamp(6) without time zone
);


--
-- Name: good_job_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_executions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active_job_id uuid NOT NULL,
    job_class text,
    queue_name text,
    serialized_params jsonb,
    scheduled_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    error text,
    error_event smallint,
    error_backtrace text[],
    process_id uuid,
    duration interval
);


--
-- Name: good_job_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_processes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    state jsonb,
    lock_type smallint
);


--
-- Name: good_job_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key text,
    value jsonb
);


--
-- Name: good_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    queue_name text,
    priority integer,
    serialized_params jsonb,
    scheduled_at timestamp(6) without time zone,
    performed_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    error text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active_job_id uuid,
    concurrency_key text,
    cron_key text,
    retried_good_job_id uuid,
    cron_at timestamp(6) without time zone,
    batch_id uuid,
    batch_callback_id uuid,
    is_discrete boolean,
    executions_count integer,
    job_class text,
    error_event smallint,
    labels text[],
    locked_by_id uuid,
    locked_at timestamp(6) without time zone
);


--
-- Name: harvest_attempt_entity_link_transitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_attempt_entity_link_transitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_attempt_entity_link_id uuid NOT NULL,
    most_recent boolean NOT NULL,
    sort_key integer NOT NULL,
    to_state character varying NOT NULL,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_attempt_entity_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_attempt_entity_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_attempt_id uuid NOT NULL,
    harvest_entity_id uuid NOT NULL,
    harvest_record_id uuid NOT NULL,
    assets boolean DEFAULT false NOT NULL,
    upsert_duration numeric DEFAULT 0.0 NOT NULL,
    assets_duration numeric DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_attempt_entity_statuses; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.harvest_attempt_entity_statuses AS
 WITH stats AS (
         SELECT harvest_attempt_entity_links.harvest_attempt_id,
            count(DISTINCT harvest_attempt_entity_links.harvest_entity_id) AS total_entities,
            count(DISTINCT harvest_attempt_entity_links.harvest_entity_id) FILTER (WHERE harvest_attempt_entity_links.assets) AS total_entities_with_assets,
            count(DISTINCT harvest_attempt_entity_links.harvest_entity_id) FILTER (WHERE ((deets.current_state)::text <> ALL ((ARRAY['success'::character varying, 'upserted'::character varying])::text[]))) AS total_entities_waiting_for_upsert,
            count(DISTINCT harvest_attempt_entity_links.harvest_entity_id) FILTER (WHERE (harvest_attempt_entity_links.assets AND ((deets.current_state)::text <> ALL ((ARRAY['success'::character varying, 'assets_fetched'::character varying])::text[])))) AS total_entities_waiting_for_assets,
            count(DISTINCT harvest_attempt_entity_links.harvest_entity_id) FILTER (WHERE ((deets.current_state)::text = 'success'::text)) AS total_entities_success,
            jsonb_build_object('min', min(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0)), 'max', max(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0)), 'avg', avg(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0)), 'stddev', stddev_samp(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0)), 'sum', sum(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0))) AS upsert_stats,
            jsonb_build_object('min', min(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0))), 'max', max(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0))), 'avg', avg(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0))), 'stddev', stddev_samp(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0))), 'sum', sum(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0)))) AS assets_stats,
            stddev_samp(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0)) AS upsert_duration_stddev,
            stddev_samp(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0))) AS assets_duration_stddev,
            avg(harvest_attempt_entity_links.upsert_duration) FILTER (WHERE (harvest_attempt_entity_links.upsert_duration <> 0.0)) AS upsert_duration_average,
            avg(harvest_attempt_entity_links.assets_duration) FILTER (WHERE (harvest_attempt_entity_links.assets AND (harvest_attempt_entity_links.assets_duration <> 0.0))) AS assets_duration_average
           FROM ((public.harvest_attempt_entity_links
             LEFT JOIN public.harvest_attempt_entity_link_transitions mrt ON (((harvest_attempt_entity_links.id = mrt.harvest_attempt_entity_link_id) AND (mrt.most_recent = true))))
             LEFT JOIN LATERAL ( SELECT COALESCE(mrt.to_state, 'pending'::character varying) AS current_state) deets ON (true))
          GROUP BY harvest_attempt_entity_links.harvest_attempt_id
        )
 SELECT stats.harvest_attempt_id,
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
            WHEN (stats.total_entities_waiting_for_upsert > 0) THEN (CURRENT_TIMESTAMP + eta.upsert_estimate)
            ELSE NULL::timestamp with time zone
        END AS upsert_eta,
        CASE
            WHEN (stats.total_entities_waiting_for_assets > 0) THEN ((CURRENT_TIMESTAMP + eta.upsert_estimate) + eta.assets_estimate)
            ELSE NULL::timestamp with time zone
        END AS assets_eta,
    LEAST(
        CASE
            WHEN (stats.total_entities > 0) THEN ((stats.total_entities_success)::numeric / (stats.total_entities)::numeric)
            ELSE 0.0
        END, 1.0) AS completion
   FROM (stats
     LEFT JOIN LATERAL ( SELECT COALESCE(make_interval(secs => (((stats.total_entities_waiting_for_upsert)::numeric * stats.upsert_duration_average))::double precision), '00:00:00'::interval) AS upsert_estimate,
            COALESCE(make_interval(secs => (((stats.total_entities_waiting_for_assets)::numeric * stats.assets_duration_average))::double precision), '00:00:00'::interval) AS assets_estimate) eta ON (true));


--
-- Name: harvest_attempt_record_link_transitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_attempt_record_link_transitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_attempt_record_link_id uuid NOT NULL,
    most_recent boolean NOT NULL,
    sort_key integer NOT NULL,
    to_state character varying NOT NULL,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_attempt_record_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_attempt_record_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_attempt_id uuid NOT NULL,
    harvest_record_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    extraction_duration numeric DEFAULT 0.0 NOT NULL
);


--
-- Name: harvest_attempt_record_statuses; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.harvest_attempt_record_statuses AS
 WITH stats AS (
         SELECT harvest_attempt_record_links.harvest_attempt_id,
            count(DISTINCT harvest_attempt_record_links.harvest_record_id) AS total_records,
            count(DISTINCT harvest_attempt_record_links.harvest_record_id) FILTER (WHERE ((deets.current_state)::text <> ALL ((ARRAY['success'::character varying, 'upserted'::character varying, 'extracted'::character varying])::text[]))) AS total_records_waiting_for_extraction,
            count(DISTINCT harvest_attempt_record_links.harvest_record_id) FILTER (WHERE ((deets.current_state)::text <> ALL ((ARRAY['success'::character varying, 'upserted'::character varying])::text[]))) AS total_records_waiting_for_upsert,
            count(DISTINCT harvest_attempt_record_links.harvest_record_id) FILTER (WHERE ((deets.current_state)::text = 'success'::text)) AS total_records_success,
            jsonb_build_object('min', min(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0)), 'max', max(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0)), 'avg', avg(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0)), 'stddev', stddev_samp(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0)), 'sum', sum(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0))) AS extraction_stats,
            stddev_samp(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0)) AS extraction_duration_stddev,
            avg(harvest_attempt_record_links.extraction_duration) FILTER (WHERE (harvest_attempt_record_links.extraction_duration <> 0.0)) AS extraction_duration_average
           FROM ((public.harvest_attempt_record_links
             LEFT JOIN public.harvest_attempt_record_link_transitions mrt ON (((harvest_attempt_record_links.id = mrt.harvest_attempt_record_link_id) AND (mrt.most_recent = true))))
             LEFT JOIN LATERAL ( SELECT COALESCE(mrt.to_state, 'pending'::character varying) AS current_state) deets ON (true))
          GROUP BY harvest_attempt_record_links.harvest_attempt_id
        )
 SELECT stats.harvest_attempt_id,
    stats.total_records,
    stats.total_records_waiting_for_extraction,
    stats.total_records_waiting_for_upsert,
    stats.total_records_success,
    stats.extraction_stats,
    stats.extraction_duration_average,
    stats.extraction_duration_stddev,
    LEAST(
        CASE
            WHEN (stats.total_records > 0) THEN ((stats.total_records_success)::numeric / (stats.total_records)::numeric)
            ELSE 0.0
        END, 1.0) AS completion
   FROM stats;


--
-- Name: harvest_attempt_transitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_attempt_transitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_attempt_id uuid NOT NULL,
    most_recent boolean NOT NULL,
    sort_key integer NOT NULL,
    to_state character varying NOT NULL,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    harvest_set_id uuid,
    harvest_mapping_id uuid,
    mode text DEFAULT 'manual'::public.harvest_schedule_mode NOT NULL,
    description text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    record_count bigint,
    began_at timestamp without time zone,
    ended_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    metadata_format text NOT NULL,
    target_entity_type text NOT NULL,
    target_entity_id uuid NOT NULL,
    extraction_mapping_template text DEFAULT ''::text NOT NULL,
    scheduled_at timestamp without time zone,
    scheduling_key text
);


--
-- Name: harvest_cached_asset_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_cached_asset_references (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_cached_asset_id uuid NOT NULL,
    cacheable_type character varying NOT NULL,
    cacheable_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_cached_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_cached_assets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    url public.citext NOT NULL,
    fetched_at timestamp with time zone,
    touched_at timestamp with time zone,
    file_size bigint,
    file_name public.citext,
    content_type public.citext,
    signature public.citext,
    asset_data jsonb,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    harvest_mapping_id uuid,
    harvest_set_id uuid,
    harvest_attempt_id uuid,
    target_entity_type character varying NOT NULL,
    target_entity_id uuid NOT NULL,
    metadata_format public.harvest_metadata_format NOT NULL,
    list_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    read_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    format_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    mapping_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    extraction_mapping_template text DEFAULT ''::text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_contributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_contributor_id uuid NOT NULL,
    harvest_entity_id uuid NOT NULL,
    legacy_kind public.citext,
    metadata jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    role_id uuid,
    inner_position bigint,
    outer_position bigint
);


--
-- Name: harvest_contributors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_contributors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    contributor_id uuid,
    kind public.contributor_kind NOT NULL,
    identifier public.citext NOT NULL,
    email public.citext,
    prefix text,
    suffix text,
    bio text,
    url text,
    properties jsonb,
    links jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tracked_attributes text[] DEFAULT '{}'::text[] NOT NULL,
    tracked_properties text[] DEFAULT '{}'::text[] NOT NULL,
    orcid text
);


--
-- Name: harvest_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_entities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_record_id uuid NOT NULL,
    parent_id uuid,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    identifier text NOT NULL,
    metadata_kind text,
    extracted_attributes jsonb,
    extracted_properties jsonb,
    extracted_assets jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    existing_parent_type text,
    existing_parent_id uuid,
    extracted_links jsonb,
    entity_kind public.child_entity_kind NOT NULL,
    CONSTRAINT harvest_entity_exclusive_parentage CHECK (
CASE
    WHEN (existing_parent_id IS NOT NULL) THEN (parent_id IS NULL)
    WHEN (parent_id IS NOT NULL) THEN (existing_parent_id IS NULL)
    ELSE ((parent_id IS NULL) AND (existing_parent_id IS NULL))
END)
);


--
-- Name: harvest_entity_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_entity_hierarchies (
    ancestor_id uuid NOT NULL,
    descendant_id uuid NOT NULL,
    generations integer NOT NULL
);


--
-- Name: harvest_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_errors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_type character varying NOT NULL,
    source_id uuid NOT NULL,
    code text,
    message text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_mapping_record_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_mapping_record_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_mapping_id uuid NOT NULL,
    harvest_record_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_mappings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    harvest_set_id uuid,
    mode text DEFAULT 'manual'::public.harvest_schedule_mode NOT NULL,
    frequency interval,
    frequency_expression text,
    list_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    read_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    format_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    mapping_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    metadata_format text NOT NULL,
    target_entity_type text NOT NULL,
    target_entity_id uuid NOT NULL,
    extraction_mapping_template text DEFAULT ''::text NOT NULL,
    schedule_changed_at timestamp without time zone,
    last_scheduled_at timestamp without time zone,
    schedule_data jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: harvest_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid,
    harvest_attempt_id uuid,
    harvest_mapping_id uuid,
    harvest_record_id uuid,
    harvest_entity_id uuid,
    at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    level public.harvest_message_level DEFAULT 'debug'::public.harvest_message_level NOT NULL,
    message text NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_metadata_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_metadata_mappings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    target_entity_type character varying NOT NULL,
    target_entity_id uuid NOT NULL,
    field public.harvest_metadata_mapping_field NOT NULL,
    pattern public.citext NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    status public.harvest_record_status DEFAULT 'pending'::public.harvest_record_status NOT NULL,
    identifier text NOT NULL,
    metadata_format text NOT NULL,
    xml_source text,
    xml_metadata_source text,
    entity_count bigint,
    source_changed_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    local_metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    skipped jsonb DEFAULT '{"active": false}'::jsonb NOT NULL,
    harvest_configuration_id uuid,
    underlying_data_format public.underlying_data_format NOT NULL,
    json_source jsonb,
    json_metadata_source jsonb
);


--
-- Name: harvest_set_record_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_set_record_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_set_id uuid NOT NULL,
    harvest_record_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_source_id uuid NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    description text,
    raw_source text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    estimated_record_count integer,
    last_harvested_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: harvest_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.harvest_sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    protocol public.harvest_protocol DEFAULT 'unknown'::public.harvest_protocol NOT NULL,
    metadata_format text NOT NULL,
    base_url text NOT NULL,
    description text,
    list_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    read_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    format_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    mapping_options jsonb DEFAULT '{}'::jsonb NOT NULL,
    sets_refreshed_at timestamp without time zone,
    last_harvested_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    identifier public.citext NOT NULL,
    extraction_mapping_template text DEFAULT ''::text NOT NULL,
    checked_at timestamp without time zone,
    status public.harvest_source_status DEFAULT 'inactive'::public.harvest_source_status NOT NULL,
    allow_insecure boolean DEFAULT false NOT NULL
);


--
-- Name: hierarchical_schema_ranks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.hierarchical_schema_ranks AS
 SELECT hier.ancestor_type AS entity_type,
    hier.ancestor_id AS entity_id,
    hier.schema_definition_id,
    count(DISTINCT hier.schema_version_id) AS distinct_version_count,
    count(*) AS schema_count,
    mode() WITHIN GROUP (ORDER BY hier.depth) AS schema_rank
   FROM public.entity_hierarchies hier
  WHERE (hier.ancestor_id <> hier.descendant_id)
  GROUP BY hier.ancestor_type, hier.ancestor_id, hier.schema_definition_id;


--
-- Name: hierarchical_schema_version_ranks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.hierarchical_schema_version_ranks AS
 SELECT hier.ancestor_type AS entity_type,
    hier.ancestor_id AS entity_id,
    hier.schema_definition_id,
    hier.schema_version_id,
    count(*) AS schema_count,
    mode() WITHIN GROUP (ORDER BY hier.depth) AS schema_rank
   FROM public.entity_hierarchies hier
  WHERE (hier.ancestor_id <> hier.descendant_id)
  GROUP BY hier.ancestor_type, hier.ancestor_id, hier.schema_definition_id, hier.schema_version_id;


--
-- Name: ordering_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordering_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ordering_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    "position" bigint NOT NULL,
    inverse_position bigint NOT NULL,
    link_operator public.link_operator,
    auth_path public.ltree NOT NULL,
    scope public.ltree NOT NULL,
    relative_depth integer NOT NULL,
    tree_depth bigint,
    tree_parent_type character varying,
    tree_parent_id uuid,
    stale_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    order_props jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: ordering_entry_counts; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.ordering_entry_counts AS
 SELECT oe.ordering_id,
    count(*) FILTER (WHERE visibility.visible) AS visible_count,
    count(*) AS entries_count
   FROM ((public.ordering_entries oe
     LEFT JOIN public.entity_visibilities ev USING (entity_type, entity_id))
     LEFT JOIN LATERAL ( SELECT
                CASE ev.visibility
                    WHEN 'visible'::public.entity_visibility THEN true
                    WHEN 'hidden'::public.entity_visibility THEN false
                    WHEN 'limited'::public.entity_visibility THEN (ev.visibility_range @> CURRENT_TIMESTAMP)
                    ELSE false
                END AS visible) visibility ON (true))
  GROUP BY oe.ordering_id
  WITH NO DATA;


--
-- Name: initial_ordering_derivations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.initial_ordering_derivations AS
 SELECT DISTINCT ON (ord.entity_id) ord.entity_id,
    ord.entity_type,
    ord.id AS ordering_id,
    ord.identifier
   FROM (public.orderings ord
     LEFT JOIN public.ordering_entry_counts oec ON ((oec.ordering_id = ord.id)))
  WHERE ((ord.disabled_at IS NULL) AND (NOT ord.hidden))
  ORDER BY ord.entity_id, oec.visible_count DESC NULLS LAST, ord."position", ord.name, ord.identifier;


--
-- Name: initial_ordering_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.initial_ordering_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    ordering_id uuid NOT NULL,
    kind public.initial_ordering_kind NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: initial_ordering_selections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.initial_ordering_selections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    ordering_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: item_authorizations; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.item_authorizations AS
 WITH RECURSIVE collection_paths(community_id, collection_id, auth_path) AS (
         SELECT coll.community_id,
            coll.id AS collection_id,
            (comm.auth_path OPERATOR(public.||) public.text2ltree((coll.system_slug)::text)) AS auth_path
           FROM (public.collections coll
             JOIN public.communities comm ON ((comm.id = coll.community_id)))
          WHERE (coll.parent_id IS NULL)
        UNION ALL
         SELECT coll.community_id,
            coll.id AS collection_id,
            (ct.auth_path OPERATOR(public.||) public.text2ltree((coll.system_slug)::text)) AS auth_path
           FROM (public.collections coll
             JOIN collection_paths ct ON ((ct.collection_id = coll.parent_id)))
        ), item_paths(community_id, collection_id, item_id, auth_path) AS (
         SELECT coll.community_id,
            i.collection_id,
            i.id AS item_id,
            (coll.auth_path OPERATOR(public.||) public.text2ltree((i.system_slug)::text)) AS auth_path
           FROM (public.items i
             JOIN collection_paths coll USING (collection_id))
          WHERE (i.parent_id IS NULL)
        UNION ALL
         SELECT coll.community_id,
            i.collection_id,
            i.id AS item_id,
            (ip.auth_path OPERATOR(public.||) public.text2ltree((i.system_slug)::text)) AS auth_path
           FROM ((public.items i
             JOIN collection_paths coll USING (collection_id))
             JOIN item_paths ip ON ((ip.item_id = i.parent_id)))
        )
 SELECT item_paths.community_id,
    item_paths.collection_id,
    item_paths.item_id,
    item_paths.auth_path
   FROM item_paths
  WITH NO DATA;


--
-- Name: item_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_id uuid NOT NULL,
    target_id uuid NOT NULL,
    operator public.item_link_operator NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: latest_harvest_attempt_links; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.latest_harvest_attempt_links AS
 SELECT DISTINCT ON (harvest_attempts.harvest_source_id, harvest_attempts.harvest_set_id, harvest_attempts.harvest_mapping_id) harvest_attempts.harvest_source_id,
    harvest_attempts.harvest_set_id,
    harvest_attempts.harvest_mapping_id,
    harvest_attempts.id AS harvest_attempt_id
   FROM public.harvest_attempts
  ORDER BY harvest_attempts.harvest_source_id, harvest_attempts.harvest_set_id, harvest_attempts.harvest_mapping_id, harvest_attempts.created_at DESC;


--
-- Name: layout_definition_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layout_definition_hierarchies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    auth_path public.ltree DEFAULT ''::public.ltree NOT NULL,
    kind public.layout_definition_kind NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    depth integer GENERATED ALWAYS AS (public.nlevel(auth_path)) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT layout_definition_hierarchies_auth_path_sanity_check CHECK (
CASE kind
    WHEN 'root'::public.layout_definition_kind THEN (public.nlevel(auth_path) = 0)
    WHEN 'leaf'::public.layout_definition_kind THEN (public.nlevel(auth_path) > 0)
    ELSE false
END)
);


--
-- Name: layout_invalidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layout_invalidations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    stale_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sequence_id bigint NOT NULL
);


--
-- Name: layout_invalidations_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.layout_invalidations_sequence
    START WITH 9223372036854775807
    INCREMENT BY -1
    NO MINVALUE
    MAXVALUE 9223372036854775807
    CACHE 1
    CYCLE;


--
-- Name: layout_invalidations_sequence; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.layout_invalidations_sequence OWNED BY public.layout_invalidations.sequence_id;


--
-- Name: layouts_hero_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_hero_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_kind public.layout_kind DEFAULT 'hero'::public.layout_kind NOT NULL,
    root boolean GENERATED ALWAYS AS (((entity_type IS NULL) AND (entity_id IS NULL))) STORED NOT NULL,
    leaf boolean GENERATED ALWAYS AS (((entity_type IS NOT NULL) AND (entity_id IS NOT NULL))) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_hero_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_hero_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'hero'::public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_list_item_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_list_item_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_kind public.layout_kind DEFAULT 'list_item'::public.layout_kind NOT NULL,
    root boolean GENERATED ALWAYS AS (((entity_type IS NULL) AND (entity_id IS NULL))) STORED NOT NULL,
    leaf boolean GENERATED ALWAYS AS (((entity_type IS NOT NULL) AND (entity_id IS NOT NULL))) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_list_item_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_list_item_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'list_item'::public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_main_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_main_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    root boolean GENERATED ALWAYS AS (((entity_type IS NULL) AND (entity_id IS NULL))) STORED NOT NULL,
    leaf boolean GENERATED ALWAYS AS (((entity_type IS NOT NULL) AND (entity_id IS NOT NULL))) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_main_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_main_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_metadata_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_metadata_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_kind public.layout_kind DEFAULT 'metadata'::public.layout_kind NOT NULL,
    root boolean GENERATED ALWAYS AS (((entity_type IS NULL) AND (entity_id IS NULL))) STORED NOT NULL,
    leaf boolean GENERATED ALWAYS AS (((entity_type IS NOT NULL) AND (entity_id IS NOT NULL))) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_metadata_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_metadata_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'metadata'::public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_navigation_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_navigation_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_kind public.layout_kind DEFAULT 'navigation'::public.layout_kind NOT NULL,
    root boolean GENERATED ALWAYS AS (((entity_type IS NULL) AND (entity_id IS NULL))) STORED NOT NULL,
    leaf boolean GENERATED ALWAYS AS (((entity_type IS NOT NULL) AND (entity_id IS NOT NULL))) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_navigation_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_navigation_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'navigation'::public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_supplementary_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_supplementary_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying,
    entity_id uuid,
    layout_kind public.layout_kind DEFAULT 'supplementary'::public.layout_kind NOT NULL,
    root boolean GENERATED ALWAYS AS (((entity_type IS NULL) AND (entity_id IS NULL))) STORED NOT NULL,
    leaf boolean GENERATED ALWAYS AS (((entity_type IS NOT NULL) AND (entity_id IS NOT NULL))) STORED NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: layouts_supplementary_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layouts_supplementary_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'supplementary'::public.layout_kind NOT NULL,
    generation uuid NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: legacy_harvest_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_harvest_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    harvest_attempt_id uuid NOT NULL,
    identifier text NOT NULL,
    metadata_format text NOT NULL,
    raw_source text,
    raw_metadata_source text,
    local_metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    entity_count bigint,
    datestamp date,
    issued_on date,
    available_on date,
    issued_at timestamp without time zone,
    available_at timestamp without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    skipped jsonb DEFAULT '{"active": false}'::jsonb NOT NULL,
    has_been_skipped boolean GENERATED ALWAYS AS (public.record_is_skipped(skipped)) STORED NOT NULL
);


--
-- Name: link_target_candidates; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.link_target_candidates AS
 SELECT src.entity_type AS source_type,
    src.entity_id AS source_id,
    src.system_slug AS source_slug,
    target.entity_type AS target_type,
    target.entity_id AS target_id,
    target.auth_path,
    target.system_slug,
    target.depth,
    target.title,
        CASE
            WHEN (target.entity_type = 'Collection'::text) THEN target.entity_id
            ELSE NULL::uuid
        END AS collection_id,
        CASE
            WHEN (target.entity_type = 'Item'::text) THEN target.entity_id
            ELSE NULL::uuid
        END AS item_id,
    target.created_at,
    target.updated_at
   FROM ((public.entities src
     JOIN public.entities target ON (((target.entity_type = ANY (ARRAY['Collection'::text, 'Item'::text])) AND (NOT (src.auth_path OPERATOR(public.<@) target.auth_path)) AND (src.auth_path OPERATOR(public.<>) target.auth_path) AND (NOT (src.auth_path OPERATOR(public.@>) target.auth_path)))))
     LEFT JOIN public.entity_links existing_link ON (((src.entity_type = (existing_link.source_type)::text) AND (src.entity_id = existing_link.source_id) AND (target.entity_type = (existing_link.target_type)::text) AND (target.entity_id = existing_link.target_id))))
  WHERE (existing_link.id IS NULL);


--
-- Name: ordering_entry_ancestor_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordering_entry_ancestor_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ordering_id uuid NOT NULL,
    child_id uuid NOT NULL,
    ancestor_id uuid NOT NULL,
    inverse_depth bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT oeal_child_does_not_parent_itself CHECK ((child_id <> ancestor_id))
);


--
-- Name: schema_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name public.citext NOT NULL,
    identifier public.citext NOT NULL,
    kind public.schema_kind NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    namespace public.citext NOT NULL,
    declaration text GENERATED ALWAYS AS ((((namespace)::text || ':'::text) || (identifier)::text)) STORED NOT NULL
);


--
-- Name: ordering_entry_candidates; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ordering_entry_candidates AS
 SELECT ent.entity_type,
    ent.entity_id,
    ent.hierarchical_type,
    ent.hierarchical_id,
    ent.auth_path,
    ent.scope,
    ent.schema_version_id,
    ent.link_operator,
    ent.depth AS entity_depth,
    ent.title AS entity_title,
    ent.created_at AS entity_created_at,
    ent.updated_at AS entity_updated_at,
    ent.properties AS entity_properties,
    sv.namespace AS schema_namespace,
    sv.identifier AS schema_identifier,
    sv.kind AS schema_kind,
    sv.number AS schema_number,
    sv.parsed AS schema_parsed_number,
    sv.declaration AS schema_version_slug,
    sd.name AS schema_name
   FROM ((public.entities ent
     JOIN public.schema_versions sv ON ((sv.id = ent.schema_version_id)))
     JOIN public.schema_definitions sd ON ((sd.id = sv.schema_definition_id)));


--
-- Name: ordering_entry_sibling_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordering_entry_sibling_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ordering_id uuid NOT NULL,
    sibling_id uuid NOT NULL,
    prev_id uuid,
    next_id uuid,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT oesl_child_does_not_ref_itself CHECK (((sibling_id <> prev_id) AND (sibling_id <> next_id)))
);


--
-- Name: ordering_invalidations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordering_invalidations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ordering_id uuid NOT NULL,
    stale_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    title public.citext NOT NULL,
    slug public.citext NOT NULL,
    body text NOT NULL,
    hero_image_data jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    keycloak_id uuid NOT NULL,
    system_slug public.citext NOT NULL,
    email_verified boolean DEFAULT false NOT NULL,
    email public.citext NOT NULL,
    username public.citext NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    given_name text DEFAULT ''::text NOT NULL,
    family_name text DEFAULT ''::text NOT NULL,
    roles text[] DEFAULT '{}'::text[] NOT NULL,
    resource_roles jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    global_access_control_list jsonb DEFAULT '{}'::jsonb NOT NULL,
    allowed_actions public.ltree[] DEFAULT '{}'::public.ltree[] NOT NULL,
    avatar_data jsonb,
    role_priority integer GENERATED ALWAYS AS (public.user_role_priority(roles, metadata, allowed_actions)) STORED,
    search_given_name text GENERATED ALWAYS AS (public.to_prefix_search(given_name)) STORED NOT NULL,
    search_family_name text GENERATED ALWAYS AS (public.to_prefix_search(family_name)) STORED NOT NULL,
    access_management public.access_management DEFAULT 'forbidden'::public.access_management NOT NULL,
    can_manage_access_globally boolean DEFAULT false NOT NULL,
    can_manage_access_contextually boolean DEFAULT false NOT NULL
);


--
-- Name: pending_role_assignments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.pending_role_assignments AS
 SELECT 'Community'::text AS accessible_type,
    c.id AS accessible_id,
    r.id AS role_id,
    'User'::text AS subject_type,
    u.id AS subject_id
   FROM ((public.communities c
     CROSS JOIN public.users u)
     CROSS JOIN public.roles r)
  WHERE (('global_admin'::text = ANY (u.roles)) AND (r.identifier = 'admin'::public.role_identifier) AND (NOT (EXISTS ( SELECT 1
           FROM public.access_grants
          WHERE (((access_grants.accessible_type)::text = 'Community'::text) AND (access_grants.accessible_id = c.id) AND (access_grants.role_id = r.id) AND ((access_grants.subject_type)::text = 'User'::text) AND (access_grants.subject_id = u.id))))));


--
-- Name: permalinks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permalinks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    permalinkable_type character varying NOT NULL,
    permalinkable_id uuid NOT NULL,
    canonical boolean DEFAULT false NOT NULL,
    kind public.permalinkable_kind NOT NULL,
    uri public.citext NOT NULL,
    permalinkable_slug public.citext NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: pghero_query_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pghero_query_stats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    database text,
    "user" text,
    query text,
    query_hash bigint,
    total_time double precision,
    calls bigint,
    captured_at timestamp without time zone
);


--
-- Name: pghero_space_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pghero_space_stats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    database text,
    schema text,
    relation text,
    size bigint,
    captured_at timestamp without time zone
);


--
-- Name: primary_role_assignments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.primary_role_assignments AS
 SELECT DISTINCT ON (ag.subject_id, ag.subject_type, ag.role_id) ag.subject_id,
    ag.subject_type,
    ag.role_id
   FROM (( SELECT DISTINCT access_grants.subject_id,
            access_grants.subject_type,
            access_grants.role_id
           FROM public.access_grants) ag
     JOIN public.roles r ON ((r.id = ag.role_id)))
  ORDER BY ag.subject_id, ag.subject_type, ag.role_id, r.primacy, r.priority DESC, r.kind;


--
-- Name: related_collection_links; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.related_collection_links AS
 SELECT entity_links.source_id,
    entity_links.target_id,
    src.schema_version_id
   FROM ((public.entity_links
     JOIN public.collections src ON ((src.id = entity_links.source_id)))
     JOIN public.collections tgt ON (((tgt.id = entity_links.target_id) AND (tgt.schema_version_id = src.schema_version_id))))
  WHERE (((entity_links.source_type)::text = 'Collection'::text) AND ((entity_links.target_type)::text = 'Collection'::text));


--
-- Name: related_item_links; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.related_item_links AS
 SELECT entity_links.source_id,
    entity_links.target_id,
    src.schema_version_id
   FROM ((public.entity_links
     JOIN public.items src ON ((src.id = entity_links.source_id)))
     JOIN public.items tgt ON (((tgt.id = entity_links.target_id) AND (tgt.schema_version_id = src.schema_version_id))))
  WHERE (((entity_links.source_type)::text = 'Item'::text) AND ((entity_links.target_type)::text = 'Item'::text));


--
-- Name: rendering_entity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rendering_entity_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    render_duration numeric NOT NULL,
    generation uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: rendering_layout_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rendering_layout_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    render_duration numeric NOT NULL,
    generation uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: rendering_template_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rendering_template_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    template_definition_type character varying NOT NULL,
    template_definition_id uuid NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    template_kind public.template_kind NOT NULL,
    render_duration numeric NOT NULL,
    generation uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: request_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_queries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind public.request_query_kind DEFAULT 'query'::public.request_query_kind NOT NULL,
    query text NOT NULL,
    digest text NOT NULL,
    operation_name text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: request_timings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_timings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    request_query_id uuid NOT NULL,
    duration numeric NOT NULL,
    variables jsonb,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    permission_id uuid NOT NULL,
    role_id uuid NOT NULL,
    action public.ltree NOT NULL,
    inferring_actions public.ltree[] DEFAULT '{}'::public.ltree[] NOT NULL,
    inferring_scopes public.ltree[] DEFAULT '{}'::public.ltree[] NOT NULL,
    inferred boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: rollups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rollups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name public.citext NOT NULL,
    "interval" public.citext NOT NULL,
    "time" timestamp without time zone NOT NULL,
    dimensions jsonb DEFAULT '{}'::jsonb NOT NULL,
    value numeric(21,4)
);


--
-- Name: schema_version_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_version_properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schema_version_id uuid NOT NULL,
    schema_definition_id uuid NOT NULL,
    "position" integer NOT NULL,
    "array" boolean DEFAULT false NOT NULL,
    nested boolean DEFAULT false NOT NULL,
    orderable boolean DEFAULT false NOT NULL,
    required boolean DEFAULT false NOT NULL,
    kind public.schema_property_kind DEFAULT 'simple'::public.schema_property_kind NOT NULL,
    type public.schema_property_type NOT NULL,
    path text NOT NULL,
    label text NOT NULL,
    extract_path text[] NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    default_value jsonb GENERATED ALWAYS AS ((metadata -> 'default'::text)) STORED,
    function public.schema_property_function DEFAULT 'unspecified'::public.schema_property_function NOT NULL,
    searchable boolean DEFAULT false NOT NULL
);


--
-- Name: schema_definition_properties; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.schema_definition_properties AS
 WITH aggregated_versions AS (
         SELECT svp.schema_definition_id,
            svp.path,
            svp.type,
            bool_or(sv.current) AS current,
            jsonb_agg(jsonb_build_object('id', sv.id, 'number', sv.number, 'slug', sv.declaration) ORDER BY sv."position" DESC) AS versions,
            count(DISTINCT svp.schema_version_id) AS version_count,
            array_agg(DISTINCT svp.schema_version_id) AS covered_version_ids,
            min(svp.created_at) AS created_at,
            max(svp.updated_at) AS updated_at
           FROM (public.schema_version_properties svp
             JOIN public.schema_versions sv ON (((sv.id = svp.schema_version_id) AND (sv.schema_definition_id = svp.schema_definition_id))))
          GROUP BY svp.schema_definition_id, svp.path, svp.type
        ), defining_properties AS (
         SELECT DISTINCT ON (sv.schema_definition_id, svp.path, svp.type) sv.schema_definition_id,
            svp.path,
            svp.type,
            svp.kind,
            svp.label,
            svp."array",
            svp.nested,
            svp.orderable,
            svp.required,
            svp.extract_path,
            svp.metadata,
            svp.default_value
           FROM (public.schema_version_properties svp
             JOIN public.schema_versions sv ON (((sv.id = svp.schema_version_id) AND (sv.schema_definition_id = svp.schema_definition_id))))
          ORDER BY sv.schema_definition_id, svp.path, svp.type, sv.parsed DESC
        )
 SELECT dp.schema_definition_id,
    dp.path,
    dp.type,
    dp.kind,
    dp.label,
    dp."array",
    dp.nested,
    dp.orderable,
    dp.required,
    dp.extract_path,
    dp.metadata,
    dp.default_value,
    av.current,
    av.versions,
    av.covered_version_ids,
    av.version_count,
    av.created_at,
    av.updated_at
   FROM (aggregated_versions av
     JOIN defining_properties dp USING (schema_definition_id, path, type))
  WITH NO DATA;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schema_version_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_version_associations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_id uuid NOT NULL,
    target_id uuid NOT NULL,
    name public.citext NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: schema_version_orderings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.schema_version_orderings AS
 SELECT sv.id AS schema_version_id,
    (d.definition ->> 'id'::text) AS identifier,
    (d.definition ->> 'name'::text) AS name,
    public.jsonb_to_bigint((d.definition -> 'position'::text)) AS schema_position,
    d.definition_index,
    public.jsonb_to_boolean((d.definition -> 'constant'::text)) AS constant,
    public.jsonb_to_boolean((d.definition -> 'hidden'::text)) AS hidden,
    (d.definition #>> '{render,mode}'::text[]) AS render_mode,
    p.paths,
    p.paths_with_direction,
    d.definition
   FROM ((public.schema_versions sv
     CROSS JOIN LATERAL jsonb_array_elements((sv.configuration -> 'orderings'::text)) WITH ORDINALITY d(definition, definition_index))
     LEFT JOIN LATERAL ( SELECT array_agg((x.defn ->> 'path'::text) ORDER BY x."position") AS paths,
            jsonb_object_agg((x.defn ->> 'path'::text), (x.defn ->> 'direction'::text)) AS paths_with_direction
           FROM jsonb_array_elements(jsonb_path_query_array(d.definition, '$."order"[*]'::jsonpath)) WITH ORDINALITY x(defn, "position")) p ON (true));


--
-- Name: schematic_collected_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schematic_collected_references (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    referrer_type character varying NOT NULL,
    referrer_id uuid NOT NULL,
    referent_type character varying NOT NULL,
    referent_id uuid NOT NULL,
    path public.citext NOT NULL,
    "position" integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: schematic_scalar_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schematic_scalar_references (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    referrer_type character varying NOT NULL,
    referrer_id uuid NOT NULL,
    referent_type character varying NOT NULL,
    referent_id uuid NOT NULL,
    path public.citext NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: schematic_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schematic_texts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    path public.citext NOT NULL,
    lang public.citext,
    kind public.citext DEFAULT 'text'::public.citext,
    dictionary regconfig DEFAULT 'simple'::regconfig NOT NULL,
    weight public.full_text_weight DEFAULT 'D'::"char" NOT NULL,
    content text,
    text_content text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document tsvector GENERATED ALWAYS AS (setweight(to_tsvector(dictionary, text_content), (weight)::"char")) STORED,
    schema_version_property_id uuid
);


--
-- Name: stale_entities; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.stale_entities AS
 SELECT DISTINCT ON (layout_invalidations.entity_id) layout_invalidations.sequence_id AS id,
    layout_invalidations.entity_type,
    layout_invalidations.entity_id,
    layout_invalidations.stale_at,
    layout_invalidations.created_at,
    layout_invalidations.updated_at
   FROM public.layout_invalidations
  ORDER BY layout_invalidations.entity_id, layout_invalidations.stale_at DESC;


--
-- Name: templates_blurb_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_blurb_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'blurb'::public.template_kind NOT NULL,
    background public.blurb_background DEFAULT 'none'::public.blurb_background NOT NULL,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_blurb_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_blurb_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'blurb'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_contributor_list_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_contributor_list_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'contributor_list'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.contributor_list_background DEFAULT 'none'::public.contributor_list_background NOT NULL,
    "limit" integer,
    filter public.contributor_list_filter DEFAULT 'all'::public.contributor_list_filter NOT NULL,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL
);


--
-- Name: templates_contributor_list_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_contributor_list_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'contributor_list'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_descendant_list_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_descendant_list_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'descendant_list'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.descendant_list_background DEFAULT 'none'::public.descendant_list_background NOT NULL,
    variant public.descendant_list_variant DEFAULT 'cards'::public.descendant_list_variant NOT NULL,
    selection_source_mode public.selection_source_mode DEFAULT 'self'::public.selection_source_mode NOT NULL,
    selection_mode public.descendant_list_selection_mode DEFAULT 'manual'::public.descendant_list_selection_mode NOT NULL,
    selection_source text DEFAULT 'self'::text NOT NULL,
    title text,
    selection_limit integer,
    dynamic_ordering_definition jsonb,
    ordering_identifier text,
    see_all_button_label text,
    show_see_all_button boolean DEFAULT false NOT NULL,
    show_entity_context boolean DEFAULT false NOT NULL,
    manual_list_name text DEFAULT 'manual'::text NOT NULL,
    selection_source_ancestor_name text,
    selection_property_path text,
    show_hero_image boolean DEFAULT false NOT NULL,
    use_selection_fallback boolean DEFAULT false NOT NULL,
    selection_fallback_mode public.descendant_list_selection_mode DEFAULT 'manual'::public.descendant_list_selection_mode NOT NULL,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL,
    see_all_ordering_identifier text,
    show_contributors boolean DEFAULT false NOT NULL,
    show_nested_entities boolean DEFAULT false NOT NULL,
    entity_context public.list_entity_context DEFAULT 'none'::public.list_entity_context NOT NULL,
    browse_style boolean DEFAULT false NOT NULL,
    selection_unbounded boolean DEFAULT false NOT NULL
);


--
-- Name: templates_descendant_list_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_descendant_list_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'descendant_list'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    see_all_ordering_id uuid
);


--
-- Name: templates_detail_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_detail_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'detail'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.detail_background DEFAULT 'none'::public.detail_background NOT NULL,
    variant public.detail_variant DEFAULT 'summary'::public.detail_variant NOT NULL,
    show_announcements boolean DEFAULT false NOT NULL,
    show_hero_image boolean DEFAULT false NOT NULL,
    show_body boolean DEFAULT false NOT NULL,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL
);


--
-- Name: templates_detail_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_detail_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'detail'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_hero_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_hero_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'hero'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'hero'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.hero_background DEFAULT 'none'::public.hero_background NOT NULL,
    enable_descendant_browsing boolean DEFAULT false NOT NULL,
    enable_descendant_search boolean DEFAULT false NOT NULL,
    list_contributors boolean DEFAULT false NOT NULL,
    show_basic_view_metrics boolean DEFAULT false NOT NULL,
    show_big_search_prompt boolean DEFAULT false NOT NULL,
    show_breadcrumbs boolean DEFAULT false NOT NULL,
    show_doi boolean DEFAULT false NOT NULL,
    show_hero_image boolean DEFAULT false NOT NULL,
    show_issn boolean DEFAULT false NOT NULL,
    show_sharing_link boolean DEFAULT false NOT NULL,
    show_split_display boolean DEFAULT false NOT NULL,
    show_thumbnail_image boolean DEFAULT false NOT NULL,
    descendant_search_prompt text,
    hide_summary boolean DEFAULT false NOT NULL
);


--
-- Name: templates_hero_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_hero_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'hero'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'hero'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_link_list_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_link_list_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'link_list'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.link_list_background DEFAULT 'none'::public.link_list_background NOT NULL,
    variant public.link_list_variant DEFAULT 'cards'::public.link_list_variant NOT NULL,
    selection_source_mode public.selection_source_mode DEFAULT 'self'::public.selection_source_mode NOT NULL,
    selection_mode public.link_list_selection_mode DEFAULT 'manual'::public.link_list_selection_mode NOT NULL,
    selection_source text DEFAULT 'self'::text NOT NULL,
    title text,
    selection_limit integer,
    dynamic_ordering_definition jsonb,
    see_all_button_label text,
    show_see_all_button boolean DEFAULT false NOT NULL,
    show_entity_context boolean DEFAULT false NOT NULL,
    manual_list_name text DEFAULT 'manual'::text NOT NULL,
    selection_source_ancestor_name text,
    show_hero_image boolean DEFAULT false NOT NULL,
    use_selection_fallback boolean DEFAULT false NOT NULL,
    selection_fallback_mode public.link_list_selection_mode DEFAULT 'manual'::public.link_list_selection_mode NOT NULL,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL,
    see_all_ordering_identifier text,
    show_contributors boolean DEFAULT false NOT NULL,
    show_nested_entities boolean DEFAULT false NOT NULL,
    entity_context public.list_entity_context DEFAULT 'none'::public.list_entity_context NOT NULL,
    browse_style boolean DEFAULT false NOT NULL,
    selection_unbounded boolean DEFAULT false NOT NULL
);


--
-- Name: templates_link_list_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_link_list_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'link_list'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    see_all_ordering_id uuid
);


--
-- Name: templates_list_item_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_list_item_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'list_item'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'list_item'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    use_selection_fallback boolean DEFAULT false NOT NULL,
    selection_limit integer,
    selection_mode public.list_item_selection_mode DEFAULT 'manual'::public.list_item_selection_mode NOT NULL,
    selection_fallback_mode public.list_item_selection_mode DEFAULT 'manual'::public.list_item_selection_mode NOT NULL,
    selection_source_mode public.selection_source_mode DEFAULT 'self'::public.selection_source_mode NOT NULL,
    dynamic_ordering_definition jsonb,
    ordering_identifier text,
    selection_source text DEFAULT 'self'::text NOT NULL,
    manual_list_name text DEFAULT 'manual'::text NOT NULL,
    selection_source_ancestor_name text,
    selection_property_path text,
    see_all_ordering_identifier text,
    selection_unbounded boolean DEFAULT false NOT NULL
);


--
-- Name: templates_list_item_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_list_item_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'list_item'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'list_item'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    see_all_ordering_id uuid
);


--
-- Name: templates_metadata_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_metadata_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'metadata'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'metadata'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.metadata_background DEFAULT 'none'::public.metadata_background NOT NULL
);


--
-- Name: templates_metadata_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_metadata_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'metadata'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'metadata'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_navigation_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_navigation_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'navigation'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'navigation'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.navigation_background DEFAULT 'none'::public.navigation_background NOT NULL,
    hide_metadata boolean DEFAULT false NOT NULL
);


--
-- Name: templates_navigation_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_navigation_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'navigation'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'navigation'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_ordering_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_ordering_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'ordering'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.ordering_background DEFAULT 'none'::public.ordering_background NOT NULL,
    ordering_source_mode public.selection_source_mode DEFAULT 'parent'::public.selection_source_mode NOT NULL,
    ordering_source text DEFAULT 'parent'::text NOT NULL,
    ordering_source_ancestor_name text,
    selection_source_mode public.selection_source_mode DEFAULT 'self'::public.selection_source_mode NOT NULL,
    selection_source text DEFAULT 'self'::text NOT NULL,
    selection_source_ancestor_name text,
    ordering_identifier text,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL
);


--
-- Name: templates_ordering_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_ordering_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'ordering'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    ordering_id uuid,
    ordering_entry_id uuid
);


--
-- Name: templates_page_list_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_page_list_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'page_list'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.page_list_background DEFAULT 'none'::public.page_list_background NOT NULL,
    width public.template_width DEFAULT 'full'::public.template_width NOT NULL
);


--
-- Name: templates_page_list_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_page_list_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'main'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'page_list'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_supplementary_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_supplementary_definitions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'supplementary'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'supplementary'::public.template_kind NOT NULL,
    "position" bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL,
    background public.supplementary_background DEFAULT 'none'::public.supplementary_background NOT NULL
);


--
-- Name: templates_supplementary_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_supplementary_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_instance_id uuid NOT NULL,
    template_definition_id uuid NOT NULL,
    entity_type character varying NOT NULL,
    entity_id uuid NOT NULL,
    layout_kind public.layout_kind DEFAULT 'supplementary'::public.layout_kind NOT NULL,
    template_kind public.template_kind DEFAULT 'supplementary'::public.template_kind NOT NULL,
    generation uuid NOT NULL,
    "position" bigint NOT NULL,
    last_rendered_at timestamp without time zone,
    render_duration numeric,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    slots jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: templates_derived_instance_digests; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.templates_derived_instance_digests AS
 WITH digested_template_instances AS (
         SELECT templates_hero_instances.id AS template_instance_id,
            'Templates::HeroInstance'::text AS template_instance_type,
            templates_hero_instances.template_definition_id,
            'Templates::HeroDefinition'::text AS template_definition_type,
            templates_hero_instances.layout_instance_id,
            'Layouts::HeroInstance'::text AS layout_instance_type,
            layouts_hero_instances.layout_definition_id,
            'Layouts::HeroDefinition'::text AS layout_definition_type,
            templates_hero_instances.entity_id,
            templates_hero_instances.entity_type,
            templates_hero_instances."position",
            templates_hero_instances.layout_kind,
            templates_hero_instances.template_kind,
            NULL::public.template_width AS width,
            templates_hero_instances.generation,
            templates_hero_instances.config,
            (templates_hero_instances.slots || jsonb_build_object('template_kind', templates_hero_instances.template_kind)) AS slots,
            templates_hero_instances.render_duration,
            templates_hero_instances.last_rendered_at,
            templates_hero_instances.created_at,
            templates_hero_instances.updated_at
           FROM ((public.templates_hero_instances
             JOIN public.layouts_hero_instances ON ((layouts_hero_instances.id = templates_hero_instances.layout_instance_id)))
             JOIN public.templates_hero_definitions ON ((templates_hero_definitions.id = templates_hero_instances.template_definition_id)))
        UNION ALL
         SELECT templates_list_item_instances.id AS template_instance_id,
            'Templates::ListItemInstance'::text AS template_instance_type,
            templates_list_item_instances.template_definition_id,
            'Templates::ListItemDefinition'::text AS template_definition_type,
            templates_list_item_instances.layout_instance_id,
            'Layouts::ListItemInstance'::text AS layout_instance_type,
            layouts_list_item_instances.layout_definition_id,
            'Layouts::ListItemDefinition'::text AS layout_definition_type,
            templates_list_item_instances.entity_id,
            templates_list_item_instances.entity_type,
            templates_list_item_instances."position",
            templates_list_item_instances.layout_kind,
            templates_list_item_instances.template_kind,
            NULL::public.template_width AS width,
            templates_list_item_instances.generation,
            templates_list_item_instances.config,
            (templates_list_item_instances.slots || jsonb_build_object('template_kind', templates_list_item_instances.template_kind)) AS slots,
            templates_list_item_instances.render_duration,
            templates_list_item_instances.last_rendered_at,
            templates_list_item_instances.created_at,
            templates_list_item_instances.updated_at
           FROM ((public.templates_list_item_instances
             JOIN public.layouts_list_item_instances ON ((layouts_list_item_instances.id = templates_list_item_instances.layout_instance_id)))
             JOIN public.templates_list_item_definitions ON ((templates_list_item_definitions.id = templates_list_item_instances.template_definition_id)))
        UNION ALL
         SELECT templates_blurb_instances.id AS template_instance_id,
            'Templates::BlurbInstance'::text AS template_instance_type,
            templates_blurb_instances.template_definition_id,
            'Templates::BlurbDefinition'::text AS template_definition_type,
            templates_blurb_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_blurb_instances.entity_id,
            templates_blurb_instances.entity_type,
            templates_blurb_instances."position",
            templates_blurb_instances.layout_kind,
            templates_blurb_instances.template_kind,
            templates_blurb_definitions.width,
            templates_blurb_instances.generation,
            templates_blurb_instances.config,
            (templates_blurb_instances.slots || jsonb_build_object('template_kind', templates_blurb_instances.template_kind)) AS slots,
            templates_blurb_instances.render_duration,
            templates_blurb_instances.last_rendered_at,
            templates_blurb_instances.created_at,
            templates_blurb_instances.updated_at
           FROM ((public.templates_blurb_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_blurb_instances.layout_instance_id)))
             JOIN public.templates_blurb_definitions ON ((templates_blurb_definitions.id = templates_blurb_instances.template_definition_id)))
        UNION ALL
         SELECT templates_detail_instances.id AS template_instance_id,
            'Templates::DetailInstance'::text AS template_instance_type,
            templates_detail_instances.template_definition_id,
            'Templates::DetailDefinition'::text AS template_definition_type,
            templates_detail_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_detail_instances.entity_id,
            templates_detail_instances.entity_type,
            templates_detail_instances."position",
            templates_detail_instances.layout_kind,
            templates_detail_instances.template_kind,
            templates_detail_definitions.width,
            templates_detail_instances.generation,
            templates_detail_instances.config,
            (templates_detail_instances.slots || jsonb_build_object('template_kind', templates_detail_instances.template_kind)) AS slots,
            templates_detail_instances.render_duration,
            templates_detail_instances.last_rendered_at,
            templates_detail_instances.created_at,
            templates_detail_instances.updated_at
           FROM ((public.templates_detail_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_detail_instances.layout_instance_id)))
             JOIN public.templates_detail_definitions ON ((templates_detail_definitions.id = templates_detail_instances.template_definition_id)))
        UNION ALL
         SELECT templates_descendant_list_instances.id AS template_instance_id,
            'Templates::DescendantListInstance'::text AS template_instance_type,
            templates_descendant_list_instances.template_definition_id,
            'Templates::DescendantListDefinition'::text AS template_definition_type,
            templates_descendant_list_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_descendant_list_instances.entity_id,
            templates_descendant_list_instances.entity_type,
            templates_descendant_list_instances."position",
            templates_descendant_list_instances.layout_kind,
            templates_descendant_list_instances.template_kind,
            templates_descendant_list_definitions.width,
            templates_descendant_list_instances.generation,
            templates_descendant_list_instances.config,
            (templates_descendant_list_instances.slots || jsonb_build_object('template_kind', templates_descendant_list_instances.template_kind)) AS slots,
            templates_descendant_list_instances.render_duration,
            templates_descendant_list_instances.last_rendered_at,
            templates_descendant_list_instances.created_at,
            templates_descendant_list_instances.updated_at
           FROM ((public.templates_descendant_list_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_descendant_list_instances.layout_instance_id)))
             JOIN public.templates_descendant_list_definitions ON ((templates_descendant_list_definitions.id = templates_descendant_list_instances.template_definition_id)))
        UNION ALL
         SELECT templates_link_list_instances.id AS template_instance_id,
            'Templates::LinkListInstance'::text AS template_instance_type,
            templates_link_list_instances.template_definition_id,
            'Templates::LinkListDefinition'::text AS template_definition_type,
            templates_link_list_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_link_list_instances.entity_id,
            templates_link_list_instances.entity_type,
            templates_link_list_instances."position",
            templates_link_list_instances.layout_kind,
            templates_link_list_instances.template_kind,
            templates_link_list_definitions.width,
            templates_link_list_instances.generation,
            templates_link_list_instances.config,
            (templates_link_list_instances.slots || jsonb_build_object('template_kind', templates_link_list_instances.template_kind)) AS slots,
            templates_link_list_instances.render_duration,
            templates_link_list_instances.last_rendered_at,
            templates_link_list_instances.created_at,
            templates_link_list_instances.updated_at
           FROM ((public.templates_link_list_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_link_list_instances.layout_instance_id)))
             JOIN public.templates_link_list_definitions ON ((templates_link_list_definitions.id = templates_link_list_instances.template_definition_id)))
        UNION ALL
         SELECT templates_page_list_instances.id AS template_instance_id,
            'Templates::PageListInstance'::text AS template_instance_type,
            templates_page_list_instances.template_definition_id,
            'Templates::PageListDefinition'::text AS template_definition_type,
            templates_page_list_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_page_list_instances.entity_id,
            templates_page_list_instances.entity_type,
            templates_page_list_instances."position",
            templates_page_list_instances.layout_kind,
            templates_page_list_instances.template_kind,
            templates_page_list_definitions.width,
            templates_page_list_instances.generation,
            templates_page_list_instances.config,
            (templates_page_list_instances.slots || jsonb_build_object('template_kind', templates_page_list_instances.template_kind)) AS slots,
            templates_page_list_instances.render_duration,
            templates_page_list_instances.last_rendered_at,
            templates_page_list_instances.created_at,
            templates_page_list_instances.updated_at
           FROM ((public.templates_page_list_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_page_list_instances.layout_instance_id)))
             JOIN public.templates_page_list_definitions ON ((templates_page_list_definitions.id = templates_page_list_instances.template_definition_id)))
        UNION ALL
         SELECT templates_contributor_list_instances.id AS template_instance_id,
            'Templates::ContributorListInstance'::text AS template_instance_type,
            templates_contributor_list_instances.template_definition_id,
            'Templates::ContributorListDefinition'::text AS template_definition_type,
            templates_contributor_list_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_contributor_list_instances.entity_id,
            templates_contributor_list_instances.entity_type,
            templates_contributor_list_instances."position",
            templates_contributor_list_instances.layout_kind,
            templates_contributor_list_instances.template_kind,
            templates_contributor_list_definitions.width,
            templates_contributor_list_instances.generation,
            templates_contributor_list_instances.config,
            (templates_contributor_list_instances.slots || jsonb_build_object('template_kind', templates_contributor_list_instances.template_kind)) AS slots,
            templates_contributor_list_instances.render_duration,
            templates_contributor_list_instances.last_rendered_at,
            templates_contributor_list_instances.created_at,
            templates_contributor_list_instances.updated_at
           FROM ((public.templates_contributor_list_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_contributor_list_instances.layout_instance_id)))
             JOIN public.templates_contributor_list_definitions ON ((templates_contributor_list_definitions.id = templates_contributor_list_instances.template_definition_id)))
        UNION ALL
         SELECT templates_ordering_instances.id AS template_instance_id,
            'Templates::OrderingInstance'::text AS template_instance_type,
            templates_ordering_instances.template_definition_id,
            'Templates::OrderingDefinition'::text AS template_definition_type,
            templates_ordering_instances.layout_instance_id,
            'Layouts::MainInstance'::text AS layout_instance_type,
            layouts_main_instances.layout_definition_id,
            'Layouts::MainDefinition'::text AS layout_definition_type,
            templates_ordering_instances.entity_id,
            templates_ordering_instances.entity_type,
            templates_ordering_instances."position",
            templates_ordering_instances.layout_kind,
            templates_ordering_instances.template_kind,
            templates_ordering_definitions.width,
            templates_ordering_instances.generation,
            templates_ordering_instances.config,
            (templates_ordering_instances.slots || jsonb_build_object('template_kind', templates_ordering_instances.template_kind)) AS slots,
            templates_ordering_instances.render_duration,
            templates_ordering_instances.last_rendered_at,
            templates_ordering_instances.created_at,
            templates_ordering_instances.updated_at
           FROM ((public.templates_ordering_instances
             JOIN public.layouts_main_instances ON ((layouts_main_instances.id = templates_ordering_instances.layout_instance_id)))
             JOIN public.templates_ordering_definitions ON ((templates_ordering_definitions.id = templates_ordering_instances.template_definition_id)))
        UNION ALL
         SELECT templates_navigation_instances.id AS template_instance_id,
            'Templates::NavigationInstance'::text AS template_instance_type,
            templates_navigation_instances.template_definition_id,
            'Templates::NavigationDefinition'::text AS template_definition_type,
            templates_navigation_instances.layout_instance_id,
            'Layouts::NavigationInstance'::text AS layout_instance_type,
            layouts_navigation_instances.layout_definition_id,
            'Layouts::NavigationDefinition'::text AS layout_definition_type,
            templates_navigation_instances.entity_id,
            templates_navigation_instances.entity_type,
            templates_navigation_instances."position",
            templates_navigation_instances.layout_kind,
            templates_navigation_instances.template_kind,
            NULL::public.template_width AS width,
            templates_navigation_instances.generation,
            templates_navigation_instances.config,
            (templates_navigation_instances.slots || jsonb_build_object('template_kind', templates_navigation_instances.template_kind)) AS slots,
            templates_navigation_instances.render_duration,
            templates_navigation_instances.last_rendered_at,
            templates_navigation_instances.created_at,
            templates_navigation_instances.updated_at
           FROM ((public.templates_navigation_instances
             JOIN public.layouts_navigation_instances ON ((layouts_navigation_instances.id = templates_navigation_instances.layout_instance_id)))
             JOIN public.templates_navigation_definitions ON ((templates_navigation_definitions.id = templates_navigation_instances.template_definition_id)))
        UNION ALL
         SELECT templates_metadata_instances.id AS template_instance_id,
            'Templates::MetadataInstance'::text AS template_instance_type,
            templates_metadata_instances.template_definition_id,
            'Templates::MetadataDefinition'::text AS template_definition_type,
            templates_metadata_instances.layout_instance_id,
            'Layouts::MetadataInstance'::text AS layout_instance_type,
            layouts_metadata_instances.layout_definition_id,
            'Layouts::MetadataDefinition'::text AS layout_definition_type,
            templates_metadata_instances.entity_id,
            templates_metadata_instances.entity_type,
            templates_metadata_instances."position",
            templates_metadata_instances.layout_kind,
            templates_metadata_instances.template_kind,
            NULL::public.template_width AS width,
            templates_metadata_instances.generation,
            templates_metadata_instances.config,
            (templates_metadata_instances.slots || jsonb_build_object('template_kind', templates_metadata_instances.template_kind)) AS slots,
            templates_metadata_instances.render_duration,
            templates_metadata_instances.last_rendered_at,
            templates_metadata_instances.created_at,
            templates_metadata_instances.updated_at
           FROM ((public.templates_metadata_instances
             JOIN public.layouts_metadata_instances ON ((layouts_metadata_instances.id = templates_metadata_instances.layout_instance_id)))
             JOIN public.templates_metadata_definitions ON ((templates_metadata_definitions.id = templates_metadata_instances.template_definition_id)))
        UNION ALL
         SELECT templates_supplementary_instances.id AS template_instance_id,
            'Templates::SupplementaryInstance'::text AS template_instance_type,
            templates_supplementary_instances.template_definition_id,
            'Templates::SupplementaryDefinition'::text AS template_definition_type,
            templates_supplementary_instances.layout_instance_id,
            'Layouts::SupplementaryInstance'::text AS layout_instance_type,
            layouts_supplementary_instances.layout_definition_id,
            'Layouts::SupplementaryDefinition'::text AS layout_definition_type,
            templates_supplementary_instances.entity_id,
            templates_supplementary_instances.entity_type,
            templates_supplementary_instances."position",
            templates_supplementary_instances.layout_kind,
            templates_supplementary_instances.template_kind,
            NULL::public.template_width AS width,
            templates_supplementary_instances.generation,
            templates_supplementary_instances.config,
            (templates_supplementary_instances.slots || jsonb_build_object('template_kind', templates_supplementary_instances.template_kind)) AS slots,
            templates_supplementary_instances.render_duration,
            templates_supplementary_instances.last_rendered_at,
            templates_supplementary_instances.created_at,
            templates_supplementary_instances.updated_at
           FROM ((public.templates_supplementary_instances
             JOIN public.layouts_supplementary_instances ON ((layouts_supplementary_instances.id = templates_supplementary_instances.layout_instance_id)))
             JOIN public.templates_supplementary_definitions ON ((templates_supplementary_definitions.id = templates_supplementary_instances.template_definition_id)))
        )
 SELECT digested_template_instances.template_instance_id,
    digested_template_instances.template_instance_type,
    digested_template_instances.template_definition_id,
    digested_template_instances.template_definition_type,
    digested_template_instances.layout_instance_id,
    digested_template_instances.layout_instance_type,
    digested_template_instances.layout_definition_id,
    digested_template_instances.layout_definition_type,
    digested_template_instances.entity_id,
    digested_template_instances.entity_type,
    digested_template_instances."position",
    digested_template_instances.layout_kind,
    digested_template_instances.template_kind,
    digested_template_instances.width,
    digested_template_instances.generation,
    digested_template_instances.config,
    digested_template_instances.slots,
    digested_template_instances.last_rendered_at,
    digested_template_instances.render_duration,
    digested_template_instances.created_at,
    digested_template_instances.updated_at
   FROM digested_template_instances;


--
-- Name: templates_instance_siblings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.templates_instance_siblings AS
 SELECT source.template_instance_type,
    source.template_instance_id,
    sibling.template_instance_type AS sibling_instance_type,
    sibling.template_instance_id AS sibling_instance_id,
    sibling."position",
        CASE
            WHEN (sibling."position" > source."position") THEN 'next'::public.sibling_kind
            ELSE 'prev'::public.sibling_kind
        END AS kind,
    COALESCE((sibling.config @> '{"dark": true}'::jsonb), false) AS dark,
    sibling.config,
    sibling.layout_kind,
    sibling.template_kind,
    sibling.width
   FROM (public.templates_instance_digests source
     JOIN public.templates_instance_digests sibling USING (layout_instance_type, layout_instance_id))
  WHERE (source.template_instance_id <> sibling.template_instance_id);


--
-- Name: templates_manual_list_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_manual_list_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_type character varying NOT NULL,
    source_id uuid NOT NULL,
    target_type character varying NOT NULL,
    target_id uuid NOT NULL,
    template_kind public.template_kind NOT NULL,
    list_name text NOT NULL,
    "position" integer,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: templates_manual_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates_manual_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    layout_definition_type character varying NOT NULL,
    layout_definition_id uuid NOT NULL,
    template_definition_type character varying NOT NULL,
    template_definition_id uuid NOT NULL,
    layout_kind public.layout_kind NOT NULL,
    template_kind public.template_kind NOT NULL,
    list_name text NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: tuner_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tuner_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name public.citext,
    value bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: tuner_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tuner_suggestions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    report text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: user_access_infos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.user_access_infos AS
 WITH contextual_access_management AS (
         SELECT ag.subject_id AS user_id,
            ag.role_id,
            bool_or((r.allowed_actions OPERATOR(public.~) '*.manage_access'::public.lquery)) AS can_manage_access_contextually
           FROM (public.access_grants ag
             JOIN public.roles r ON ((r.id = ag.role_id)))
          WHERE ((ag.subject_type)::text = 'User'::text)
          GROUP BY ag.subject_id, ag.role_id
        )
 SELECT u.id AS user_id,
    am.can_manage_access_globally,
    am.can_manage_access_contextually,
        CASE
            WHEN am.can_manage_access_globally THEN 'global'::public.access_management
            WHEN am.can_manage_access_contextually THEN 'contextual'::public.access_management
            ELSE 'forbidden'::public.access_management
        END AS access_management
   FROM ((public.users u
     LEFT JOIN contextual_access_management cam ON ((cam.user_id = u.id)))
     LEFT JOIN LATERAL ( SELECT ('global_admin'::text = ANY (u.roles)) AS can_manage_access_globally,
            COALESCE(cam.can_manage_access_contextually, false) AS can_manage_access_contextually) am ON (true));


--
-- Name: user_group_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_group_memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    user_group_id uuid NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    keycloak_id uuid,
    system_slug public.citext NOT NULL,
    name public.citext NOT NULL,
    description public.citext NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: layout_invalidations sequence_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout_invalidations ALTER COLUMN sequence_id SET DEFAULT nextval('public.layout_invalidations_sequence'::regclass);


--
-- Name: access_grants access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT access_grants_pkey PRIMARY KEY (id);


--
-- Name: ahoy_events ahoy_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events
    ADD CONSTRAINT ahoy_events_pkey PRIMARY KEY (id);


--
-- Name: ahoy_visits ahoy_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_visits
    ADD CONSTRAINT ahoy_visits_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: collection_attributions collection_attributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_attributions
    ADD CONSTRAINT collection_attributions_pkey PRIMARY KEY (id);


--
-- Name: collection_contributions collection_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_contributions
    ADD CONSTRAINT collection_contributions_pkey PRIMARY KEY (id);


--
-- Name: collection_linked_items collection_linked_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_linked_items
    ADD CONSTRAINT collection_linked_items_pkey PRIMARY KEY (id);


--
-- Name: collection_links collection_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_links
    ADD CONSTRAINT collection_links_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: communities communities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_pkey PRIMARY KEY (id);


--
-- Name: community_memberships community_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT community_memberships_pkey PRIMARY KEY (id);


--
-- Name: contribution_role_configurations contribution_role_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contribution_role_configurations
    ADD CONSTRAINT contribution_role_configurations_pkey PRIMARY KEY (id);


--
-- Name: contributors contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT contributors_pkey PRIMARY KEY (id);


--
-- Name: controlled_vocabularies controlled_vocabularies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.controlled_vocabularies
    ADD CONSTRAINT controlled_vocabularies_pkey PRIMARY KEY (id);


--
-- Name: controlled_vocabulary_items controlled_vocabulary_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.controlled_vocabulary_items
    ADD CONSTRAINT controlled_vocabulary_items_pkey PRIMARY KEY (id);


--
-- Name: controlled_vocabulary_sources controlled_vocabulary_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.controlled_vocabulary_sources
    ADD CONSTRAINT controlled_vocabulary_sources_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: entity_composed_texts entity_composed_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_composed_texts
    ADD CONSTRAINT entity_composed_texts_pkey PRIMARY KEY (id);


--
-- Name: entity_derived_layout_definitions entity_derived_layout_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_derived_layout_definitions
    ADD CONSTRAINT entity_derived_layout_definitions_pkey PRIMARY KEY (id);


--
-- Name: entity_hierarchies entity_hierarchies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_hierarchies
    ADD CONSTRAINT entity_hierarchies_pkey PRIMARY KEY (id);


--
-- Name: entity_links entity_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT entity_links_pkey PRIMARY KEY (id);


--
-- Name: entity_orderable_properties entity_orderable_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_orderable_properties
    ADD CONSTRAINT entity_orderable_properties_pkey PRIMARY KEY (id);


--
-- Name: entity_search_documents entity_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_search_documents
    ADD CONSTRAINT entity_search_documents_pkey PRIMARY KEY (id);


--
-- Name: entity_searchable_properties entity_searchable_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_searchable_properties
    ADD CONSTRAINT entity_searchable_properties_pkey PRIMARY KEY (id);


--
-- Name: entity_visibilities entity_visibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_visibilities
    ADD CONSTRAINT entity_visibilities_pkey PRIMARY KEY (id);


--
-- Name: fake_visitors fake_visitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fake_visitors
    ADD CONSTRAINT fake_visitors_pkey PRIMARY KEY (id);


--
-- Name: frontend_revalidations frontend_revalidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frontend_revalidations
    ADD CONSTRAINT frontend_revalidations_pkey PRIMARY KEY (id);


--
-- Name: global_configurations global_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.global_configurations
    ADD CONSTRAINT global_configurations_pkey PRIMARY KEY (id);


--
-- Name: good_job_batches good_job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_batches
    ADD CONSTRAINT good_job_batches_pkey PRIMARY KEY (id);


--
-- Name: good_job_executions good_job_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_executions
    ADD CONSTRAINT good_job_executions_pkey PRIMARY KEY (id);


--
-- Name: good_job_processes good_job_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_processes
    ADD CONSTRAINT good_job_processes_pkey PRIMARY KEY (id);


--
-- Name: good_job_settings good_job_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_settings
    ADD CONSTRAINT good_job_settings_pkey PRIMARY KEY (id);


--
-- Name: good_jobs good_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_jobs
    ADD CONSTRAINT good_jobs_pkey PRIMARY KEY (id);


--
-- Name: granted_permissions granted_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.granted_permissions
    ADD CONSTRAINT granted_permissions_pkey PRIMARY KEY (id);


--
-- Name: harvest_attempt_entity_link_transitions harvest_attempt_entity_link_transitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_entity_link_transitions
    ADD CONSTRAINT harvest_attempt_entity_link_transitions_pkey PRIMARY KEY (id);


--
-- Name: harvest_attempt_entity_links harvest_attempt_entity_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_entity_links
    ADD CONSTRAINT harvest_attempt_entity_links_pkey PRIMARY KEY (id);


--
-- Name: harvest_attempt_record_link_transitions harvest_attempt_record_link_transitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_record_link_transitions
    ADD CONSTRAINT harvest_attempt_record_link_transitions_pkey PRIMARY KEY (id);


--
-- Name: harvest_attempt_record_links harvest_attempt_record_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_record_links
    ADD CONSTRAINT harvest_attempt_record_links_pkey PRIMARY KEY (id);


--
-- Name: harvest_attempt_transitions harvest_attempt_transitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_transitions
    ADD CONSTRAINT harvest_attempt_transitions_pkey PRIMARY KEY (id);


--
-- Name: harvest_attempts harvest_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempts
    ADD CONSTRAINT harvest_attempts_pkey PRIMARY KEY (id);


--
-- Name: harvest_cached_asset_references harvest_cached_asset_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_cached_asset_references
    ADD CONSTRAINT harvest_cached_asset_references_pkey PRIMARY KEY (id);


--
-- Name: harvest_cached_assets harvest_cached_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_cached_assets
    ADD CONSTRAINT harvest_cached_assets_pkey PRIMARY KEY (id);


--
-- Name: harvest_configurations harvest_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_configurations
    ADD CONSTRAINT harvest_configurations_pkey PRIMARY KEY (id);


--
-- Name: harvest_contributions harvest_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributions
    ADD CONSTRAINT harvest_contributions_pkey PRIMARY KEY (id);


--
-- Name: harvest_contributors harvest_contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributors
    ADD CONSTRAINT harvest_contributors_pkey PRIMARY KEY (id);


--
-- Name: harvest_entities harvest_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_entities
    ADD CONSTRAINT harvest_entities_pkey PRIMARY KEY (id);


--
-- Name: harvest_errors harvest_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_errors
    ADD CONSTRAINT harvest_errors_pkey PRIMARY KEY (id);


--
-- Name: harvest_mapping_record_links harvest_mapping_record_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_mapping_record_links
    ADD CONSTRAINT harvest_mapping_record_links_pkey PRIMARY KEY (id);


--
-- Name: harvest_mappings harvest_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_mappings
    ADD CONSTRAINT harvest_mappings_pkey PRIMARY KEY (id);


--
-- Name: harvest_messages harvest_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_messages
    ADD CONSTRAINT harvest_messages_pkey PRIMARY KEY (id);


--
-- Name: harvest_metadata_mappings harvest_metadata_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_metadata_mappings
    ADD CONSTRAINT harvest_metadata_mappings_pkey PRIMARY KEY (id);


--
-- Name: legacy_harvest_records harvest_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_harvest_records
    ADD CONSTRAINT harvest_records_pkey PRIMARY KEY (id);


--
-- Name: harvest_records harvest_records_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_records
    ADD CONSTRAINT harvest_records_pkey1 PRIMARY KEY (id);


--
-- Name: harvest_set_record_links harvest_set_record_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_set_record_links
    ADD CONSTRAINT harvest_set_record_links_pkey PRIMARY KEY (id);


--
-- Name: harvest_sets harvest_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_sets
    ADD CONSTRAINT harvest_sets_pkey PRIMARY KEY (id);


--
-- Name: harvest_sources harvest_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_sources
    ADD CONSTRAINT harvest_sources_pkey PRIMARY KEY (id);


--
-- Name: initial_ordering_links initial_ordering_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initial_ordering_links
    ADD CONSTRAINT initial_ordering_links_pkey PRIMARY KEY (id);


--
-- Name: initial_ordering_selections initial_ordering_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initial_ordering_selections
    ADD CONSTRAINT initial_ordering_selections_pkey PRIMARY KEY (id);


--
-- Name: item_attributions item_attributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_attributions
    ADD CONSTRAINT item_attributions_pkey PRIMARY KEY (id);


--
-- Name: item_contributions item_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_contributions
    ADD CONSTRAINT item_contributions_pkey PRIMARY KEY (id);


--
-- Name: item_links item_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_links
    ADD CONSTRAINT item_links_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: layout_definition_hierarchies layout_definition_hierarchies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout_definition_hierarchies
    ADD CONSTRAINT layout_definition_hierarchies_pkey PRIMARY KEY (id);


--
-- Name: layout_invalidations layout_invalidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout_invalidations
    ADD CONSTRAINT layout_invalidations_pkey PRIMARY KEY (id);


--
-- Name: layouts_hero_definitions layouts_hero_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_hero_definitions
    ADD CONSTRAINT layouts_hero_definitions_pkey PRIMARY KEY (id);


--
-- Name: layouts_hero_instances layouts_hero_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_hero_instances
    ADD CONSTRAINT layouts_hero_instances_pkey PRIMARY KEY (id);


--
-- Name: layouts_instance_digests layouts_instance_digests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_instance_digests
    ADD CONSTRAINT layouts_instance_digests_pkey PRIMARY KEY (id);


--
-- Name: layouts_list_item_definitions layouts_list_item_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_list_item_definitions
    ADD CONSTRAINT layouts_list_item_definitions_pkey PRIMARY KEY (id);


--
-- Name: layouts_list_item_instances layouts_list_item_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_list_item_instances
    ADD CONSTRAINT layouts_list_item_instances_pkey PRIMARY KEY (id);


--
-- Name: layouts_main_definitions layouts_main_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_main_definitions
    ADD CONSTRAINT layouts_main_definitions_pkey PRIMARY KEY (id);


--
-- Name: layouts_main_instances layouts_main_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_main_instances
    ADD CONSTRAINT layouts_main_instances_pkey PRIMARY KEY (id);


--
-- Name: layouts_metadata_definitions layouts_metadata_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_metadata_definitions
    ADD CONSTRAINT layouts_metadata_definitions_pkey PRIMARY KEY (id);


--
-- Name: layouts_metadata_instances layouts_metadata_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_metadata_instances
    ADD CONSTRAINT layouts_metadata_instances_pkey PRIMARY KEY (id);


--
-- Name: layouts_navigation_definitions layouts_navigation_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_navigation_definitions
    ADD CONSTRAINT layouts_navigation_definitions_pkey PRIMARY KEY (id);


--
-- Name: layouts_navigation_instances layouts_navigation_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_navigation_instances
    ADD CONSTRAINT layouts_navigation_instances_pkey PRIMARY KEY (id);


--
-- Name: layouts_supplementary_definitions layouts_supplementary_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_supplementary_definitions
    ADD CONSTRAINT layouts_supplementary_definitions_pkey PRIMARY KEY (id);


--
-- Name: layouts_supplementary_instances layouts_supplementary_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_supplementary_instances
    ADD CONSTRAINT layouts_supplementary_instances_pkey PRIMARY KEY (id);


--
-- Name: named_variable_dates named_variable_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.named_variable_dates
    ADD CONSTRAINT named_variable_dates_pkey PRIMARY KEY (id);


--
-- Name: ordering_entries ordering_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entries
    ADD CONSTRAINT ordering_entries_pkey PRIMARY KEY (id);


--
-- Name: ordering_entry_ancestor_links ordering_entry_ancestor_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_ancestor_links
    ADD CONSTRAINT ordering_entry_ancestor_links_pkey PRIMARY KEY (id);


--
-- Name: ordering_entry_sibling_links ordering_entry_sibling_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_sibling_links
    ADD CONSTRAINT ordering_entry_sibling_links_pkey PRIMARY KEY (id);


--
-- Name: ordering_invalidations ordering_invalidations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_invalidations
    ADD CONSTRAINT ordering_invalidations_pkey PRIMARY KEY (id);


--
-- Name: orderings orderings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderings
    ADD CONSTRAINT orderings_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: permalinks permalinks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permalinks
    ADD CONSTRAINT permalinks_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pghero_query_stats pghero_query_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pghero_query_stats
    ADD CONSTRAINT pghero_query_stats_pkey PRIMARY KEY (id);


--
-- Name: pghero_space_stats pghero_space_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pghero_space_stats
    ADD CONSTRAINT pghero_space_stats_pkey PRIMARY KEY (id);


--
-- Name: rendering_entity_logs rendering_entity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendering_entity_logs
    ADD CONSTRAINT rendering_entity_logs_pkey PRIMARY KEY (id);


--
-- Name: rendering_layout_logs rendering_layout_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendering_layout_logs
    ADD CONSTRAINT rendering_layout_logs_pkey PRIMARY KEY (id);


--
-- Name: rendering_template_logs rendering_template_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendering_template_logs
    ADD CONSTRAINT rendering_template_logs_pkey PRIMARY KEY (id);


--
-- Name: request_queries request_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_queries
    ADD CONSTRAINT request_queries_pkey PRIMARY KEY (id);


--
-- Name: request_timings request_timings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_timings
    ADD CONSTRAINT request_timings_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rollups rollups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rollups
    ADD CONSTRAINT rollups_pkey PRIMARY KEY (id);


--
-- Name: schema_definitions schema_definitions_declaration_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_definitions
    ADD CONSTRAINT schema_definitions_declaration_key UNIQUE (declaration);


--
-- Name: schema_definitions schema_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_definitions
    ADD CONSTRAINT schema_definitions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: schema_version_ancestors schema_version_ancestors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_ancestors
    ADD CONSTRAINT schema_version_ancestors_pkey PRIMARY KEY (id);


--
-- Name: schema_version_associations schema_version_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_associations
    ADD CONSTRAINT schema_version_associations_pkey PRIMARY KEY (id);


--
-- Name: schema_version_properties schema_version_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_properties
    ADD CONSTRAINT schema_version_properties_pkey PRIMARY KEY (id);


--
-- Name: schema_versions schema_versions_current; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_versions
    ADD CONSTRAINT schema_versions_current EXCLUDE USING btree (schema_definition_id WITH =) WHERE (current) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: schema_versions schema_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_versions
    ADD CONSTRAINT schema_versions_pkey PRIMARY KEY (id);


--
-- Name: schematic_collected_references schematic_collected_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schematic_collected_references
    ADD CONSTRAINT schematic_collected_references_pkey PRIMARY KEY (id);


--
-- Name: schematic_scalar_references schematic_scalar_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schematic_scalar_references
    ADD CONSTRAINT schematic_scalar_references_pkey PRIMARY KEY (id);


--
-- Name: schematic_texts schematic_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schematic_texts
    ADD CONSTRAINT schematic_texts_pkey PRIMARY KEY (id);


--
-- Name: templates_blurb_definitions templates_blurb_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_blurb_definitions
    ADD CONSTRAINT templates_blurb_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_blurb_instances templates_blurb_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_blurb_instances
    ADD CONSTRAINT templates_blurb_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_contributor_list_definitions templates_contributor_list_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_contributor_list_definitions
    ADD CONSTRAINT templates_contributor_list_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_contributor_list_instances templates_contributor_list_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_contributor_list_instances
    ADD CONSTRAINT templates_contributor_list_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_definition_digests templates_definition_digests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_definition_digests
    ADD CONSTRAINT templates_definition_digests_pkey PRIMARY KEY (id);


--
-- Name: templates_descendant_list_definitions templates_descendant_list_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_descendant_list_definitions
    ADD CONSTRAINT templates_descendant_list_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_descendant_list_instances templates_descendant_list_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_descendant_list_instances
    ADD CONSTRAINT templates_descendant_list_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_detail_definitions templates_detail_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_detail_definitions
    ADD CONSTRAINT templates_detail_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_detail_instances templates_detail_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_detail_instances
    ADD CONSTRAINT templates_detail_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_hero_definitions templates_hero_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_hero_definitions
    ADD CONSTRAINT templates_hero_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_hero_instances templates_hero_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_hero_instances
    ADD CONSTRAINT templates_hero_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_instance_digests templates_instance_digests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_instance_digests
    ADD CONSTRAINT templates_instance_digests_pkey PRIMARY KEY (id);


--
-- Name: templates_link_list_definitions templates_link_list_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_link_list_definitions
    ADD CONSTRAINT templates_link_list_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_link_list_instances templates_link_list_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_link_list_instances
    ADD CONSTRAINT templates_link_list_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_list_item_definitions templates_list_item_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_list_item_definitions
    ADD CONSTRAINT templates_list_item_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_list_item_instances templates_list_item_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_list_item_instances
    ADD CONSTRAINT templates_list_item_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_manual_list_entries templates_manual_list_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_manual_list_entries
    ADD CONSTRAINT templates_manual_list_entries_pkey PRIMARY KEY (id);


--
-- Name: templates_manual_lists templates_manual_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_manual_lists
    ADD CONSTRAINT templates_manual_lists_pkey PRIMARY KEY (id);


--
-- Name: templates_metadata_definitions templates_metadata_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_metadata_definitions
    ADD CONSTRAINT templates_metadata_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_metadata_instances templates_metadata_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_metadata_instances
    ADD CONSTRAINT templates_metadata_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_navigation_definitions templates_navigation_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_navigation_definitions
    ADD CONSTRAINT templates_navigation_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_navigation_instances templates_navigation_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_navigation_instances
    ADD CONSTRAINT templates_navigation_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_ordering_definitions templates_ordering_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_definitions
    ADD CONSTRAINT templates_ordering_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_ordering_instances templates_ordering_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_instances
    ADD CONSTRAINT templates_ordering_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_page_list_definitions templates_page_list_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_page_list_definitions
    ADD CONSTRAINT templates_page_list_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_page_list_instances templates_page_list_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_page_list_instances
    ADD CONSTRAINT templates_page_list_instances_pkey PRIMARY KEY (id);


--
-- Name: templates_supplementary_definitions templates_supplementary_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_supplementary_definitions
    ADD CONSTRAINT templates_supplementary_definitions_pkey PRIMARY KEY (id);


--
-- Name: templates_supplementary_instances templates_supplementary_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_supplementary_instances
    ADD CONSTRAINT templates_supplementary_instances_pkey PRIMARY KEY (id);


--
-- Name: tuner_metrics tuner_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tuner_metrics
    ADD CONSTRAINT tuner_metrics_pkey PRIMARY KEY (id);


--
-- Name: tuner_suggestions tuner_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tuner_suggestions
    ADD CONSTRAINT tuner_suggestions_pkey PRIMARY KEY (id);


--
-- Name: user_group_memberships user_group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_memberships
    ADD CONSTRAINT user_group_memberships_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: asset_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX asset_anc_desc_idx ON public.asset_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: asset_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX asset_desc_idx ON public.asset_hierarchies USING btree (descendant_id);


--
-- Name: assignable_role_targets_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assignable_role_targets_pkey ON public.assignable_role_targets USING btree (source_role_id, target_role_id);


--
-- Name: authorizing_entities_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX authorizing_entities_pkey ON public.authorizing_entities USING btree (auth_path, entity_id, scope, hierarchical_type, hierarchical_id);


--
-- Name: collection_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX collection_anc_desc_idx ON public.collection_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: collection_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collection_desc_idx ON public.collection_hierarchies USING btree (descendant_id);


--
-- Name: controlled_vocabulary_item_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX controlled_vocabulary_item_anc_desc_idx ON public.controlled_vocabulary_item_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: controlled_vocabulary_item_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX controlled_vocabulary_item_desc_idx ON public.controlled_vocabulary_item_hierarchies USING btree (descendant_id);


--
-- Name: entity_cached_ancestors_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX entity_cached_ancestors_pkey ON public.entity_cached_ancestors USING btree (entity_type, entity_id, name) INCLUDE (ancestor_type, ancestor_id);


--
-- Name: harvest_attempts_scheduling_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX harvest_attempts_scheduling_uniqueness ON public.harvest_attempts USING btree (harvest_mapping_id, scheduling_key) WHERE ((mode = 'scheduled'::text) AND (harvest_mapping_id IS NOT NULL) AND (scheduling_key IS NOT NULL));


--
-- Name: harvest_contributions_sans_role_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX harvest_contributions_sans_role_uniqueness ON public.harvest_contributions USING btree (harvest_contributor_id, harvest_entity_id) WHERE (role_id IS NULL);


--
-- Name: harvest_contributions_with_role_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX harvest_contributions_with_role_uniqueness ON public.harvest_contributions USING btree (harvest_contributor_id, harvest_entity_id, role_id) WHERE (role_id IS NOT NULL);


--
-- Name: harvest_entity_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX harvest_entity_anc_desc_idx ON public.harvest_entity_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: harvest_entity_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX harvest_entity_desc_idx ON public.harvest_entity_hierarchies USING btree (descendant_id);


--
-- Name: idx_layouts_hero_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_layouts_hero_instances_defn ON public.layouts_hero_instances USING btree (layout_definition_id);


--
-- Name: idx_layouts_list_item_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_layouts_list_item_instances_defn ON public.layouts_list_item_instances USING btree (layout_definition_id);


--
-- Name: idx_layouts_main_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_layouts_main_instances_defn ON public.layouts_main_instances USING btree (layout_definition_id);


--
-- Name: idx_layouts_metadata_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_layouts_metadata_instances_defn ON public.layouts_metadata_instances USING btree (layout_definition_id);


--
-- Name: idx_layouts_navigation_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_layouts_navigation_instances_defn ON public.layouts_navigation_instances USING btree (layout_definition_id);


--
-- Name: idx_layouts_supplementary_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_layouts_supplementary_instances_defn ON public.layouts_supplementary_instances USING btree (layout_definition_id);


--
-- Name: idx_templates_blurb_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_blurb_definitions_layout ON public.templates_blurb_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_blurb_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_blurb_instances_defn ON public.templates_blurb_instances USING btree (template_definition_id);


--
-- Name: idx_templates_blurb_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_blurb_instances_layout ON public.templates_blurb_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_contributor_list_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_contributor_list_definitions_layout ON public.templates_contributor_list_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_contributor_list_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_contributor_list_instances_defn ON public.templates_contributor_list_instances USING btree (template_definition_id);


--
-- Name: idx_templates_contributor_list_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_contributor_list_instances_layout ON public.templates_contributor_list_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_descendant_list_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_descendant_list_definitions_layout ON public.templates_descendant_list_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_descendant_list_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_descendant_list_instances_defn ON public.templates_descendant_list_instances USING btree (template_definition_id);


--
-- Name: idx_templates_descendant_list_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_descendant_list_instances_layout ON public.templates_descendant_list_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_detail_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_detail_definitions_layout ON public.templates_detail_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_detail_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_detail_instances_defn ON public.templates_detail_instances USING btree (template_definition_id);


--
-- Name: idx_templates_detail_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_detail_instances_layout ON public.templates_detail_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_hero_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_hero_definitions_layout ON public.templates_hero_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_hero_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_hero_instances_defn ON public.templates_hero_instances USING btree (template_definition_id);


--
-- Name: idx_templates_hero_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_hero_instances_layout ON public.templates_hero_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_instance_digest_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digest_entity ON public.templates_instance_digests USING btree (entity_type, entity_id);


--
-- Name: idx_templates_instance_digests_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digests_layout_definition ON public.templates_instance_digests USING btree (layout_definition_type, layout_definition_id);


--
-- Name: idx_templates_instance_digests_layout_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digests_layout_instance ON public.templates_instance_digests USING btree (layout_instance_type, layout_instance_id);


--
-- Name: idx_templates_instance_digests_rendered_by_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digests_rendered_by_entity ON public.templates_instance_digests USING btree (last_rendered_at, entity_type, entity_id);


--
-- Name: idx_templates_instance_digests_rendering_by_template; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digests_rendering_by_template ON public.templates_instance_digests USING btree (template_kind, render_duration);


--
-- Name: idx_templates_instance_digests_siblings; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digests_siblings ON public.templates_instance_digests USING btree (template_instance_type, template_instance_id, layout_instance_type, layout_instance_id, "position") INCLUDE (config, layout_kind, template_kind, width);


--
-- Name: idx_templates_instance_digests_template_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_instance_digests_template_definition ON public.templates_instance_digests USING btree (template_definition_type, template_definition_id);


--
-- Name: idx_templates_instance_digests_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_templates_instance_digests_uniqueness ON public.templates_instance_digests USING btree (template_instance_type, template_instance_id);


--
-- Name: idx_templates_link_list_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_link_list_definitions_layout ON public.templates_link_list_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_link_list_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_link_list_instances_defn ON public.templates_link_list_instances USING btree (template_definition_id);


--
-- Name: idx_templates_link_list_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_link_list_instances_layout ON public.templates_link_list_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_list_item_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_list_item_definitions_layout ON public.templates_list_item_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_list_item_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_list_item_instances_defn ON public.templates_list_item_instances USING btree (template_definition_id);


--
-- Name: idx_templates_list_item_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_list_item_instances_layout ON public.templates_list_item_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_metadata_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_metadata_definitions_layout ON public.templates_metadata_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_metadata_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_metadata_instances_defn ON public.templates_metadata_instances USING btree (template_definition_id);


--
-- Name: idx_templates_metadata_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_metadata_instances_layout ON public.templates_metadata_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_navigation_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_navigation_definitions_layout ON public.templates_navigation_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_navigation_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_navigation_instances_defn ON public.templates_navigation_instances USING btree (template_definition_id);


--
-- Name: idx_templates_navigation_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_navigation_instances_layout ON public.templates_navigation_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_ordering_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_ordering_definitions_layout ON public.templates_ordering_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_ordering_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_ordering_instances_defn ON public.templates_ordering_instances USING btree (template_definition_id);


--
-- Name: idx_templates_ordering_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_ordering_instances_layout ON public.templates_ordering_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_page_list_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_page_list_definitions_layout ON public.templates_page_list_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_page_list_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_page_list_instances_defn ON public.templates_page_list_instances USING btree (template_definition_id);


--
-- Name: idx_templates_page_list_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_page_list_instances_layout ON public.templates_page_list_instances USING btree (layout_instance_id);


--
-- Name: idx_templates_supplementary_definitions_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_supplementary_definitions_layout ON public.templates_supplementary_definitions USING btree (layout_definition_id);


--
-- Name: idx_templates_supplementary_instances_defn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_supplementary_instances_defn ON public.templates_supplementary_instances USING btree (template_definition_id);


--
-- Name: idx_templates_supplementary_instances_layout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_templates_supplementary_instances_layout ON public.templates_supplementary_instances USING btree (layout_instance_id);


--
-- Name: index_access_grants_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_auth_path ON public.access_grants USING gist (auth_path);


--
-- Name: index_access_grants_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_collection_id ON public.access_grants USING btree (collection_id);


--
-- Name: index_access_grants_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_community_id ON public.access_grants USING btree (community_id);


--
-- Name: index_access_grants_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_item_id ON public.access_grants USING btree (item_id);


--
-- Name: index_access_grants_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_role_id ON public.access_grants USING btree (role_id);


--
-- Name: index_access_grants_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_subject ON public.access_grants USING btree (subject_type, subject_id);


--
-- Name: index_access_grants_on_user_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_user_group_id ON public.access_grants USING btree (user_group_id);


--
-- Name: index_access_grants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_on_user_id ON public.access_grants USING btree (user_id);


--
-- Name: index_access_grants_role_check; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_grants_role_check ON public.access_grants USING btree (accessible_type, accessible_id, role_id, subject_type, subject_id);


--
-- Name: index_access_grants_subject_roles; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_grants_subject_roles ON public.access_grants USING btree (subject_id, subject_type, role_id);


--
-- Name: index_access_grants_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_grants_uniqueness ON public.access_grants USING btree (accessible_type, accessible_id, subject_type, subject_id);


--
-- Name: index_ahoy_events_asset_downloads_aggregation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_asset_downloads_aggregation ON public.ahoy_events USING btree ("time", visit_id, entity_id, subject_id) WHERE ((context = 'frontend'::public.analytics_context) AND (name OPERATOR(public.=) 'asset.download'::public.citext));


--
-- Name: index_ahoy_events_entity_views_aggregation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_entity_views_aggregation ON public.ahoy_events USING btree ("time", visit_id, entity_id, subject_id) WHERE ((context = 'frontend'::public.analytics_context) AND (name OPERATOR(public.=) 'entity.view'::public.citext));


--
-- Name: index_ahoy_events_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_entity ON public.ahoy_events USING btree (entity_type, entity_id);


--
-- Name: index_ahoy_events_on_name_and_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_name_and_time ON public.ahoy_events USING btree (name, "time");


--
-- Name: index_ahoy_events_on_properties; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_properties ON public.ahoy_events USING gin (properties jsonb_path_ops);


--
-- Name: index_ahoy_events_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_subject ON public.ahoy_events USING btree (subject_type, subject_id);


--
-- Name: index_ahoy_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_user_id ON public.ahoy_events USING btree (user_id);


--
-- Name: index_ahoy_events_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_visit_id ON public.ahoy_events USING btree (visit_id);


--
-- Name: index_ahoy_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_visits_on_user_id ON public.ahoy_visits USING btree (user_id);


--
-- Name: index_ahoy_visits_on_visit_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ahoy_visits_on_visit_token ON public.ahoy_visits USING btree (visit_token);


--
-- Name: index_ahoy_visits_on_visitor_token_and_started_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_visits_on_visitor_token_and_started_at ON public.ahoy_visits USING btree (visitor_token, started_at);


--
-- Name: index_announcements_oldest_by_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_announcements_oldest_by_entity ON public.announcements USING btree (entity_id, entity_type, published_on);


--
-- Name: index_announcements_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_announcements_on_entity ON public.announcements USING btree (entity_type, entity_id);


--
-- Name: index_announcements_recent_by_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_announcements_recent_by_entity ON public.announcements USING btree (entity_id, entity_type, published_on DESC);


--
-- Name: index_assets_on_attachable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_attachable ON public.assets USING btree (attachable_type, attachable_id);


--
-- Name: index_assets_on_attachable_id_and_attachable_type_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_attachable_id_and_attachable_type_and_position ON public.assets USING btree (attachable_id, attachable_type, "position");


--
-- Name: index_assets_on_attachment_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_attachment_data ON public.assets USING gin (attachment_data);


--
-- Name: index_assets_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_collection_id ON public.assets USING btree (collection_id);


--
-- Name: index_assets_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_community_id ON public.assets USING btree (community_id);


--
-- Name: index_assets_on_file_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_file_size ON public.assets USING btree (file_size);


--
-- Name: index_assets_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_item_id ON public.assets USING btree (item_id);


--
-- Name: index_assets_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_kind ON public.assets USING btree (kind);


--
-- Name: index_assets_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_name ON public.assets USING btree (name);


--
-- Name: index_assets_on_parent_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_parent_id_and_position ON public.assets USING btree (parent_id, "position");


--
-- Name: index_assets_on_preview_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_preview_data ON public.assets USING gin (preview_data);


--
-- Name: index_assets_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assets_uniqueness ON public.assets USING btree (attachable_type, attachable_id, identifier) WHERE (identifier IS NOT NULL);


--
-- Name: index_assignable_role_targets_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignable_role_targets_ordering ON public.assignable_role_targets USING btree (source_role_id, priority, target_role_id);


--
-- Name: index_authorizing_entities_for_collections; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_for_collections ON public.authorizing_entities USING btree (hierarchical_id, hierarchical_type, auth_path, scope) WHERE (hierarchical_type = 'Collection'::text);


--
-- Name: index_authorizing_entities_for_items; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_for_items ON public.authorizing_entities USING btree (hierarchical_id, hierarchical_type, auth_path, scope) WHERE (hierarchical_type = 'Item'::text);


--
-- Name: index_authorizing_entities_for_single_join; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_for_single_join ON public.authorizing_entities USING btree (scope, auth_path, hierarchical_id, hierarchical_type);


--
-- Name: index_authorizing_entities_match_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_match_scope ON public.authorizing_entities USING btree (hierarchical_id, hierarchical_type, auth_path, scope);


--
-- Name: index_authorizing_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_on_entity_id ON public.authorizing_entities USING btree (entity_id);


--
-- Name: index_authorizing_entities_on_hierarchical; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_on_hierarchical ON public.authorizing_entities USING btree (hierarchical_type, hierarchical_id);


--
-- Name: index_authorizing_entities_single_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizing_entities_single_user ON public.authorizing_entities USING btree (auth_path, scope) INCLUDE (hierarchical_id, hierarchical_type);


--
-- Name: index_collection_attributions_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_attributions_ordering ON public.collection_attributions USING btree (collection_id, "position");


--
-- Name: index_collection_attributions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_attributions_uniqueness ON public.collection_attributions USING btree (collection_id, contributor_id);


--
-- Name: index_collection_authorizations_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_authorizations_on_auth_path ON public.collection_authorizations USING gist (auth_path);


--
-- Name: index_collection_authorizations_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_authorizations_on_collection_id ON public.collection_authorizations USING btree (collection_id);


--
-- Name: index_collection_authorizations_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_authorizations_on_community_id ON public.collection_authorizations USING btree (community_id);


--
-- Name: index_collection_contributions_assigned_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_contributions_assigned_uniqueness ON public.collection_contributions USING btree (contributor_id, collection_id, role_id);


--
-- Name: index_collection_contributions_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_contributions_on_collection_id ON public.collection_contributions USING btree (collection_id);


--
-- Name: index_collection_contributions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_contributions_on_role_id ON public.collection_contributions USING btree (role_id);


--
-- Name: index_collection_linked_items_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_linked_items_on_target_id ON public.collection_linked_items USING btree (target_id);


--
-- Name: index_collection_linked_items_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_linked_items_uniqueness ON public.collection_linked_items USING btree (source_id, target_id);


--
-- Name: index_collection_links_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_links_on_target_id ON public.collection_links USING btree (target_id);


--
-- Name: index_collection_links_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_links_uniqueness ON public.collection_links USING btree (source_id, target_id);


--
-- Name: index_collections_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_auth_path ON public.collections USING gist (auth_path);


--
-- Name: index_collections_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_community_id ON public.collections USING btree (community_id);


--
-- Name: index_collections_on_doi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_doi ON public.collections USING btree (doi);


--
-- Name: index_collections_on_has_doi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_has_doi ON public.collections USING btree (has_doi);


--
-- Name: index_collections_on_issn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_issn ON public.collections USING btree (issn);


--
-- Name: index_collections_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_parent_id ON public.collections USING btree (parent_id);


--
-- Name: index_collections_on_properties; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_properties ON public.collections USING gin (properties);


--
-- Name: index_collections_on_raw_doi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_raw_doi ON public.collections USING btree (raw_doi);


--
-- Name: index_collections_on_schema_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_schema_definition_id ON public.collections USING btree (schema_definition_id);


--
-- Name: index_collections_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_schema_version_id ON public.collections USING btree (schema_version_id);


--
-- Name: index_collections_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_system_slug ON public.collections USING btree (system_slug);


--
-- Name: index_collections_unique_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_unique_identifier ON public.collections USING btree (identifier, community_id, parent_id);


--
-- Name: index_collections_versioned_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_versioned_ids ON public.collections USING btree (id, schema_version_id);


--
-- Name: index_communities_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communities_on_auth_path ON public.communities USING gist (auth_path);


--
-- Name: index_communities_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_communities_on_identifier ON public.communities USING btree (identifier);


--
-- Name: index_communities_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communities_on_position ON public.communities USING btree ("position");


--
-- Name: index_communities_on_schema_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communities_on_schema_definition_id ON public.communities USING btree (schema_definition_id);


--
-- Name: index_communities_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communities_on_schema_version_id ON public.communities USING btree (schema_version_id);


--
-- Name: index_communities_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_communities_on_system_slug ON public.communities USING btree (system_slug);


--
-- Name: index_communities_versioned_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_communities_versioned_ids ON public.communities USING btree (id, schema_version_id);


--
-- Name: index_community_memberships_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_community_memberships_on_role_id ON public.community_memberships USING btree (role_id);


--
-- Name: index_community_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_community_memberships_on_user_id ON public.community_memberships USING btree (user_id);


--
-- Name: index_community_memberships_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_community_memberships_uniqueness ON public.community_memberships USING btree (community_id, user_id);


--
-- Name: index_contribution_role_configurations_on_default_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contribution_role_configurations_on_default_item_id ON public.contribution_role_configurations USING btree (default_item_id);


--
-- Name: index_contribution_role_configurations_on_other_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contribution_role_configurations_on_other_item_id ON public.contribution_role_configurations USING btree (other_item_id);


--
-- Name: index_contribution_role_configurations_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contribution_role_configurations_on_source ON public.contribution_role_configurations USING btree (source_type, source_id);


--
-- Name: index_contribution_role_configurations_vocabulary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contribution_role_configurations_vocabulary ON public.contribution_role_configurations USING btree (controlled_vocabulary_id);


--
-- Name: index_contributor_attributions_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributor_attributions_entity ON public.contributor_attributions USING btree (entity_type, entity_id);


--
-- Name: index_contributor_attributions_on_attribution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contributor_attributions_on_attribution_id ON public.contributor_attributions USING btree (attribution_id);


--
-- Name: index_contributor_attributions_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributor_attributions_on_item_id ON public.contributor_attributions USING btree (item_id);


--
-- Name: index_contributor_attributions_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributor_attributions_source ON public.contributor_attributions USING btree (attribution_type, attribution_id);


--
-- Name: index_contributor_published_ranking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributor_published_ranking ON public.contributor_attributions USING btree (contributor_id, published_rank);


--
-- Name: index_contributor_title_ranking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributor_title_ranking ON public.contributor_attributions USING btree (contributor_id, title_rank);


--
-- Name: index_contributors_on_affiliation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_affiliation ON public.contributors USING btree (affiliation);


--
-- Name: index_contributors_on_contribution_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_contribution_count ON public.contributors USING btree (contribution_count);


--
-- Name: index_contributors_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contributors_on_identifier ON public.contributors USING btree (identifier);


--
-- Name: index_contributors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_name ON public.contributors USING btree (name);


--
-- Name: index_contributors_on_orcid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_orcid ON public.contributors USING btree (orcid);


--
-- Name: index_contributors_on_properties; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_properties ON public.contributors USING gin (properties);


--
-- Name: index_contributors_on_sort_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_on_sort_name ON public.contributors USING btree (sort_name);


--
-- Name: index_contributors_prefix_searching_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contributors_prefix_searching_names ON public.contributors USING gin (search_name public.gin_trgm_ops);


--
-- Name: index_controlled_vocabularies_on_provides; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_controlled_vocabularies_on_provides ON public.controlled_vocabularies USING btree (provides);


--
-- Name: index_controlled_vocabularies_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_controlled_vocabularies_uniqueness ON public.controlled_vocabularies USING btree (namespace, identifier, version);


--
-- Name: index_controlled_vocabulary_items_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_controlled_vocabulary_items_on_parent_id ON public.controlled_vocabulary_items USING btree (parent_id);


--
-- Name: index_controlled_vocabulary_items_on_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_controlled_vocabulary_items_on_tags ON public.controlled_vocabulary_items USING gin (tags);


--
-- Name: index_controlled_vocabulary_items_ranking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_controlled_vocabulary_items_ranking ON public.controlled_vocabulary_items USING btree (parent_id, ranking, "position");


--
-- Name: index_controlled_vocabulary_items_sort_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_controlled_vocabulary_items_sort_order ON public.controlled_vocabulary_items USING btree (priority DESC, "position", identifier);


--
-- Name: index_controlled_vocabulary_items_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_controlled_vocabulary_items_uniqueness ON public.controlled_vocabulary_items USING btree (controlled_vocabulary_id, identifier);


--
-- Name: index_controlled_vocabulary_sources_on_controlled_vocabulary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_controlled_vocabulary_sources_on_controlled_vocabulary_id ON public.controlled_vocabulary_sources USING btree (controlled_vocabulary_id);


--
-- Name: index_controlled_vocabulary_sources_on_provides; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_controlled_vocabulary_sources_on_provides ON public.controlled_vocabulary_sources USING btree (provides);


--
-- Name: index_edld_check; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edld_check ON public.entity_derived_layout_definitions USING btree (layout_definition_type, layout_definition_id, entity_type, entity_id, layout_kind);


--
-- Name: index_entities_check; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_check ON public.entities USING gist (auth_path, schema_version_id, entity_type, entity_id) WHERE "real";


--
-- Name: index_entities_crumb_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_crumb_source ON public.entities USING gist (depth, auth_path, entity_id, entity_type, system_slug);


--
-- Name: index_entities_for_descendant_parents; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_for_descendant_parents ON public.entities USING gist (auth_path public.gist_ltree_ops (siglen='1024'), entity_id, entity_type, depth) WHERE (link_operator IS NULL);


--
-- Name: index_entities_for_named_ancestor_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_for_named_ancestor_lookup ON public.entities USING btree (depth DESC, schema_version_id, entity_id) INCLUDE (entity_type, auth_path);


--
-- Name: index_entities_hierarchical_permission_matching; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_hierarchical_permission_matching ON public.entities USING btree (hierarchical_id, hierarchical_type) INCLUDE (auth_path, scope);


--
-- Name: index_entities_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_auth_path ON public.entities USING gist (auth_path public.gist_ltree_ops (siglen='1024'));


--
-- Name: index_entities_on_auth_path_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_auth_path_uniqueness ON public.entities USING btree (auth_path);


--
-- Name: index_entities_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_entity ON public.entities USING btree (entity_type, entity_id);


--
-- Name: index_entities_on_hierarchical; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_hierarchical ON public.entities USING btree (hierarchical_type, hierarchical_id);


--
-- Name: index_entities_on_link_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_link_operator ON public.entities USING btree (link_operator);


--
-- Name: index_entities_on_properties; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_properties ON public.entities USING gin (properties jsonb_path_ops);


--
-- Name: index_entities_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_schema_version_id ON public.entities USING btree (schema_version_id);


--
-- Name: index_entities_on_search_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_search_title ON public.entities USING gin (search_title public.gin_trgm_ops);


--
-- Name: index_entities_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_system_slug ON public.entities USING btree (system_slug);


--
-- Name: index_entities_permissions_calculation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_permissions_calculation ON public.entities USING gist (hierarchical_type, hierarchical_id, auth_path, scope);


--
-- Name: index_entities_real; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_real ON public.entities USING btree (entity_id, entity_type, schema_version_id) WHERE (link_operator IS NULL);


--
-- Name: index_entities_schematic_descendant_querying; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_schematic_descendant_querying ON public.entities USING gist (auth_path, schema_version_id, link_operator);


--
-- Name: index_entities_staleness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_staleness ON public.entities USING btree (stale);


--
-- Name: index_entity_author_contributions_ranking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_author_contributions_ranking ON public.entity_author_contributions USING btree (entity_id, ranking);


--
-- Name: index_entity_author_contributions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_author_contributions_uniqueness ON public.entity_author_contributions USING btree (entity_id, contributor_id);


--
-- Name: index_entity_composed_texts_on_document; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_composed_texts_on_document ON public.entity_composed_texts USING gist (document);


--
-- Name: index_entity_composed_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_composed_texts_uniqueness ON public.entity_composed_texts USING btree (entity_type, entity_id);


--
-- Name: index_entity_derived_layout_definitions_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_derived_layout_definitions_on_entity ON public.entity_derived_layout_definitions USING btree (entity_type, entity_id);


--
-- Name: index_entity_derived_layout_definitions_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_derived_layout_definitions_on_layout_definition ON public.entity_derived_layout_definitions USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_entity_derived_layout_definitions_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_derived_layout_definitions_on_schema_version_id ON public.entity_derived_layout_definitions USING btree (schema_version_id);


--
-- Name: index_entity_hierarchies_by_descendant_title_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_by_descendant_title_asc ON public.entity_hierarchies USING btree (title, ancestor_type, ancestor_id);


--
-- Name: index_entity_hierarchies_by_descendant_title_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_by_descendant_title_desc ON public.entity_hierarchies USING btree (title DESC, ancestor_type, ancestor_id);


--
-- Name: index_entity_hierarchies_on_ancestor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_on_ancestor ON public.entity_hierarchies USING btree (ancestor_type, ancestor_id);


--
-- Name: index_entity_hierarchies_on_descendant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_on_descendant ON public.entity_hierarchies USING btree (descendant_type, descendant_id);


--
-- Name: index_entity_hierarchies_on_hierarchical; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_on_hierarchical ON public.entity_hierarchies USING btree (hierarchical_type, hierarchical_id);


--
-- Name: index_entity_hierarchies_on_schema_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_on_schema_definition_id ON public.entity_hierarchies USING btree (schema_definition_id);


--
-- Name: index_entity_hierarchies_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_on_schema_version_id ON public.entity_hierarchies USING btree (schema_version_id);


--
-- Name: index_entity_hierarchies_ranking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_hierarchies_ranking ON public.entity_hierarchies USING btree (ancestor_type, ancestor_id, schema_definition_id, schema_version_id, depth) WHERE (ancestor_id <> descendant_id);


--
-- Name: index_entity_hierarchies_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_hierarchies_uniqueness ON public.entity_hierarchies USING btree (ancestor_id, descendant_id);


--
-- Name: index_entity_links_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_auth_path ON public.entity_links USING gist (auth_path);


--
-- Name: index_entity_links_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_schema_version_id ON public.entity_links USING btree (schema_version_id);


--
-- Name: index_entity_links_on_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_scope ON public.entity_links USING gist (scope);


--
-- Name: index_entity_links_on_source_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_source_collection_id ON public.entity_links USING btree (source_collection_id);


--
-- Name: index_entity_links_on_source_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_source_community_id ON public.entity_links USING btree (source_community_id);


--
-- Name: index_entity_links_on_source_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_source_item_id ON public.entity_links USING btree (source_item_id);


--
-- Name: index_entity_links_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_links_on_system_slug ON public.entity_links USING btree (system_slug);


--
-- Name: index_entity_links_on_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_target ON public.entity_links USING btree (target_type, target_id);


--
-- Name: index_entity_links_on_target_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_target_collection_id ON public.entity_links USING btree (target_collection_id);


--
-- Name: index_entity_links_on_target_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_target_community_id ON public.entity_links USING btree (target_community_id);


--
-- Name: index_entity_links_on_target_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_on_target_item_id ON public.entity_links USING btree (target_item_id);


--
-- Name: index_entity_links_related_collections; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_related_collections ON public.entity_links USING btree (source_id, target_id) WHERE (((source_type)::text = 'Collection'::text) AND ((target_type)::text = 'Collection'::text));


--
-- Name: index_entity_links_related_items; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_links_related_items ON public.entity_links USING btree (source_id, target_id) WHERE (((source_type)::text = 'Item'::text) AND ((target_type)::text = 'Item'::text));


--
-- Name: index_entity_links_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_links_uniqueness ON public.entity_links USING btree (source_type, source_id, target_type, target_id);


--
-- Name: index_entity_orderable_properties_on_schema_version_property_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_orderable_properties_on_schema_version_property_id ON public.entity_orderable_properties USING btree (schema_version_property_id);


--
-- Name: index_entity_search_documents_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_search_documents_on_collection_id ON public.entity_search_documents USING btree (collection_id);


--
-- Name: index_entity_search_documents_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_search_documents_on_community_id ON public.entity_search_documents USING btree (community_id);


--
-- Name: index_entity_search_documents_on_document; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_search_documents_on_document ON public.entity_search_documents USING gin (document);


--
-- Name: index_entity_search_documents_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_search_documents_on_entity ON public.entity_search_documents USING btree (entity_type, entity_id);


--
-- Name: index_entity_search_documents_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_search_documents_on_item_id ON public.entity_search_documents USING btree (item_id);


--
-- Name: index_entity_visibilities_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entity_visibilities_on_entity ON public.entity_visibilities USING btree (entity_type, entity_id);


--
-- Name: index_entity_visibilities_visibility_coverage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entity_visibilities_visibility_coverage ON public.entity_visibilities USING gist (visibility, visibility_range, entity_type, entity_id);


--
-- Name: index_eop_boolean; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_boolean ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, boolean_value);


--
-- Name: index_eop_boolean_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_boolean_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, boolean_value DESC NULLS LAST);


--
-- Name: index_eop_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_date ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, date_value);


--
-- Name: index_eop_date_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_date_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, date_value DESC NULLS LAST);


--
-- Name: index_eop_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_email ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, email_value);


--
-- Name: index_eop_email_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_email_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, email_value DESC NULLS LAST);


--
-- Name: index_eop_fixed_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_fixed_position ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, fixed_position);


--
-- Name: index_eop_fixed_position_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_fixed_position_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, fixed_position DESC NULLS LAST);


--
-- Name: index_eop_float; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_float ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, float_value);


--
-- Name: index_eop_float_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_float_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, float_value DESC NULLS LAST);


--
-- Name: index_eop_integer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_integer ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, integer_value);


--
-- Name: index_eop_integer_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_integer_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, integer_value DESC NULLS LAST);


--
-- Name: index_eop_string; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_string ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, string_value);


--
-- Name: index_eop_string_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_string_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, string_value DESC NULLS LAST);


--
-- Name: index_eop_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_timestamp ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, timestamp_value);


--
-- Name: index_eop_timestamp_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_timestamp_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, timestamp_value DESC NULLS LAST);


--
-- Name: index_eop_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_eop_uniqueness ON public.entity_orderable_properties USING btree (entity_type, entity_id, path);


--
-- Name: index_eop_variable_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_variable_date ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, variable_date_value);


--
-- Name: index_eop_variable_date_inverted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eop_variable_date_inverted ON public.entity_orderable_properties USING btree (entity_type, entity_id, path, variable_date_value DESC NULLS LAST);


--
-- Name: index_esp_on_svp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_esp_on_svp ON public.entity_searchable_properties USING btree (schema_version_property_id);


--
-- Name: index_esp_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_esp_uniqueness ON public.entity_searchable_properties USING btree (entity_type, entity_id, path);


--
-- Name: index_fake_visitors_on_sequence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fake_visitors_on_sequence ON public.fake_visitors USING btree (sequence);


--
-- Name: index_fake_visitors_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fake_visitors_on_user_id ON public.fake_visitors USING btree (user_id);


--
-- Name: index_frontend_revalidations_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_frontend_revalidations_on_entity ON public.frontend_revalidations USING btree (entity_type, entity_id);


--
-- Name: index_global_configurations_singleton_guard; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_global_configurations_singleton_guard ON public.global_configurations USING btree (guard);


--
-- Name: index_good_job_executions_on_active_job_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_job_executions_on_active_job_id_and_created_at ON public.good_job_executions USING btree (active_job_id, created_at);


--
-- Name: index_good_job_executions_on_process_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_job_executions_on_process_id_and_created_at ON public.good_job_executions USING btree (process_id, created_at);


--
-- Name: index_good_job_jobs_for_candidate_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_job_jobs_for_candidate_lookup ON public.good_jobs USING btree (priority, created_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_job_settings_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_good_job_settings_on_key ON public.good_job_settings USING btree (key);


--
-- Name: index_good_jobs_jobs_on_finished_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_jobs_on_finished_at ON public.good_jobs USING btree (finished_at) WHERE ((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL));


--
-- Name: index_good_jobs_jobs_on_priority_created_at_when_unfinished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_jobs_on_priority_created_at_when_unfinished ON public.good_jobs USING btree (priority DESC NULLS LAST, created_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_active_job_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_active_job_id_and_created_at ON public.good_jobs USING btree (active_job_id, created_at);


--
-- Name: index_good_jobs_on_batch_callback_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_batch_callback_id ON public.good_jobs USING btree (batch_callback_id) WHERE (batch_callback_id IS NOT NULL);


--
-- Name: index_good_jobs_on_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_batch_id ON public.good_jobs USING btree (batch_id) WHERE (batch_id IS NOT NULL);


--
-- Name: index_good_jobs_on_concurrency_key_when_unfinished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_concurrency_key_when_unfinished ON public.good_jobs USING btree (concurrency_key) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_cron_key_and_created_at_cond; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_cron_key_and_created_at_cond ON public.good_jobs USING btree (cron_key, created_at) WHERE (cron_key IS NOT NULL);


--
-- Name: index_good_jobs_on_cron_key_and_cron_at_cond; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_good_jobs_on_cron_key_and_cron_at_cond ON public.good_jobs USING btree (cron_key, cron_at) WHERE (cron_key IS NOT NULL);


--
-- Name: index_good_jobs_on_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_labels ON public.good_jobs USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: index_good_jobs_on_locked_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_locked_by_id ON public.good_jobs USING btree (locked_by_id) WHERE (locked_by_id IS NOT NULL);


--
-- Name: index_good_jobs_on_priority_scheduled_at_unfinished_unlocked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_priority_scheduled_at_unfinished_unlocked ON public.good_jobs USING btree (priority, scheduled_at) WHERE ((finished_at IS NULL) AND (locked_by_id IS NULL));


--
-- Name: index_good_jobs_on_queue_name_and_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_queue_name_and_scheduled_at ON public.good_jobs USING btree (queue_name, scheduled_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_scheduled_at ON public.good_jobs USING btree (scheduled_at) WHERE (finished_at IS NULL);


--
-- Name: index_granted_permissions_by_role_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_by_role_permission ON public.granted_permissions USING btree (role_id, permission_id);


--
-- Name: index_granted_permissions_contextual_btree; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_contextual_btree ON public.granted_permissions USING btree (scope, auth_path, user_id, permission_id, action, inferred, role_id, accessible_id, accessible_type, access_grant_id);


--
-- Name: index_granted_permissions_contextual_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_contextual_user ON public.granted_permissions USING btree (user_id, permission_id, scope, auth_path, action, inferred, role_id, accessible_id, accessible_type, access_grant_id);


--
-- Name: index_granted_permissions_on_access_grant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_on_access_grant_id ON public.granted_permissions USING btree (access_grant_id);


--
-- Name: index_granted_permissions_on_accessible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_on_accessible ON public.granted_permissions USING btree (accessible_type, accessible_id);


--
-- Name: index_granted_permissions_on_inferred; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_on_inferred ON public.granted_permissions USING btree (inferred);


--
-- Name: index_granted_permissions_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_on_permission_id ON public.granted_permissions USING btree (permission_id);


--
-- Name: index_granted_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_on_role_id ON public.granted_permissions USING btree (role_id);


--
-- Name: index_granted_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_granted_permissions_on_user_id ON public.granted_permissions USING btree (user_id);


--
-- Name: index_granted_permissions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_granted_permissions_uniqueness ON public.granted_permissions USING btree (access_grant_id, permission_id, user_id, scope, action);


--
-- Name: index_harl_transitions_parent_most_recent; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harl_transitions_parent_most_recent ON public.harvest_attempt_record_link_transitions USING btree (harvest_attempt_record_link_id, most_recent) WHERE most_recent;


--
-- Name: index_harvest_attempt_entity_link_transitions_parent_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_attempt_entity_link_transitions_parent_sort ON public.harvest_attempt_entity_link_transitions USING btree (harvest_attempt_entity_link_id, sort_key);


--
-- Name: index_harvest_attempt_entity_links_on_harvest_attempt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempt_entity_links_on_harvest_attempt_id ON public.harvest_attempt_entity_links USING btree (harvest_attempt_id);


--
-- Name: index_harvest_attempt_entity_links_on_harvest_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempt_entity_links_on_harvest_entity_id ON public.harvest_attempt_entity_links USING btree (harvest_entity_id);


--
-- Name: index_harvest_attempt_entity_links_on_harvest_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempt_entity_links_on_harvest_record_id ON public.harvest_attempt_entity_links USING btree (harvest_record_id);


--
-- Name: index_harvest_attempt_entity_links_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_attempt_entity_links_uniqueness ON public.harvest_attempt_entity_links USING btree (harvest_attempt_id, harvest_entity_id);


--
-- Name: index_harvest_attempt_record_link_transitions_parent_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_attempt_record_link_transitions_parent_sort ON public.harvest_attempt_record_link_transitions USING btree (harvest_attempt_record_link_id, sort_key);


--
-- Name: index_harvest_attempt_record_links_on_harvest_attempt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempt_record_links_on_harvest_attempt_id ON public.harvest_attempt_record_links USING btree (harvest_attempt_id);


--
-- Name: index_harvest_attempt_record_links_on_harvest_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempt_record_links_on_harvest_record_id ON public.harvest_attempt_record_links USING btree (harvest_record_id);


--
-- Name: index_harvest_attempt_record_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_attempt_record_uniqueness ON public.harvest_attempt_record_links USING btree (harvest_attempt_id, harvest_record_id);


--
-- Name: index_harvest_attempt_transitions_parent_most_recent; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_attempt_transitions_parent_most_recent ON public.harvest_attempt_transitions USING btree (harvest_attempt_id, most_recent) WHERE most_recent;


--
-- Name: index_harvest_attempt_transitions_parent_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_attempt_transitions_parent_sort ON public.harvest_attempt_transitions USING btree (harvest_attempt_id, sort_key);


--
-- Name: index_harvest_attempts_on_harvest_mapping_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempts_on_harvest_mapping_id ON public.harvest_attempts USING btree (harvest_mapping_id);


--
-- Name: index_harvest_attempts_on_harvest_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempts_on_harvest_set_id ON public.harvest_attempts USING btree (harvest_set_id);


--
-- Name: index_harvest_attempts_on_harvest_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempts_on_harvest_source_id ON public.harvest_attempts USING btree (harvest_source_id);


--
-- Name: index_harvest_attempts_on_target_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_attempts_on_target_entity ON public.harvest_attempts USING btree (target_entity_type, target_entity_id);


--
-- Name: index_harvest_cached_assets_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_cached_assets_on_url ON public.harvest_cached_assets USING btree (url);


--
-- Name: index_harvest_configurations_on_harvest_attempt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_configurations_on_harvest_attempt_id ON public.harvest_configurations USING btree (harvest_attempt_id);


--
-- Name: index_harvest_configurations_on_harvest_mapping_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_configurations_on_harvest_mapping_id ON public.harvest_configurations USING btree (harvest_mapping_id);


--
-- Name: index_harvest_configurations_on_harvest_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_configurations_on_harvest_set_id ON public.harvest_configurations USING btree (harvest_set_id);


--
-- Name: index_harvest_configurations_on_harvest_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_configurations_on_harvest_source_id ON public.harvest_configurations USING btree (harvest_source_id);


--
-- Name: index_harvest_configurations_on_target_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_configurations_on_target_entity ON public.harvest_configurations USING btree (target_entity_type, target_entity_id);


--
-- Name: index_harvest_contributions_on_harvest_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_contributions_on_harvest_entity_id ON public.harvest_contributions USING btree (harvest_entity_id);


--
-- Name: index_harvest_contributions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_contributions_on_role_id ON public.harvest_contributions USING btree (role_id);


--
-- Name: index_harvest_contributors_on_contributor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_contributors_on_contributor_id ON public.harvest_contributors USING btree (contributor_id);


--
-- Name: index_harvest_contributors_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_contributors_uniqueness ON public.harvest_contributors USING btree (harvest_source_id, identifier);


--
-- Name: index_harvest_entities_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_entities_on_entity ON public.harvest_entities USING btree (entity_type, entity_id);


--
-- Name: index_harvest_entities_on_existing_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_entities_on_existing_parent ON public.harvest_entities USING btree (existing_parent_type, existing_parent_id);


--
-- Name: index_harvest_entities_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_entities_on_parent_id ON public.harvest_entities USING btree (parent_id);


--
-- Name: index_harvest_entities_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_entities_on_schema_version_id ON public.harvest_entities USING btree (schema_version_id);


--
-- Name: index_harvest_entities_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_entities_uniqueness ON public.harvest_entities USING btree (harvest_record_id, identifier);


--
-- Name: index_harvest_errors_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_errors_on_source ON public.harvest_errors USING btree (source_type, source_id);


--
-- Name: index_harvest_mapping_record_links_on_harvest_mapping_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_mapping_record_links_on_harvest_mapping_id ON public.harvest_mapping_record_links USING btree (harvest_mapping_id);


--
-- Name: index_harvest_mapping_record_links_on_harvest_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_mapping_record_links_on_harvest_record_id ON public.harvest_mapping_record_links USING btree (harvest_record_id);


--
-- Name: index_harvest_mapping_record_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_mapping_record_uniqueness ON public.harvest_mapping_record_links USING btree (harvest_mapping_id, harvest_record_id);


--
-- Name: index_harvest_mappings_on_harvest_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_mappings_on_harvest_set_id ON public.harvest_mappings USING btree (harvest_set_id);


--
-- Name: index_harvest_mappings_on_target_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_mappings_on_target_entity ON public.harvest_mappings USING btree (target_entity_type, target_entity_id);


--
-- Name: index_harvest_messages_on_harvest_attempt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_messages_on_harvest_attempt_id ON public.harvest_messages USING btree (harvest_attempt_id);


--
-- Name: index_harvest_messages_on_harvest_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_messages_on_harvest_entity_id ON public.harvest_messages USING btree (harvest_entity_id);


--
-- Name: index_harvest_messages_on_harvest_mapping_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_messages_on_harvest_mapping_id ON public.harvest_messages USING btree (harvest_mapping_id);


--
-- Name: index_harvest_messages_on_harvest_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_messages_on_harvest_record_id ON public.harvest_messages USING btree (harvest_record_id);


--
-- Name: index_harvest_messages_on_harvest_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_messages_on_harvest_source_id ON public.harvest_messages USING btree (harvest_source_id);


--
-- Name: index_harvest_metadata_mappings_on_harvest_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_metadata_mappings_on_harvest_source_id ON public.harvest_metadata_mappings USING btree (harvest_source_id);


--
-- Name: index_harvest_metadata_mappings_on_target_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_metadata_mappings_on_target_entity ON public.harvest_metadata_mappings USING btree (target_entity_type, target_entity_id);


--
-- Name: index_harvest_metadata_mappings_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_metadata_mappings_uniqueness ON public.harvest_metadata_mappings USING btree (harvest_source_id, field, pattern);


--
-- Name: index_harvest_records_on_harvest_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_records_on_harvest_configuration_id ON public.harvest_records USING btree (harvest_configuration_id);


--
-- Name: index_harvest_records_on_harvest_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_records_on_harvest_source_id ON public.harvest_records USING btree (harvest_source_id);


--
-- Name: index_harvest_records_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_records_on_status ON public.harvest_records USING btree (status);


--
-- Name: index_harvest_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_records_uniqueness ON public.harvest_records USING btree (harvest_source_id, identifier);


--
-- Name: index_harvest_set_record_links_on_harvest_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_set_record_links_on_harvest_record_id ON public.harvest_set_record_links USING btree (harvest_record_id);


--
-- Name: index_harvest_set_record_links_on_harvest_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_harvest_set_record_links_on_harvest_set_id ON public.harvest_set_record_links USING btree (harvest_set_id);


--
-- Name: index_harvest_set_record_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_set_record_uniqueness ON public.harvest_set_record_links USING btree (harvest_set_id, harvest_record_id);


--
-- Name: index_harvest_sets_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_sets_uniqueness ON public.harvest_sets USING btree (harvest_source_id, identifier);


--
-- Name: index_harvest_sources_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_harvest_sources_on_identifier ON public.harvest_sources USING btree (identifier);


--
-- Name: index_hcar_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hcar_uniqueness ON public.harvest_cached_asset_references USING btree (harvest_cached_asset_id, cacheable_id);


--
-- Name: index_herl_transitions_parent_most_recent; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_herl_transitions_parent_most_recent ON public.harvest_attempt_entity_link_transitions USING btree (harvest_attempt_entity_link_id, most_recent) WHERE most_recent;


--
-- Name: index_initial_ordering_links_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_initial_ordering_links_on_entity ON public.initial_ordering_links USING btree (entity_type, entity_id);


--
-- Name: index_initial_ordering_links_on_ordering_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_initial_ordering_links_on_ordering_id ON public.initial_ordering_links USING btree (ordering_id);


--
-- Name: index_initial_ordering_selections_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_initial_ordering_selections_on_entity ON public.initial_ordering_selections USING btree (entity_type, entity_id);


--
-- Name: index_initial_ordering_selections_on_ordering_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_initial_ordering_selections_on_ordering_id ON public.initial_ordering_selections USING btree (ordering_id);


--
-- Name: index_item_attributions_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_attributions_ordering ON public.item_attributions USING btree (item_id, "position");


--
-- Name: index_item_attributions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_item_attributions_uniqueness ON public.item_attributions USING btree (item_id, contributor_id);


--
-- Name: index_item_authorizations_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_authorizations_on_auth_path ON public.item_authorizations USING gist (auth_path);


--
-- Name: index_item_authorizations_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_authorizations_on_collection_id ON public.item_authorizations USING btree (collection_id);


--
-- Name: index_item_authorizations_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_authorizations_on_community_id ON public.item_authorizations USING btree (community_id);


--
-- Name: index_item_authorizations_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_item_authorizations_on_item_id ON public.item_authorizations USING btree (item_id);


--
-- Name: index_item_contributions_assigned_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_item_contributions_assigned_uniqueness ON public.item_contributions USING btree (contributor_id, item_id, role_id);


--
-- Name: index_item_contributions_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_contributions_on_item_id ON public.item_contributions USING btree (item_id);


--
-- Name: index_item_contributions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_contributions_on_role_id ON public.item_contributions USING btree (role_id);


--
-- Name: index_item_links_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_links_on_target_id ON public.item_links USING btree (target_id);


--
-- Name: index_item_links_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_item_links_uniqueness ON public.item_links USING btree (source_id, target_id);


--
-- Name: index_items_on_auth_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_auth_path ON public.items USING gist (auth_path);


--
-- Name: index_items_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_collection_id ON public.items USING btree (collection_id);


--
-- Name: index_items_on_doi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_doi ON public.items USING btree (doi);


--
-- Name: index_items_on_has_doi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_has_doi ON public.items USING btree (has_doi);


--
-- Name: index_items_on_issn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_issn ON public.items USING btree (issn);


--
-- Name: index_items_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_parent_id ON public.items USING btree (parent_id);


--
-- Name: index_items_on_properties; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_properties ON public.items USING gin (properties);


--
-- Name: index_items_on_raw_doi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_raw_doi ON public.items USING btree (raw_doi);


--
-- Name: index_items_on_schema_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_schema_definition_id ON public.items USING btree (schema_definition_id);


--
-- Name: index_items_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_schema_version_id ON public.items USING btree (schema_version_id);


--
-- Name: index_items_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_on_system_slug ON public.items USING btree (system_slug);


--
-- Name: index_items_unique_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_unique_identifier ON public.items USING btree (identifier, collection_id, parent_id);


--
-- Name: index_items_versioned_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_versioned_ids ON public.items USING btree (id, schema_version_id);


--
-- Name: index_layout_definition_hierarchies_check; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layout_definition_hierarchies_check ON public.layout_definition_hierarchies USING gist (schema_version_id, auth_path, layout_kind, layout_definition_type, layout_definition_id);


--
-- Name: index_layout_definition_hierarchies_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layout_definition_hierarchies_on_entity ON public.layout_definition_hierarchies USING btree (entity_type, entity_id);


--
-- Name: index_layout_definition_hierarchies_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layout_definition_hierarchies_on_layout_definition ON public.layout_definition_hierarchies USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_layout_definition_hierarchies_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layout_definition_hierarchies_on_schema_version_id ON public.layout_definition_hierarchies USING btree (schema_version_id);


--
-- Name: index_layout_instance_digest_check; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layout_instance_digest_check ON public.layouts_instance_digests USING btree (layout_definition_id, entity_type, entity_id);


--
-- Name: index_layout_invalidations_distinct_staleness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layout_invalidations_distinct_staleness ON public.layout_invalidations USING btree (entity_id, stale_at DESC);


--
-- Name: index_layout_invalidations_on_sequence_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layout_invalidations_on_sequence_id ON public.layout_invalidations USING btree (sequence_id);


--
-- Name: index_layouts_hero_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_hero_instances_on_entity ON public.layouts_hero_instances USING btree (entity_type, entity_id);


--
-- Name: index_layouts_hero_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_hero_instances_on_generation ON public.layouts_hero_instances USING btree (generation);


--
-- Name: index_layouts_hero_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_hero_instances_on_last_rendered_at ON public.layouts_hero_instances USING btree (last_rendered_at);


--
-- Name: index_layouts_instance_digests_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_instance_digests_on_entity ON public.layouts_instance_digests USING btree (entity_type, entity_id);


--
-- Name: index_layouts_instance_digests_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_instance_digests_on_layout_definition ON public.layouts_instance_digests USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_layouts_instance_digests_on_layout_instance; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_instance_digests_on_layout_instance ON public.layouts_instance_digests USING btree (layout_instance_type, layout_instance_id);


--
-- Name: index_layouts_list_item_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_list_item_instances_on_entity ON public.layouts_list_item_instances USING btree (entity_type, entity_id);


--
-- Name: index_layouts_list_item_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_list_item_instances_on_generation ON public.layouts_list_item_instances USING btree (generation);


--
-- Name: index_layouts_list_item_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_list_item_instances_on_last_rendered_at ON public.layouts_list_item_instances USING btree (last_rendered_at);


--
-- Name: index_layouts_main_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_main_instances_on_entity ON public.layouts_main_instances USING btree (entity_type, entity_id);


--
-- Name: index_layouts_main_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_main_instances_on_generation ON public.layouts_main_instances USING btree (generation);


--
-- Name: index_layouts_main_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_main_instances_on_last_rendered_at ON public.layouts_main_instances USING btree (last_rendered_at);


--
-- Name: index_layouts_metadata_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_metadata_instances_on_entity ON public.layouts_metadata_instances USING btree (entity_type, entity_id);


--
-- Name: index_layouts_metadata_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_metadata_instances_on_generation ON public.layouts_metadata_instances USING btree (generation);


--
-- Name: index_layouts_metadata_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_metadata_instances_on_last_rendered_at ON public.layouts_metadata_instances USING btree (last_rendered_at);


--
-- Name: index_layouts_navigation_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_navigation_instances_on_entity ON public.layouts_navigation_instances USING btree (entity_type, entity_id);


--
-- Name: index_layouts_navigation_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_navigation_instances_on_generation ON public.layouts_navigation_instances USING btree (generation);


--
-- Name: index_layouts_navigation_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_navigation_instances_on_last_rendered_at ON public.layouts_navigation_instances USING btree (last_rendered_at);


--
-- Name: index_layouts_supplementary_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_layouts_supplementary_instances_on_entity ON public.layouts_supplementary_instances USING btree (entity_type, entity_id);


--
-- Name: index_layouts_supplementary_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_supplementary_instances_on_generation ON public.layouts_supplementary_instances USING btree (generation);


--
-- Name: index_layouts_supplementary_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layouts_supplementary_instances_on_last_rendered_at ON public.layouts_supplementary_instances USING btree (last_rendered_at);


--
-- Name: index_legacy_harvest_records_on_has_been_skipped; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_harvest_records_on_has_been_skipped ON public.legacy_harvest_records USING btree (has_been_skipped);


--
-- Name: index_list_item_templates_see_all_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_list_item_templates_see_all_ordering ON public.templates_list_item_instances USING btree (see_all_ordering_id);


--
-- Name: index_manual_template_references_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_manual_template_references_ordering ON public.templates_manual_list_entries USING btree (source_type, source_id, template_kind, list_name, "position");


--
-- Name: index_manual_template_references_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_manual_template_references_uniqueness ON public.templates_manual_list_entries USING btree (source_type, source_id, target_type, target_id, template_kind, list_name);


--
-- Name: index_named_variable_dates_ascending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_named_variable_dates_ascending ON public.named_variable_dates USING btree (value, "precision", path, entity_type, entity_id);


--
-- Name: index_named_variable_dates_by_coverage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_named_variable_dates_by_coverage ON public.named_variable_dates USING gist (coverage, path, entity_type, entity_id);


--
-- Name: index_named_variable_dates_descending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_named_variable_dates_descending ON public.named_variable_dates USING btree (value DESC NULLS LAST, "precision" DESC NULLS LAST, path, entity_type, entity_id);


--
-- Name: index_named_variable_dates_on_actual_precision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_named_variable_dates_on_actual_precision ON public.named_variable_dates USING btree (actual_precision);


--
-- Name: index_named_variable_dates_on_precision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_named_variable_dates_on_precision ON public.named_variable_dates USING btree ("precision");


--
-- Name: index_named_variable_dates_on_schema_version_property_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_named_variable_dates_on_schema_version_property_id ON public.named_variable_dates USING btree (schema_version_property_id);


--
-- Name: index_named_variable_dates_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_named_variable_dates_uniqueness ON public.named_variable_dates USING btree (entity_type, entity_id, path);


--
-- Name: index_nvd_join_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nvd_join_asc ON public.named_variable_dates USING btree (entity_type, entity_id, path, value, "precision");


--
-- Name: index_nvd_join_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nvd_join_desc ON public.named_variable_dates USING btree (entity_type, entity_id, path, value DESC NULLS LAST, "precision" DESC NULLS LAST);


--
-- Name: index_ordering_entries_references_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_references_entity ON public.ordering_entries USING btree (entity_type, entity_id);


--
-- Name: index_ordering_entries_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_sort ON public.ordering_entries USING btree (ordering_id, "position");


--
-- Name: index_ordering_entries_sort_inverse; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_sort_inverse ON public.ordering_entries USING btree (ordering_id, inverse_position);


--
-- Name: index_ordering_entries_sorted_by_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_sorted_by_scope ON public.ordering_entries USING gist (ordering_id, scope, "position");


--
-- Name: index_ordering_entries_staleness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_staleness ON public.ordering_entries USING btree (ordering_id, stale_at) WHERE (stale_at IS NOT NULL);


--
-- Name: index_ordering_entries_tree_ancestry_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_tree_ancestry_lookup ON public.ordering_entries USING gist (ordering_id, auth_path, tree_depth) INCLUDE (id);


--
-- Name: index_ordering_entries_tree_child_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_tree_child_lookup ON public.ordering_entries USING btree (ordering_id, auth_path) INCLUDE (tree_depth, id) WHERE (tree_depth > 1);


--
-- Name: index_ordering_entries_tree_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entries_tree_parent ON public.ordering_entries USING btree (ordering_id, tree_parent_id, tree_parent_type);


--
-- Name: index_ordering_entries_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ordering_entries_uniqueness ON public.ordering_entries USING btree (ordering_id, entity_type, entity_id);


--
-- Name: index_ordering_entry_ancestor_links_on_ancestor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_ancestor_links_on_ancestor_id ON public.ordering_entry_ancestor_links USING btree (ancestor_id);


--
-- Name: index_ordering_entry_ancestor_links_on_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_ancestor_links_on_child_id ON public.ordering_entry_ancestor_links USING btree (child_id);


--
-- Name: index_ordering_entry_ancestor_links_on_ordering_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_ancestor_links_on_ordering_id ON public.ordering_entry_ancestor_links USING btree (ordering_id);


--
-- Name: index_ordering_entry_ancestor_links_sorting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_ancestor_links_sorting ON public.ordering_entry_ancestor_links USING btree (ordering_id, child_id, ancestor_id, inverse_depth);


--
-- Name: index_ordering_entry_ancestor_links_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ordering_entry_ancestor_links_uniqueness ON public.ordering_entry_ancestor_links USING btree (ordering_id, child_id, inverse_depth);


--
-- Name: index_ordering_entry_sibling_links_on_next_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_sibling_links_on_next_id ON public.ordering_entry_sibling_links USING btree (next_id);


--
-- Name: index_ordering_entry_sibling_links_on_ordering_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_sibling_links_on_ordering_id ON public.ordering_entry_sibling_links USING btree (ordering_id);


--
-- Name: index_ordering_entry_sibling_links_on_prev_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_sibling_links_on_prev_id ON public.ordering_entry_sibling_links USING btree (prev_id);


--
-- Name: index_ordering_entry_sibling_links_on_sibling_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_entry_sibling_links_on_sibling_id ON public.ordering_entry_sibling_links USING btree (sibling_id);


--
-- Name: index_ordering_entry_sibling_links_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ordering_entry_sibling_links_uniqueness ON public.ordering_entry_sibling_links USING btree (ordering_id, sibling_id);


--
-- Name: index_ordering_invalidations_distinct_staleness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordering_invalidations_distinct_staleness ON public.ordering_invalidations USING btree (ordering_id, stale_at DESC);


--
-- Name: index_orderings_deterministic_by_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_deterministic_by_position ON public.orderings USING btree (entity_id, entity_type, "position", name, identifier);


--
-- Name: index_orderings_deterministic_by_schema_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_deterministic_by_schema_position ON public.orderings USING btree (entity_id, entity_type, schema_position, name, identifier);


--
-- Name: index_orderings_enabled_by_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_enabled_by_entity ON public.orderings USING btree (entity_id, entity_type) WHERE (disabled_at IS NULL);


--
-- Name: index_orderings_for_initial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_for_initial ON public.orderings USING btree (id, entity_id, entity_type, "position", name, identifier) WHERE ((disabled_at IS NULL) AND (NOT hidden));


--
-- Name: index_orderings_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_on_collection_id ON public.orderings USING btree (collection_id);


--
-- Name: index_orderings_on_community_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_on_community_id ON public.orderings USING btree (community_id);


--
-- Name: index_orderings_on_handled_schema_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_on_handled_schema_definition_id ON public.orderings USING btree (handled_schema_definition_id);


--
-- Name: index_orderings_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_on_item_id ON public.orderings USING btree (item_id);


--
-- Name: index_orderings_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_on_schema_version_id ON public.orderings USING btree (schema_version_id);


--
-- Name: index_orderings_staleness; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orderings_staleness ON public.orderings USING btree (stale);


--
-- Name: index_orderings_unique_handler; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_orderings_unique_handler ON public.orderings USING btree (entity_type, entity_id, handled_schema_definition_id);


--
-- Name: index_orderings_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_orderings_uniqueness ON public.orderings USING btree (entity_id, entity_type, identifier);


--
-- Name: index_pages_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_ordering ON public.pages USING btree (entity_type, entity_id, "position");


--
-- Name: index_pages_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pages_uniqueness ON public.pages USING btree (entity_type, entity_id, slug);


--
-- Name: index_permalinks_on_canonical_permalinkable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permalinks_on_canonical_permalinkable ON public.permalinks USING btree (permalinkable_type, permalinkable_id) WHERE canonical;


--
-- Name: index_permalinks_on_permalinkable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permalinks_on_permalinkable ON public.permalinks USING btree (permalinkable_type, permalinkable_id);


--
-- Name: index_permalinks_on_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permalinks_on_uri ON public.permalinks USING btree (uri);


--
-- Name: index_permalinks_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permalinks_ordering ON public.permalinks USING btree (canonical DESC, uri);


--
-- Name: index_permissions_contextual_derivations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_contextual_derivations ON public.permissions USING btree (name, scope, path) WHERE (kind = 'contextual'::public.permission_kind);


--
-- Name: index_permissions_inherited; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_inherited ON public.permissions USING btree (id, path, inheritance);


--
-- Name: index_permissions_name_text; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_name_text ON public.permissions USING btree (((name)::text));


--
-- Name: index_permissions_on_inheritance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_inheritance ON public.permissions USING gist (inheritance);


--
-- Name: index_permissions_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_kind ON public.permissions USING btree (kind);


--
-- Name: index_permissions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_name ON public.permissions USING btree (name);


--
-- Name: index_permissions_on_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_scope ON public.permissions USING btree (scope);


--
-- Name: index_permissions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_uniqueness ON public.permissions USING btree (path);


--
-- Name: index_pghero_query_stats_on_database_and_captured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pghero_query_stats_on_database_and_captured_at ON public.pghero_query_stats USING btree (database, captured_at);


--
-- Name: index_pghero_space_stats_on_database_and_captured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pghero_space_stats_on_database_and_captured_at ON public.pghero_space_stats USING btree (database, captured_at);


--
-- Name: index_rendering_entity_logs_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_entity_logs_on_entity ON public.rendering_entity_logs USING btree (entity_type, entity_id);


--
-- Name: index_rendering_entity_logs_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_entity_logs_on_schema_version_id ON public.rendering_entity_logs USING btree (schema_version_id);


--
-- Name: index_rendering_layout_logs_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_layout_logs_on_entity ON public.rendering_layout_logs USING btree (entity_type, entity_id);


--
-- Name: index_rendering_layout_logs_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_layout_logs_on_layout_definition ON public.rendering_layout_logs USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_rendering_layout_logs_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_layout_logs_on_schema_version_id ON public.rendering_layout_logs USING btree (schema_version_id);


--
-- Name: index_rendering_template_logs_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_template_logs_on_entity ON public.rendering_template_logs USING btree (entity_type, entity_id);


--
-- Name: index_rendering_template_logs_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_template_logs_on_layout_definition ON public.rendering_template_logs USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_rendering_template_logs_on_schema_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_template_logs_on_schema_version_id ON public.rendering_template_logs USING btree (schema_version_id);


--
-- Name: index_rendering_template_logs_on_template_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rendering_template_logs_on_template_definition ON public.rendering_template_logs USING btree (template_definition_type, template_definition_id);


--
-- Name: index_request_timings_on_request_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_timings_on_request_query_id ON public.request_timings USING btree (request_query_id);


--
-- Name: index_role_permissions_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_permissions_on_permission_id ON public.role_permissions USING btree (permission_id);


--
-- Name: index_roles_on_allowed_actions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_allowed_actions ON public.roles USING gist (allowed_actions);


--
-- Name: index_roles_on_custom_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_custom_priority ON public.roles USING btree (custom_priority);


--
-- Name: index_roles_on_global_allowed_actions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_global_allowed_actions ON public.roles USING gist (global_allowed_actions);


--
-- Name: index_roles_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_identifier ON public.roles USING btree (identifier);


--
-- Name: index_roles_sort_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_sort_order ON public.roles USING btree (primacy, priority DESC, kind);


--
-- Name: index_roles_unique_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_unique_name ON public.roles USING btree (name);


--
-- Name: index_rollups_on_name_and_interval_and_time_and_dimensions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rollups_on_name_and_interval_and_time_and_dimensions ON public.rollups USING btree (name, "interval", "time", dimensions);


--
-- Name: index_schema_definition_properties_on_current; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_definition_properties_on_current ON public.schema_definition_properties USING btree (current);


--
-- Name: index_schema_definition_properties_on_orderable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_definition_properties_on_orderable ON public.schema_definition_properties USING btree (orderable);


--
-- Name: index_schema_definition_properties_on_versions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_definition_properties_on_versions ON public.schema_definition_properties USING gin (versions);


--
-- Name: index_schema_definitions_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_definitions_on_namespace ON public.schema_definitions USING btree (namespace);


--
-- Name: index_schema_definitions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schema_definitions_uniqueness ON public.schema_definitions USING btree (identifier, namespace);


--
-- Name: index_schema_version_ancestors_on_target_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_version_ancestors_on_target_version_id ON public.schema_version_ancestors USING btree (target_version_id);


--
-- Name: index_schema_version_ancestors_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schema_version_ancestors_uniqueness ON public.schema_version_ancestors USING btree (schema_version_id, target_version_id, name);


--
-- Name: index_schema_version_associations_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_version_associations_on_target_id ON public.schema_version_associations USING btree (target_id);


--
-- Name: index_schema_version_associations_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schema_version_associations_uniqueness ON public.schema_version_associations USING btree (source_id, target_id, name);


--
-- Name: index_schema_version_position_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_version_position_ordering ON public.schema_version_properties USING btree (schema_version_id, "position");


--
-- Name: index_schema_version_properties_on_function; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_version_properties_on_function ON public.schema_version_properties USING btree (function);


--
-- Name: index_schema_version_properties_on_orderable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_version_properties_on_orderable ON public.schema_version_properties USING btree (orderable);


--
-- Name: index_schema_version_properties_on_schema_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_version_properties_on_schema_definition_id ON public.schema_version_properties USING btree (schema_definition_id);


--
-- Name: index_schema_version_properties_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schema_version_properties_uniqueness ON public.schema_version_properties USING btree (schema_version_id, path);


--
-- Name: index_schema_versions_by_tuple; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_versions_by_tuple ON public.schema_versions USING btree (namespace, identifier);


--
-- Name: index_schema_versions_on_declaration; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schema_versions_on_declaration ON public.schema_versions USING btree (declaration);


--
-- Name: index_schema_versions_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_versions_on_kind ON public.schema_versions USING btree (kind);


--
-- Name: index_schema_versions_on_schema_definition_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_versions_on_schema_definition_id_and_position ON public.schema_versions USING btree (schema_definition_id, "position");


--
-- Name: index_schema_versions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schema_versions_uniqueness ON public.schema_versions USING btree (schema_definition_id, number);


--
-- Name: index_schematic_collected_references_on_referent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schematic_collected_references_on_referent ON public.schematic_collected_references USING btree (referent_type, referent_id);


--
-- Name: index_schematic_collected_references_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schematic_collected_references_ordering ON public.schematic_collected_references USING btree (referrer_type, referrer_id, path, "position");


--
-- Name: index_schematic_collected_references_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schematic_collected_references_uniqueness ON public.schematic_collected_references USING btree (referrer_type, referrer_id, referent_type, referent_id, path);


--
-- Name: index_schematic_scalar_references_on_referent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schematic_scalar_references_on_referent ON public.schematic_scalar_references USING btree (referent_type, referent_id);


--
-- Name: index_schematic_scalar_references_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schematic_scalar_references_uniqueness ON public.schematic_scalar_references USING btree (referrer_type, referrer_id, path);


--
-- Name: index_schematic_texts_entity_path_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schematic_texts_entity_path_uniqueness ON public.schematic_texts USING btree (entity_type, entity_id, path);


--
-- Name: index_schematic_texts_on_document; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schematic_texts_on_document ON public.schematic_texts USING gin (document);


--
-- Name: index_schematic_texts_on_schema_version_property_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schematic_texts_on_schema_version_property_id ON public.schematic_texts USING btree (schema_version_property_id);


--
-- Name: index_template_instance_digests_check; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_template_instance_digests_check ON public.templates_instance_digests USING btree (entity_type, entity_id, layout_definition_id, template_definition_id);


--
-- Name: index_templates_blurb_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_blurb_definitions_on_position ON public.templates_blurb_definitions USING btree ("position");


--
-- Name: index_templates_blurb_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_blurb_instances_on_entity ON public.templates_blurb_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_blurb_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_blurb_instances_on_generation ON public.templates_blurb_instances USING btree (generation);


--
-- Name: index_templates_blurb_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_blurb_instances_on_last_rendered_at ON public.templates_blurb_instances USING btree (last_rendered_at);


--
-- Name: index_templates_blurb_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_blurb_instances_on_position ON public.templates_blurb_instances USING btree ("position");


--
-- Name: index_templates_contributor_list_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_contributor_list_definitions_on_position ON public.templates_contributor_list_definitions USING btree ("position");


--
-- Name: index_templates_contributor_list_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_contributor_list_instances_on_entity ON public.templates_contributor_list_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_contributor_list_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_contributor_list_instances_on_generation ON public.templates_contributor_list_instances USING btree (generation);


--
-- Name: index_templates_contributor_list_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_contributor_list_instances_on_last_rendered_at ON public.templates_contributor_list_instances USING btree (last_rendered_at);


--
-- Name: index_templates_contributor_list_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_contributor_list_instances_on_position ON public.templates_contributor_list_instances USING btree ("position");


--
-- Name: index_templates_definition_digests_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_definition_digests_on_layout_definition ON public.templates_definition_digests USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_templates_definition_digests_on_template_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_templates_definition_digests_on_template_definition ON public.templates_definition_digests USING btree (template_definition_type, template_definition_id);


--
-- Name: index_templates_descendant_list_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_descendant_list_definitions_on_position ON public.templates_descendant_list_definitions USING btree ("position");


--
-- Name: index_templates_descendant_list_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_descendant_list_instances_on_entity ON public.templates_descendant_list_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_descendant_list_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_descendant_list_instances_on_generation ON public.templates_descendant_list_instances USING btree (generation);


--
-- Name: index_templates_descendant_list_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_descendant_list_instances_on_last_rendered_at ON public.templates_descendant_list_instances USING btree (last_rendered_at);


--
-- Name: index_templates_descendant_list_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_descendant_list_instances_on_position ON public.templates_descendant_list_instances USING btree ("position");


--
-- Name: index_templates_descendant_list_instances_see_all_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_descendant_list_instances_see_all_ordering ON public.templates_descendant_list_instances USING btree (see_all_ordering_id);


--
-- Name: index_templates_detail_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_detail_definitions_on_position ON public.templates_detail_definitions USING btree ("position");


--
-- Name: index_templates_detail_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_detail_instances_on_entity ON public.templates_detail_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_detail_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_detail_instances_on_generation ON public.templates_detail_instances USING btree (generation);


--
-- Name: index_templates_detail_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_detail_instances_on_last_rendered_at ON public.templates_detail_instances USING btree (last_rendered_at);


--
-- Name: index_templates_detail_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_detail_instances_on_position ON public.templates_detail_instances USING btree ("position");


--
-- Name: index_templates_hero_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_hero_definitions_on_position ON public.templates_hero_definitions USING btree ("position");


--
-- Name: index_templates_hero_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_hero_instances_on_entity ON public.templates_hero_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_hero_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_hero_instances_on_generation ON public.templates_hero_instances USING btree (generation);


--
-- Name: index_templates_hero_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_hero_instances_on_last_rendered_at ON public.templates_hero_instances USING btree (last_rendered_at);


--
-- Name: index_templates_hero_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_hero_instances_on_position ON public.templates_hero_instances USING btree ("position");


--
-- Name: index_templates_link_list_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_link_list_definitions_on_position ON public.templates_link_list_definitions USING btree ("position");


--
-- Name: index_templates_link_list_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_link_list_instances_on_entity ON public.templates_link_list_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_link_list_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_link_list_instances_on_generation ON public.templates_link_list_instances USING btree (generation);


--
-- Name: index_templates_link_list_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_link_list_instances_on_last_rendered_at ON public.templates_link_list_instances USING btree (last_rendered_at);


--
-- Name: index_templates_link_list_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_link_list_instances_on_position ON public.templates_link_list_instances USING btree ("position");


--
-- Name: index_templates_link_list_instances_see_all_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_link_list_instances_see_all_ordering ON public.templates_link_list_instances USING btree (see_all_ordering_id);


--
-- Name: index_templates_list_item_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_list_item_definitions_on_position ON public.templates_list_item_definitions USING btree ("position");


--
-- Name: index_templates_list_item_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_list_item_instances_on_entity ON public.templates_list_item_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_list_item_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_list_item_instances_on_generation ON public.templates_list_item_instances USING btree (generation);


--
-- Name: index_templates_list_item_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_list_item_instances_on_last_rendered_at ON public.templates_list_item_instances USING btree (last_rendered_at);


--
-- Name: index_templates_list_item_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_list_item_instances_on_position ON public.templates_list_item_instances USING btree ("position");


--
-- Name: index_templates_manual_list_entries_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_manual_list_entries_on_source ON public.templates_manual_list_entries USING btree (source_type, source_id);


--
-- Name: index_templates_manual_list_entries_on_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_manual_list_entries_on_target ON public.templates_manual_list_entries USING btree (target_type, target_id);


--
-- Name: index_templates_manual_lists_on_layout_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_manual_lists_on_layout_definition ON public.templates_manual_lists USING btree (layout_definition_type, layout_definition_id);


--
-- Name: index_templates_manual_lists_on_template_definition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_templates_manual_lists_on_template_definition ON public.templates_manual_lists USING btree (template_definition_type, template_definition_id);


--
-- Name: index_templates_metadata_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_metadata_definitions_on_position ON public.templates_metadata_definitions USING btree ("position");


--
-- Name: index_templates_metadata_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_metadata_instances_on_entity ON public.templates_metadata_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_metadata_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_metadata_instances_on_generation ON public.templates_metadata_instances USING btree (generation);


--
-- Name: index_templates_metadata_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_metadata_instances_on_last_rendered_at ON public.templates_metadata_instances USING btree (last_rendered_at);


--
-- Name: index_templates_metadata_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_metadata_instances_on_position ON public.templates_metadata_instances USING btree ("position");


--
-- Name: index_templates_navigation_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_navigation_definitions_on_position ON public.templates_navigation_definitions USING btree ("position");


--
-- Name: index_templates_navigation_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_navigation_instances_on_entity ON public.templates_navigation_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_navigation_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_navigation_instances_on_generation ON public.templates_navigation_instances USING btree (generation);


--
-- Name: index_templates_navigation_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_navigation_instances_on_last_rendered_at ON public.templates_navigation_instances USING btree (last_rendered_at);


--
-- Name: index_templates_navigation_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_navigation_instances_on_position ON public.templates_navigation_instances USING btree ("position");


--
-- Name: index_templates_ordering_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_definitions_on_position ON public.templates_ordering_definitions USING btree ("position");


--
-- Name: index_templates_ordering_instances_entry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_instances_entry ON public.templates_ordering_instances USING btree (ordering_id, ordering_entry_id);


--
-- Name: index_templates_ordering_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_instances_on_entity ON public.templates_ordering_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_ordering_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_instances_on_generation ON public.templates_ordering_instances USING btree (generation);


--
-- Name: index_templates_ordering_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_instances_on_last_rendered_at ON public.templates_ordering_instances USING btree (last_rendered_at);


--
-- Name: index_templates_ordering_instances_on_ordering_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_instances_on_ordering_id ON public.templates_ordering_instances USING btree (ordering_id);


--
-- Name: index_templates_ordering_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_ordering_instances_on_position ON public.templates_ordering_instances USING btree ("position");


--
-- Name: index_templates_page_list_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_page_list_definitions_on_position ON public.templates_page_list_definitions USING btree ("position");


--
-- Name: index_templates_page_list_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_page_list_instances_on_entity ON public.templates_page_list_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_page_list_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_page_list_instances_on_generation ON public.templates_page_list_instances USING btree (generation);


--
-- Name: index_templates_page_list_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_page_list_instances_on_last_rendered_at ON public.templates_page_list_instances USING btree (last_rendered_at);


--
-- Name: index_templates_page_list_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_page_list_instances_on_position ON public.templates_page_list_instances USING btree ("position");


--
-- Name: index_templates_supplementary_definitions_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_supplementary_definitions_on_position ON public.templates_supplementary_definitions USING btree ("position");


--
-- Name: index_templates_supplementary_instances_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_supplementary_instances_on_entity ON public.templates_supplementary_instances USING btree (entity_type, entity_id);


--
-- Name: index_templates_supplementary_instances_on_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_supplementary_instances_on_generation ON public.templates_supplementary_instances USING btree (generation);


--
-- Name: index_templates_supplementary_instances_on_last_rendered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_supplementary_instances_on_last_rendered_at ON public.templates_supplementary_instances USING btree (last_rendered_at);


--
-- Name: index_templates_supplementary_instances_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_supplementary_instances_on_position ON public.templates_supplementary_instances USING btree ("position");


--
-- Name: index_tuner_suggestions_on_report; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tuner_suggestions_on_report ON public.tuner_suggestions USING btree (report);


--
-- Name: index_user_group_memberships_on_user_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_group_memberships_on_user_group_id ON public.user_group_memberships USING btree (user_group_id);


--
-- Name: index_user_group_memberships_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_group_memberships_uniqueness ON public.user_group_memberships USING btree (user_id, user_group_id);


--
-- Name: index_user_groups_on_keycloak_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_groups_on_keycloak_id ON public.user_groups USING btree (keycloak_id);


--
-- Name: index_user_groups_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_groups_on_system_slug ON public.user_groups USING btree (system_slug);


--
-- Name: index_users_on_access_management; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_access_management ON public.users USING btree (access_management);


--
-- Name: index_users_on_allowed_actions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_allowed_actions ON public.users USING gist (allowed_actions);


--
-- Name: index_users_on_global_access_control_list; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_global_access_control_list ON public.users USING gin (global_access_control_list);


--
-- Name: index_users_on_keycloak_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_keycloak_id ON public.users USING btree (keycloak_id);


--
-- Name: index_users_on_role_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role_priority ON public.users USING btree (role_priority DESC);


--
-- Name: index_users_on_system_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_system_slug ON public.users USING btree (system_slug);


--
-- Name: index_users_prefix_searching_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_prefix_searching_names ON public.users USING gin (search_given_name public.gin_trgm_ops, search_family_name public.gin_trgm_ops);


--
-- Name: index_visits_by_country_and_region_codes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visits_by_country_and_region_codes ON public.ahoy_visits USING btree (country_code, region_code, id);


--
-- Name: item_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX item_anc_desc_idx ON public.item_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: item_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item_desc_idx ON public.item_hierarchies USING btree (descendant_id);


--
-- Name: legacy_index_harvest_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX legacy_index_harvest_records_uniqueness ON public.legacy_harvest_records USING btree (harvest_attempt_id, identifier);


--
-- Name: ordering_entry_counts_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ordering_entry_counts_pkey ON public.ordering_entry_counts USING btree (ordering_id);


--
-- Name: role_permissions_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX role_permissions_context ON public.role_permissions USING btree (role_id, permission_id, inferred, inferring_scopes);


--
-- Name: role_permissions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX role_permissions_uniqueness ON public.role_permissions USING btree (role_id, permission_id) INCLUDE (inferred, inferring_scopes, inferring_actions);


--
-- Name: schema_definition_properties_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX schema_definition_properties_pkey ON public.schema_definition_properties USING btree (schema_definition_id, path, type);


--
-- Name: udx_entity_derived_layout_definitions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_entity_derived_layout_definitions_uniqueness ON public.entity_derived_layout_definitions USING btree (entity_id, layout_kind);


--
-- Name: udx_layouts_hero_definitions_leaf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_hero_definitions_leaf ON public.layouts_hero_definitions USING btree (schema_version_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: udx_layouts_hero_definitions_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_hero_definitions_root ON public.layouts_hero_definitions USING btree (schema_version_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: udx_layouts_list_item_definitions_leaf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_list_item_definitions_leaf ON public.layouts_list_item_definitions USING btree (schema_version_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: udx_layouts_list_item_definitions_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_list_item_definitions_root ON public.layouts_list_item_definitions USING btree (schema_version_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: udx_layouts_main_definitions_leaf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_main_definitions_leaf ON public.layouts_main_definitions USING btree (schema_version_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: udx_layouts_main_definitions_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_main_definitions_root ON public.layouts_main_definitions USING btree (schema_version_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: udx_layouts_metadata_definitions_leaf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_metadata_definitions_leaf ON public.layouts_metadata_definitions USING btree (schema_version_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: udx_layouts_metadata_definitions_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_metadata_definitions_root ON public.layouts_metadata_definitions USING btree (schema_version_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: udx_layouts_navigation_definitions_leaf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_navigation_definitions_leaf ON public.layouts_navigation_definitions USING btree (schema_version_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: udx_layouts_navigation_definitions_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_navigation_definitions_root ON public.layouts_navigation_definitions USING btree (schema_version_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: udx_layouts_supplementary_definitions_leaf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_supplementary_definitions_leaf ON public.layouts_supplementary_definitions USING btree (schema_version_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: udx_layouts_supplementary_definitions_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX udx_layouts_supplementary_definitions_root ON public.layouts_supplementary_definitions USING btree (schema_version_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: authorizing_entities_hierarchical_stats; Type: STATISTICS; Schema: public; Owner: -
--

CREATE STATISTICS public.authorizing_entities_hierarchical_stats ON auth_path, hierarchical_type, hierarchical_id FROM public.authorizing_entities;


--
-- Name: ent_hierarchical_stats; Type: STATISTICS; Schema: public; Owner: -
--

CREATE STATISTICS public.ent_hierarchical_stats ON hierarchical_type, hierarchical_id, auth_path, scope FROM public.entities;


--
-- Name: entities_real_stats; Type: STATISTICS; Schema: public; Owner: -
--

CREATE STATISTICS public.entities_real_stats ON entity_type, entity_id, system_slug, auth_path, scope FROM public.entities;


--
-- Name: granted_permissions_rp_stats; Type: STATISTICS; Schema: public; Owner: -
--

CREATE STATISTICS public.granted_permissions_rp_stats ON permission_id, scope, action, role_id FROM public.granted_permissions;


--
-- Name: orderings_id_stats; Type: STATISTICS; Schema: public; Owner: -
--

CREATE STATISTICS public.orderings_id_stats ON entity_type, entity_id, identifier FROM public.orderings;


--
-- Name: role_permissions_rp_stats; Type: STATISTICS; Schema: public; Owner: -
--

CREATE STATISTICS public.role_permissions_rp_stats ON permission_id, role_id FROM public.role_permissions;


--
-- Name: schema_versions lock_version_definition_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lock_version_definition_id BEFORE UPDATE OF schema_definition_id ON public.schema_versions FOR EACH ROW WHEN ((old.schema_definition_id <> new.schema_definition_id)) EXECUTE FUNCTION public.prevent_column_update('schema_definition_id');


--
-- Name: entity_derived_layout_definitions edld_fk_entities; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_derived_layout_definitions
    ADD CONSTRAINT edld_fk_entities FOREIGN KEY (entity_type, entity_id) REFERENCES public.entities(entity_type, entity_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: entity_derived_layout_definitions edld_fk_ldh; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_derived_layout_definitions
    ADD CONSTRAINT edld_fk_ldh FOREIGN KEY (layout_definition_type, layout_definition_id) REFERENCES public.layout_definition_hierarchies(layout_definition_type, layout_definition_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: templates_navigation_instances fk_rails_0380b5f1ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_navigation_instances
    ADD CONSTRAINT fk_rails_0380b5f1ad FOREIGN KEY (template_definition_id) REFERENCES public.templates_navigation_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_mapping_record_links fk_rails_040e19d13d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_mapping_record_links
    ADD CONSTRAINT fk_rails_040e19d13d FOREIGN KEY (harvest_record_id) REFERENCES public.harvest_records(id) ON DELETE CASCADE;


--
-- Name: entity_search_documents fk_rails_0421c10e03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_search_documents
    ADD CONSTRAINT fk_rails_0421c10e03 FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: templates_navigation_instances fk_rails_05ddde0077; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_navigation_instances
    ADD CONSTRAINT fk_rails_05ddde0077 FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_navigation_instances(id) ON DELETE CASCADE;


--
-- Name: harvest_configurations fk_rails_077935b75c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_configurations
    ADD CONSTRAINT fk_rails_077935b75c FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: collection_linked_items fk_rails_08f9156aa0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_linked_items
    ADD CONSTRAINT fk_rails_08f9156aa0 FOREIGN KEY (source_id) REFERENCES public.collections(id) ON DELETE RESTRICT;


--
-- Name: assets fk_rails_091f138553; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT fk_rails_091f138553 FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: harvest_attempt_record_link_transitions fk_rails_0b568723ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_record_link_transitions
    ADD CONSTRAINT fk_rails_0b568723ae FOREIGN KEY (harvest_attempt_record_link_id) REFERENCES public.harvest_attempt_record_links(id) ON DELETE CASCADE;


--
-- Name: harvest_attempts fk_rails_0b61d27d1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempts
    ADD CONSTRAINT fk_rails_0b61d27d1a FOREIGN KEY (harvest_set_id) REFERENCES public.harvest_sets(id) ON DELETE CASCADE;


--
-- Name: layouts_metadata_instances fk_rails_0d9ab24a2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_metadata_instances
    ADD CONSTRAINT fk_rails_0d9ab24a2b FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_metadata_definitions(id) ON DELETE CASCADE;


--
-- Name: layouts_main_instances fk_rails_0e6bb1fad8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_main_instances
    ADD CONSTRAINT fk_rails_0e6bb1fad8 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_sets fk_rails_0f046d2238; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_sets
    ADD CONSTRAINT fk_rails_0f046d2238 FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: templates_page_list_instances fk_rails_0fd45e415a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_page_list_instances
    ADD CONSTRAINT fk_rails_0fd45e415a FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: harvest_attempt_record_links fk_rails_100239edde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_record_links
    ADD CONSTRAINT fk_rails_100239edde FOREIGN KEY (harvest_record_id) REFERENCES public.harvest_records(id) ON DELETE CASCADE;


--
-- Name: collections fk_rails_1036c77f58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_1036c77f58 FOREIGN KEY (schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE RESTRICT;


--
-- Name: layout_definition_hierarchies fk_rails_10918e2e3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout_definition_hierarchies
    ADD CONSTRAINT fk_rails_10918e2e3a FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: collection_links fk_rails_11a845b774; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_links
    ADD CONSTRAINT fk_rails_11a845b774 FOREIGN KEY (target_id) REFERENCES public.collections(id) ON DELETE RESTRICT;


--
-- Name: templates_page_list_definitions fk_rails_1245fb3453; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_page_list_definitions
    ADD CONSTRAINT fk_rails_1245fb3453 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: templates_hero_instances fk_rails_13ddf8a022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_hero_instances
    ADD CONSTRAINT fk_rails_13ddf8a022 FOREIGN KEY (template_definition_id) REFERENCES public.templates_hero_definitions(id) ON DELETE CASCADE;


--
-- Name: layouts_hero_definitions fk_rails_152bba3eee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_hero_definitions
    ADD CONSTRAINT fk_rails_152bba3eee FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: templates_link_list_definitions fk_rails_16eb4e2132; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_link_list_definitions
    ADD CONSTRAINT fk_rails_16eb4e2132 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_configurations fk_rails_18ac7e7431; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_configurations
    ADD CONSTRAINT fk_rails_18ac7e7431 FOREIGN KEY (harvest_mapping_id) REFERENCES public.harvest_mappings(id) ON DELETE SET NULL;


--
-- Name: contribution_role_configurations fk_rails_1a50c10011; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contribution_role_configurations
    ADD CONSTRAINT fk_rails_1a50c10011 FOREIGN KEY (default_item_id) REFERENCES public.controlled_vocabulary_items(id) ON DELETE RESTRICT;


--
-- Name: templates_blurb_definitions fk_rails_1a625c1710; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_blurb_definitions
    ADD CONSTRAINT fk_rails_1a625c1710 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: schema_version_properties fk_rails_1f31833d7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_properties
    ADD CONSTRAINT fk_rails_1f31833d7c FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: templates_descendant_list_definitions fk_rails_2293d53f73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_descendant_list_definitions
    ADD CONSTRAINT fk_rails_2293d53f73 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_attempt_entity_link_transitions fk_rails_248d27a3f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_entity_link_transitions
    ADD CONSTRAINT fk_rails_248d27a3f5 FOREIGN KEY (harvest_attempt_entity_link_id) REFERENCES public.harvest_attempt_entity_links(id) ON DELETE CASCADE;


--
-- Name: layouts_hero_instances fk_rails_269b9f8e18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_hero_instances
    ADD CONSTRAINT fk_rails_269b9f8e18 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_hero_definitions(id) ON DELETE CASCADE;


--
-- Name: entity_orderable_properties fk_rails_27196ff015; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_orderable_properties
    ADD CONSTRAINT fk_rails_27196ff015 FOREIGN KEY (schema_version_property_id) REFERENCES public.schema_version_properties(id) ON DELETE CASCADE;


--
-- Name: templates_metadata_instances fk_rails_28ca5fbc74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_metadata_instances
    ADD CONSTRAINT fk_rails_28ca5fbc74 FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_metadata_instances(id) ON DELETE CASCADE;


--
-- Name: templates_list_item_instances fk_rails_29224d5f0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_list_item_instances
    ADD CONSTRAINT fk_rails_29224d5f0a FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_list_item_instances(id) ON DELETE CASCADE;


--
-- Name: templates_hero_definitions fk_rails_29ff73dfc0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_hero_definitions
    ADD CONSTRAINT fk_rails_29ff73dfc0 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_hero_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_mapping_record_links fk_rails_2a011ee4ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_mapping_record_links
    ADD CONSTRAINT fk_rails_2a011ee4ff FOREIGN KEY (harvest_mapping_id) REFERENCES public.harvest_mappings(id) ON DELETE CASCADE;


--
-- Name: items fk_rails_2a18ad62a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_2a18ad62a0 FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE RESTRICT;


--
-- Name: access_grants fk_rails_2a8d9374ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT fk_rails_2a8d9374ca FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: community_memberships fk_rails_2acbed9229; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT fk_rails_2acbed9229 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: harvest_attempt_entity_links fk_rails_2bc66ea3bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_entity_links
    ADD CONSTRAINT fk_rails_2bc66ea3bd FOREIGN KEY (harvest_entity_id) REFERENCES public.harvest_entities(id) ON DELETE CASCADE;


--
-- Name: harvest_messages fk_rails_2e3a5f8f84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_messages
    ADD CONSTRAINT fk_rails_2e3a5f8f84 FOREIGN KEY (harvest_record_id) REFERENCES public.harvest_records(id) ON DELETE SET NULL;


--
-- Name: harvest_attempt_record_links fk_rails_2f9b9d6b4a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_record_links
    ADD CONSTRAINT fk_rails_2f9b9d6b4a FOREIGN KEY (harvest_attempt_id) REFERENCES public.harvest_attempts(id) ON DELETE CASCADE;


--
-- Name: ordering_entry_sibling_links fk_rails_33054f33ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_sibling_links
    ADD CONSTRAINT fk_rails_33054f33ac FOREIGN KEY (sibling_id) REFERENCES public.ordering_entries(id) ON DELETE CASCADE;


--
-- Name: layouts_supplementary_instances fk_rails_3358737399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_supplementary_instances
    ADD CONSTRAINT fk_rails_3358737399 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_supplementary_definitions(id) ON DELETE CASCADE;


--
-- Name: controlled_vocabulary_items fk_rails_34693393c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.controlled_vocabulary_items
    ADD CONSTRAINT fk_rails_34693393c7 FOREIGN KEY (controlled_vocabulary_id) REFERENCES public.controlled_vocabularies(id) ON DELETE CASCADE;


--
-- Name: entity_hierarchies fk_rails_352d828388; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_hierarchies
    ADD CONSTRAINT fk_rails_352d828388 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: items fk_rails_382f073cd8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_382f073cd8 FOREIGN KEY (schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE RESTRICT;


--
-- Name: templates_supplementary_instances fk_rails_38eff55817; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_supplementary_instances
    ADD CONSTRAINT fk_rails_38eff55817 FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_supplementary_instances(id) ON DELETE CASCADE;


--
-- Name: orderings fk_rails_3a24b6bb35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderings
    ADD CONSTRAINT fk_rails_3a24b6bb35 FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: request_timings fk_rails_3b0ac5b239; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_timings
    ADD CONSTRAINT fk_rails_3b0ac5b239 FOREIGN KEY (request_query_id) REFERENCES public.request_queries(id) ON DELETE CASCADE;


--
-- Name: ordering_entries fk_rails_3bfbf3b5c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entries
    ADD CONSTRAINT fk_rails_3bfbf3b5c9 FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE CASCADE;


--
-- Name: collection_links fk_rails_3cc144ad4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_links
    ADD CONSTRAINT fk_rails_3cc144ad4c FOREIGN KEY (source_id) REFERENCES public.collections(id) ON DELETE RESTRICT;


--
-- Name: harvest_records fk_rails_3d3164da92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_records
    ADD CONSTRAINT fk_rails_3d3164da92 FOREIGN KEY (harvest_configuration_id) REFERENCES public.harvest_configurations(id) ON DELETE SET NULL;


--
-- Name: harvest_attempts fk_rails_3e309e8f30; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempts
    ADD CONSTRAINT fk_rails_3e309e8f30 FOREIGN KEY (harvest_mapping_id) REFERENCES public.harvest_mappings(id) ON DELETE CASCADE;


--
-- Name: entities fk_rails_40b78347f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT fk_rails_40b78347f2 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE RESTRICT;


--
-- Name: harvest_messages fk_rails_41b2e21b60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_messages
    ADD CONSTRAINT fk_rails_41b2e21b60 FOREIGN KEY (harvest_attempt_id) REFERENCES public.harvest_attempts(id) ON DELETE SET NULL;


--
-- Name: user_group_memberships fk_rails_42022c51df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_memberships
    ADD CONSTRAINT fk_rails_42022c51df FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: role_permissions fk_rails_439e640a3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_rails_439e640a3f FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: access_grants fk_rails_45826fafdd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT fk_rails_45826fafdd FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: granted_permissions fk_rails_461469ccc7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.granted_permissions
    ADD CONSTRAINT fk_rails_461469ccc7 FOREIGN KEY (access_grant_id) REFERENCES public.access_grants(id) ON DELETE CASCADE;


--
-- Name: access_grants fk_rails_4cf2824701; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT fk_rails_4cf2824701 FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: templates_contributor_list_definitions fk_rails_4dd3d9f1db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_contributor_list_definitions
    ADD CONSTRAINT fk_rails_4dd3d9f1db FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: templates_navigation_definitions fk_rails_4ebbf856c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_navigation_definitions
    ADD CONSTRAINT fk_rails_4ebbf856c5 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_navigation_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_metadata_mappings fk_rails_4f6af7c2e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_metadata_mappings
    ADD CONSTRAINT fk_rails_4f6af7c2e4 FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: community_memberships fk_rails_5275a2ad88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT fk_rails_5275a2ad88 FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: controlled_vocabulary_sources fk_rails_52ce32d865; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.controlled_vocabulary_sources
    ADD CONSTRAINT fk_rails_52ce32d865 FOREIGN KEY (controlled_vocabulary_id) REFERENCES public.controlled_vocabularies(id) ON DELETE SET NULL;


--
-- Name: item_attributions fk_rails_53a0a2efb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_attributions
    ADD CONSTRAINT fk_rails_53a0a2efb6 FOREIGN KEY (contributor_id) REFERENCES public.contributors(id) ON DELETE CASCADE;


--
-- Name: templates_metadata_instances fk_rails_54e69d62be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_metadata_instances
    ADD CONSTRAINT fk_rails_54e69d62be FOREIGN KEY (template_definition_id) REFERENCES public.templates_metadata_definitions(id) ON DELETE CASCADE;


--
-- Name: access_grants fk_rails_55410f2ab3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT fk_rails_55410f2ab3 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: harvest_messages fk_rails_56c2e42f8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_messages
    ADD CONSTRAINT fk_rails_56c2e42f8c FOREIGN KEY (harvest_entity_id) REFERENCES public.harvest_entities(id) ON DELETE SET NULL;


--
-- Name: harvest_contributions fk_rails_57cba9c70f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributions
    ADD CONSTRAINT fk_rails_57cba9c70f FOREIGN KEY (harvest_contributor_id) REFERENCES public.harvest_contributors(id);


--
-- Name: harvest_set_record_links fk_rails_591ecb60c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_set_record_links
    ADD CONSTRAINT fk_rails_591ecb60c8 FOREIGN KEY (harvest_set_id) REFERENCES public.harvest_sets(id) ON DELETE CASCADE;


--
-- Name: templates_list_item_instances fk_rails_5a96c21277; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_list_item_instances
    ADD CONSTRAINT fk_rails_5a96c21277 FOREIGN KEY (template_definition_id) REFERENCES public.templates_list_item_definitions(id) ON DELETE CASCADE;


--
-- Name: item_attributions fk_rails_5d6b986800; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_attributions
    ADD CONSTRAINT fk_rails_5d6b986800 FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: layouts_supplementary_definitions fk_rails_5ecf3a7cc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_supplementary_definitions
    ADD CONSTRAINT fk_rails_5ecf3a7cc1 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: role_permissions fk_rails_60126080bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_rails_60126080bd FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: ordering_entry_sibling_links fk_rails_608f3a81e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_sibling_links
    ADD CONSTRAINT fk_rails_608f3a81e3 FOREIGN KEY (prev_id) REFERENCES public.ordering_entries(id) ON DELETE CASCADE;


--
-- Name: layouts_main_definitions fk_rails_61dd80f122; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_main_definitions
    ADD CONSTRAINT fk_rails_61dd80f122 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: ordering_entry_ancestor_links fk_rails_6337974632; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_ancestor_links
    ADD CONSTRAINT fk_rails_6337974632 FOREIGN KEY (ancestor_id) REFERENCES public.ordering_entries(id) ON DELETE CASCADE;


--
-- Name: harvest_mappings fk_rails_648247aee2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_mappings
    ADD CONSTRAINT fk_rails_648247aee2 FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: templates_detail_instances fk_rails_65e782e7f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_detail_instances
    ADD CONSTRAINT fk_rails_65e782e7f2 FOREIGN KEY (template_definition_id) REFERENCES public.templates_detail_definitions(id) ON DELETE CASCADE;


--
-- Name: item_links fk_rails_67a3fd259e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_links
    ADD CONSTRAINT fk_rails_67a3fd259e FOREIGN KEY (target_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: templates_descendant_list_instances fk_rails_681a91e75a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_descendant_list_instances
    ADD CONSTRAINT fk_rails_681a91e75a FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: entity_search_documents fk_rails_697e54eb95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_search_documents
    ADD CONSTRAINT fk_rails_697e54eb95 FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: orderings fk_rails_6ac675728d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderings
    ADD CONSTRAINT fk_rails_6ac675728d FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: entity_links fk_rails_6ad35546ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_6ad35546ca FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: communities fk_rails_6beda9a645; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT fk_rails_6beda9a645 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE RESTRICT;


--
-- Name: entity_links fk_rails_6c08f572dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_6c08f572dd FOREIGN KEY (source_item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: templates_hero_instances fk_rails_6d92b15d3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_hero_instances
    ADD CONSTRAINT fk_rails_6d92b15d3f FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_hero_instances(id) ON DELETE CASCADE;


--
-- Name: harvest_attempts fk_rails_6eb1b8ebed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempts
    ADD CONSTRAINT fk_rails_6eb1b8ebed FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: initial_ordering_links fk_rails_725f496dff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initial_ordering_links
    ADD CONSTRAINT fk_rails_725f496dff FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE CASCADE;


--
-- Name: item_contributions fk_rails_73af22b63e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_contributions
    ADD CONSTRAINT fk_rails_73af22b63e FOREIGN KEY (contributor_id) REFERENCES public.contributors(id);


--
-- Name: templates_list_item_definitions fk_rails_73f8774aa7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_list_item_definitions
    ADD CONSTRAINT fk_rails_73f8774aa7 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_list_item_definitions(id) ON DELETE CASCADE;


--
-- Name: assets fk_rails_747cd7500c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT fk_rails_747cd7500c FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE RESTRICT;


--
-- Name: schema_version_ancestors fk_rails_7549530172; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_ancestors
    ADD CONSTRAINT fk_rails_7549530172 FOREIGN KEY (target_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: entity_searchable_properties fk_rails_76fd135edc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_searchable_properties
    ADD CONSTRAINT fk_rails_76fd135edc FOREIGN KEY (schema_version_property_id) REFERENCES public.schema_version_properties(id) ON DELETE CASCADE;


--
-- Name: harvest_configurations fk_rails_77a58eedff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_configurations
    ADD CONSTRAINT fk_rails_77a58eedff FOREIGN KEY (harvest_set_id) REFERENCES public.harvest_sets(id) ON DELETE SET NULL;


--
-- Name: schema_version_properties fk_rails_77d4155820; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_properties
    ADD CONSTRAINT fk_rails_77d4155820 FOREIGN KEY (schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE CASCADE;


--
-- Name: ordering_entry_ancestor_links fk_rails_78654d0633; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_ancestor_links
    ADD CONSTRAINT fk_rails_78654d0633 FOREIGN KEY (child_id) REFERENCES public.ordering_entries(id) ON DELETE CASCADE;


--
-- Name: templates_supplementary_instances fk_rails_78822bf10c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_supplementary_instances
    ADD CONSTRAINT fk_rails_78822bf10c FOREIGN KEY (template_definition_id) REFERENCES public.templates_supplementary_definitions(id) ON DELETE CASCADE;


--
-- Name: granted_permissions fk_rails_79f89b52dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.granted_permissions
    ADD CONSTRAINT fk_rails_79f89b52dc FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: harvest_contributions fk_rails_7a0d956912; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributions
    ADD CONSTRAINT fk_rails_7a0d956912 FOREIGN KEY (harvest_entity_id) REFERENCES public.harvest_entities(id);


--
-- Name: legacy_harvest_records fk_rails_7d3cd534d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_harvest_records
    ADD CONSTRAINT fk_rails_7d3cd534d8 FOREIGN KEY (harvest_attempt_id) REFERENCES public.harvest_attempts(id) ON DELETE CASCADE;


--
-- Name: controlled_vocabulary_items fk_rails_7dc0c7e015; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.controlled_vocabulary_items
    ADD CONSTRAINT fk_rails_7dc0c7e015 FOREIGN KEY (parent_id) REFERENCES public.controlled_vocabulary_items(id) ON DELETE CASCADE;


--
-- Name: schema_versions fk_rails_7e7ef613db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_versions
    ADD CONSTRAINT fk_rails_7e7ef613db FOREIGN KEY (schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE CASCADE;


--
-- Name: collections fk_rails_7f2fd62be2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_7f2fd62be2 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE RESTRICT;


--
-- Name: collection_linked_items fk_rails_7fdede96da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_linked_items
    ADD CONSTRAINT fk_rails_7fdede96da FOREIGN KEY (target_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: templates_link_list_instances fk_rails_80199b8bb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_link_list_instances
    ADD CONSTRAINT fk_rails_80199b8bb1 FOREIGN KEY (see_all_ordering_id) REFERENCES public.orderings(id) ON DELETE SET NULL;


--
-- Name: ordering_invalidations fk_rails_80f155549c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_invalidations
    ADD CONSTRAINT fk_rails_80f155549c FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE CASCADE;


--
-- Name: entity_links fk_rails_8181666751; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_8181666751 FOREIGN KEY (target_item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: item_links fk_rails_818ba287b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_links
    ADD CONSTRAINT fk_rails_818ba287b7 FOREIGN KEY (source_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: entity_links fk_rails_81fdc77239; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_81fdc77239 FOREIGN KEY (source_collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: entity_derived_layout_definitions fk_rails_83800f1eec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_derived_layout_definitions
    ADD CONSTRAINT fk_rails_83800f1eec FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: communities fk_rails_840d8c73d5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT fk_rails_840d8c73d5 FOREIGN KEY (schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE RESTRICT;


--
-- Name: harvest_attempt_entity_links fk_rails_8a7bd3f12f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_entity_links
    ADD CONSTRAINT fk_rails_8a7bd3f12f FOREIGN KEY (harvest_record_id) REFERENCES public.harvest_records(id) ON DELETE CASCADE;


--
-- Name: community_memberships fk_rails_8bbf2ace3c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT fk_rails_8bbf2ace3c FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: templates_ordering_instances fk_rails_930e8b2e8f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_instances
    ADD CONSTRAINT fk_rails_930e8b2e8f FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: contribution_role_configurations fk_rails_934d649642; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contribution_role_configurations
    ADD CONSTRAINT fk_rails_934d649642 FOREIGN KEY (other_item_id) REFERENCES public.controlled_vocabulary_items(id) ON DELETE RESTRICT;


--
-- Name: harvest_entities fk_rails_96a93b8164; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_entities
    ADD CONSTRAINT fk_rails_96a93b8164 FOREIGN KEY (harvest_record_id) REFERENCES public.harvest_records(id) ON DELETE CASCADE;


--
-- Name: layouts_navigation_instances fk_rails_97fb76a4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_navigation_instances
    ADD CONSTRAINT fk_rails_97fb76a4f0 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_navigation_definitions(id) ON DELETE CASCADE;


--
-- Name: collection_contributions fk_rails_9955c93f4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_contributions
    ADD CONSTRAINT fk_rails_9955c93f4b FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: rendering_template_logs fk_rails_999be8ce67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendering_template_logs
    ADD CONSTRAINT fk_rails_999be8ce67 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: templates_contributor_list_instances fk_rails_99a28e74ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_contributor_list_instances
    ADD CONSTRAINT fk_rails_99a28e74ee FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: layouts_navigation_definitions fk_rails_9b1ab50bc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_navigation_definitions
    ADD CONSTRAINT fk_rails_9b1ab50bc6 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: templates_metadata_definitions fk_rails_a00acbf090; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_metadata_definitions
    ADD CONSTRAINT fk_rails_a00acbf090 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_metadata_definitions(id) ON DELETE CASCADE;


--
-- Name: ahoy_events fk_rails_a0df956a8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events
    ADD CONSTRAINT fk_rails_a0df956a8d FOREIGN KEY (visit_id) REFERENCES public.ahoy_visits(id) ON DELETE CASCADE;


--
-- Name: harvest_entities fk_rails_a1262d403c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_entities
    ADD CONSTRAINT fk_rails_a1262d403c FOREIGN KEY (parent_id) REFERENCES public.harvest_entities(id) ON DELETE CASCADE;


--
-- Name: rendering_entity_logs fk_rails_a308826dd8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendering_entity_logs
    ADD CONSTRAINT fk_rails_a308826dd8 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: collections fk_rails_a32ec34749; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_a32ec34749 FOREIGN KEY (parent_id) REFERENCES public.collections(id) ON DELETE RESTRICT;


--
-- Name: items fk_rails_a5b4e81110; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_a5b4e81110 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE RESTRICT;


--
-- Name: contribution_role_configurations fk_rails_a7327c6253; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contribution_role_configurations
    ADD CONSTRAINT fk_rails_a7327c6253 FOREIGN KEY (controlled_vocabulary_id) REFERENCES public.controlled_vocabularies(id) ON DELETE RESTRICT;


--
-- Name: harvest_records fk_rails_a7da2091db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_records
    ADD CONSTRAINT fk_rails_a7da2091db FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: assets fk_rails_a8a9ebb434; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT fk_rails_a8a9ebb434 FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE RESTRICT;


--
-- Name: harvest_attempt_transitions fk_rails_abb01db8f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_transitions
    ADD CONSTRAINT fk_rails_abb01db8f3 FOREIGN KEY (harvest_attempt_id) REFERENCES public.harvest_attempts(id) ON DELETE CASCADE;


--
-- Name: item_contributions fk_rails_ad054be81e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_contributions
    ADD CONSTRAINT fk_rails_ad054be81e FOREIGN KEY (role_id) REFERENCES public.controlled_vocabulary_items(id) ON DELETE RESTRICT;


--
-- Name: user_group_memberships fk_rails_aece7151f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_memberships
    ADD CONSTRAINT fk_rails_aece7151f8 FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON DELETE CASCADE;


--
-- Name: templates_blurb_instances fk_rails_afc21fc6b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_blurb_instances
    ADD CONSTRAINT fk_rails_afc21fc6b2 FOREIGN KEY (template_definition_id) REFERENCES public.templates_blurb_definitions(id) ON DELETE CASCADE;


--
-- Name: schema_version_associations fk_rails_b2a9ef07e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_associations
    ADD CONSTRAINT fk_rails_b2a9ef07e9 FOREIGN KEY (source_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: ordering_entry_ancestor_links fk_rails_b38b560010; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_ancestor_links
    ADD CONSTRAINT fk_rails_b38b560010 FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE CASCADE;


--
-- Name: harvest_entities fk_rails_b601edda92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_entities
    ADD CONSTRAINT fk_rails_b601edda92 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE RESTRICT;


--
-- Name: harvest_contributors fk_rails_b607efe09d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributors
    ADD CONSTRAINT fk_rails_b607efe09d FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: entity_links fk_rails_b6e9726cfa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_b6e9726cfa FOREIGN KEY (target_community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: access_grants fk_rails_b889c8e828; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT fk_rails_b889c8e828 FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id) ON DELETE CASCADE;


--
-- Name: rendering_layout_logs fk_rails_bb56b45520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rendering_layout_logs
    ADD CONSTRAINT fk_rails_bb56b45520 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: layouts_list_item_definitions fk_rails_bbeb9cb947; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_list_item_definitions
    ADD CONSTRAINT fk_rails_bbeb9cb947 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: harvest_configurations fk_rails_bfa1e91ba7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_configurations
    ADD CONSTRAINT fk_rails_bfa1e91ba7 FOREIGN KEY (harvest_attempt_id) REFERENCES public.harvest_attempts(id) ON DELETE SET NULL;


--
-- Name: templates_detail_definitions fk_rails_c02b6c7bef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_detail_definitions
    ADD CONSTRAINT fk_rails_c02b6c7bef FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: orderings fk_rails_c09738b6c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderings
    ADD CONSTRAINT fk_rails_c09738b6c8 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: entity_hierarchies fk_rails_c2be56f2ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_hierarchies
    ADD CONSTRAINT fk_rails_c2be56f2ad FOREIGN KEY (schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE CASCADE;


--
-- Name: layouts_list_item_instances fk_rails_c42661f077; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_list_item_instances
    ADD CONSTRAINT fk_rails_c42661f077 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_list_item_definitions(id) ON DELETE CASCADE;


--
-- Name: templates_blurb_instances fk_rails_c45a8f037b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_blurb_instances
    ADD CONSTRAINT fk_rails_c45a8f037b FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: templates_descendant_list_instances fk_rails_c4a01d56d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_descendant_list_instances
    ADD CONSTRAINT fk_rails_c4a01d56d6 FOREIGN KEY (template_definition_id) REFERENCES public.templates_descendant_list_definitions(id) ON DELETE CASCADE;


--
-- Name: collection_contributions fk_rails_c5801bead3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_contributions
    ADD CONSTRAINT fk_rails_c5801bead3 FOREIGN KEY (role_id) REFERENCES public.controlled_vocabulary_items(id) ON DELETE RESTRICT;


--
-- Name: schema_version_associations fk_rails_c9a308a9e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_associations
    ADD CONSTRAINT fk_rails_c9a308a9e8 FOREIGN KEY (target_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: ordering_entry_sibling_links fk_rails_cba05c50c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_sibling_links
    ADD CONSTRAINT fk_rails_cba05c50c2 FOREIGN KEY (next_id) REFERENCES public.ordering_entries(id) ON DELETE CASCADE;


--
-- Name: harvest_contributors fk_rails_cbaeac6363; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributors
    ADD CONSTRAINT fk_rails_cbaeac6363 FOREIGN KEY (contributor_id) REFERENCES public.contributors(id) ON DELETE SET NULL;


--
-- Name: templates_link_list_instances fk_rails_cd4f3060a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_link_list_instances
    ADD CONSTRAINT fk_rails_cd4f3060a6 FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: assets fk_rails_ce34fffb9d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT fk_rails_ce34fffb9d FOREIGN KEY (parent_id) REFERENCES public.assets(id) ON DELETE RESTRICT;


--
-- Name: templates_contributor_list_instances fk_rails_cf282c6438; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_contributor_list_instances
    ADD CONSTRAINT fk_rails_cf282c6438 FOREIGN KEY (template_definition_id) REFERENCES public.templates_contributor_list_definitions(id) ON DELETE CASCADE;


--
-- Name: granted_permissions fk_rails_d060f47715; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.granted_permissions
    ADD CONSTRAINT fk_rails_d060f47715 FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: templates_list_item_instances fk_rails_d1a7c8116b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_list_item_instances
    ADD CONSTRAINT fk_rails_d1a7c8116b FOREIGN KEY (see_all_ordering_id) REFERENCES public.orderings(id) ON DELETE SET NULL;


--
-- Name: templates_detail_instances fk_rails_d243ae43dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_detail_instances
    ADD CONSTRAINT fk_rails_d243ae43dd FOREIGN KEY (layout_instance_id) REFERENCES public.layouts_main_instances(id) ON DELETE CASCADE;


--
-- Name: schema_version_ancestors fk_rails_d355266964; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_version_ancestors
    ADD CONSTRAINT fk_rails_d355266964 FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: templates_supplementary_definitions fk_rails_d49809ac3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_supplementary_definitions
    ADD CONSTRAINT fk_rails_d49809ac3e FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_supplementary_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_messages fk_rails_d539ba1589; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_messages
    ADD CONSTRAINT fk_rails_d539ba1589 FOREIGN KEY (harvest_source_id) REFERENCES public.harvest_sources(id) ON DELETE CASCADE;


--
-- Name: orderings fk_rails_d762d1c80c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderings
    ADD CONSTRAINT fk_rails_d762d1c80c FOREIGN KEY (handled_schema_definition_id) REFERENCES public.schema_definitions(id) ON DELETE CASCADE;


--
-- Name: collection_attributions fk_rails_d870ec7ace; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_attributions
    ADD CONSTRAINT fk_rails_d870ec7ace FOREIGN KEY (contributor_id) REFERENCES public.contributors(id) ON DELETE CASCADE;


--
-- Name: access_grants fk_rails_d9b8218fcb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_grants
    ADD CONSTRAINT fk_rails_d9b8218fcb FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: schematic_texts fk_rails_da1d1a5a10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schematic_texts
    ADD CONSTRAINT fk_rails_da1d1a5a10 FOREIGN KEY (schema_version_property_id) REFERENCES public.schema_version_properties(id) ON DELETE CASCADE;


--
-- Name: ahoy_visits fk_rails_db648022ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_visits
    ADD CONSTRAINT fk_rails_db648022ad FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: harvest_mappings fk_rails_dc2ccde798; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_mappings
    ADD CONSTRAINT fk_rails_dc2ccde798 FOREIGN KEY (harvest_set_id) REFERENCES public.harvest_sets(id) ON DELETE RESTRICT;


--
-- Name: granted_permissions fk_rails_de1e7295ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.granted_permissions
    ADD CONSTRAINT fk_rails_de1e7295ac FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: layouts_metadata_definitions fk_rails_df56b1f30a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layouts_metadata_definitions
    ADD CONSTRAINT fk_rails_df56b1f30a FOREIGN KEY (schema_version_id) REFERENCES public.schema_versions(id) ON DELETE CASCADE;


--
-- Name: templates_link_list_instances fk_rails_e0b0772553; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_link_list_instances
    ADD CONSTRAINT fk_rails_e0b0772553 FOREIGN KEY (template_definition_id) REFERENCES public.templates_link_list_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_cached_asset_references fk_rails_e10303fa2f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_cached_asset_references
    ADD CONSTRAINT fk_rails_e10303fa2f FOREIGN KEY (harvest_cached_asset_id) REFERENCES public.harvest_cached_assets(id) ON DELETE CASCADE;


--
-- Name: templates_descendant_list_instances fk_rails_e502dd111b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_descendant_list_instances
    ADD CONSTRAINT fk_rails_e502dd111b FOREIGN KEY (see_all_ordering_id) REFERENCES public.orderings(id) ON DELETE SET NULL;


--
-- Name: templates_ordering_definitions fk_rails_e611341ed0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_definitions
    ADD CONSTRAINT fk_rails_e611341ed0 FOREIGN KEY (layout_definition_id) REFERENCES public.layouts_main_definitions(id) ON DELETE CASCADE;


--
-- Name: authorizing_entities fk_rails_e81ba90b04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorizing_entities
    ADD CONSTRAINT fk_rails_e81ba90b04 FOREIGN KEY (entity_id) REFERENCES public.entities(id) ON DELETE CASCADE;


--
-- Name: named_variable_dates fk_rails_e9a6036ded; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.named_variable_dates
    ADD CONSTRAINT fk_rails_e9a6036ded FOREIGN KEY (schema_version_property_id) REFERENCES public.schema_version_properties(id) ON DELETE SET NULL;


--
-- Name: fake_visitors fk_rails_ea98e13842; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fake_visitors
    ADD CONSTRAINT fk_rails_ea98e13842 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: entity_links fk_rails_eabc9b5139; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_eabc9b5139 FOREIGN KEY (target_collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: item_contributions fk_rails_eca0986480; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_contributions
    ADD CONSTRAINT fk_rails_eca0986480 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: items fk_rails_ed5bf219ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_ed5bf219ac FOREIGN KEY (parent_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: entity_search_documents fk_rails_ef6c9b8d10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_search_documents
    ADD CONSTRAINT fk_rails_ef6c9b8d10 FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: templates_ordering_instances fk_rails_f141ddb5b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_instances
    ADD CONSTRAINT fk_rails_f141ddb5b6 FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE SET NULL;


--
-- Name: ordering_entry_sibling_links fk_rails_f1e293a713; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordering_entry_sibling_links
    ADD CONSTRAINT fk_rails_f1e293a713 FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE CASCADE;


--
-- Name: ahoy_events fk_rails_f1ed9fc4a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events
    ADD CONSTRAINT fk_rails_f1ed9fc4a0 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: collection_contributions fk_rails_f2db32c240; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_contributions
    ADD CONSTRAINT fk_rails_f2db32c240 FOREIGN KEY (contributor_id) REFERENCES public.contributors(id);


--
-- Name: templates_ordering_instances fk_rails_f315024259; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_instances
    ADD CONSTRAINT fk_rails_f315024259 FOREIGN KEY (template_definition_id) REFERENCES public.templates_ordering_definitions(id) ON DELETE CASCADE;


--
-- Name: entity_links fk_rails_f54d4f5cb3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT fk_rails_f54d4f5cb3 FOREIGN KEY (source_community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: collection_attributions fk_rails_f57c9589dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_attributions
    ADD CONSTRAINT fk_rails_f57c9589dd FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: harvest_contributions fk_rails_f6afda3b44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_contributions
    ADD CONSTRAINT fk_rails_f6afda3b44 FOREIGN KEY (role_id) REFERENCES public.controlled_vocabulary_items(id) ON DELETE RESTRICT;


--
-- Name: harvest_set_record_links fk_rails_f75e1d22da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_set_record_links
    ADD CONSTRAINT fk_rails_f75e1d22da FOREIGN KEY (harvest_record_id) REFERENCES public.harvest_records(id) ON DELETE CASCADE;


--
-- Name: templates_page_list_instances fk_rails_f8800717b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_page_list_instances
    ADD CONSTRAINT fk_rails_f8800717b5 FOREIGN KEY (template_definition_id) REFERENCES public.templates_page_list_definitions(id) ON DELETE CASCADE;


--
-- Name: harvest_attempt_entity_links fk_rails_fab3db3c84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_attempt_entity_links
    ADD CONSTRAINT fk_rails_fab3db3c84 FOREIGN KEY (harvest_attempt_id) REFERENCES public.harvest_attempts(id) ON DELETE CASCADE;


--
-- Name: initial_ordering_selections fk_rails_fb3fc2b564; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initial_ordering_selections
    ADD CONSTRAINT fk_rails_fb3fc2b564 FOREIGN KEY (ordering_id) REFERENCES public.orderings(id) ON DELETE CASCADE;


--
-- Name: harvest_messages fk_rails_fb5520bb9b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.harvest_messages
    ADD CONSTRAINT fk_rails_fb5520bb9b FOREIGN KEY (harvest_mapping_id) REFERENCES public.harvest_mappings(id) ON DELETE SET NULL;


--
-- Name: orderings fk_rails_fb64dd7c38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderings
    ADD CONSTRAINT fk_rails_fb64dd7c38 FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: collections fk_rails_ff82e7b8d0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT fk_rails_ff82e7b8d0 FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE RESTRICT;


--
-- Name: templates_ordering_instances ordering_instance_entry_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates_ordering_instances
    ADD CONSTRAINT ordering_instance_entry_fk FOREIGN KEY (ordering_entry_id) REFERENCES public.ordering_entries(id) ON DELETE SET NULL (ordering_entry_id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20251008224630'),
('20251008224043'),
('20251008180200'),
('20250911164517'),
('20250910180725'),
('20250808225252'),
('20250808225236'),
('20250808170318'),
('20250808170302'),
('20250808162608'),
('20250807202326'),
('20250806224428'),
('20250730184809'),
('20250709172917'),
('20250703003427'),
('20250702225216'),
('20250702223625'),
('20250702223014'),
('20250702222307'),
('20250702214523'),
('20250702173558'),
('20250702173522'),
('20250701223926'),
('20250701212826'),
('20250701212623'),
('20250701165933'),
('20250611201949'),
('20250609210232'),
('20250505195133'),
('20250505182825'),
('20250505180140'),
('20250429192158'),
('20250408163159'),
('20250408162405'),
('20250317201446'),
('20250317193746'),
('20250311200045'),
('20250307191006'),
('20250306232956'),
('20250306220745'),
('20250306211149'),
('20250306204816'),
('20250306181146'),
('20250303205929'),
('20250303193456'),
('20250227200415'),
('20250226140405'),
('20250226140356'),
('20250226140355'),
('20250226140354'),
('20250226140353'),
('20250224203941'),
('20250224193443'),
('20250221180403'),
('20250221172515'),
('20250220221139'),
('20250219234712'),
('20250219225500'),
('20250218011515'),
('20250217215855'),
('20250207184954'),
('20250206232440'),
('20250206231834'),
('20250206231134'),
('20250206183714'),
('20250205231244'),
('20250205025649'),
('20250205024007'),
('20250129171943'),
('20250129171809'),
('20250117193744'),
('20250117193735'),
('20250114204917'),
('20250114204050'),
('20250114203526'),
('20250108190032'),
('20250107212233'),
('20250107205521'),
('20250107202700'),
('20250107201204'),
('20250107183852'),
('20241217203803'),
('20241217175502'),
('20241217175355'),
('20241205225757'),
('20241205194208'),
('20241204230232'),
('20241119165014'),
('20241113212205'),
('20241105174753'),
('20241105174558'),
('20241104221045'),
('20241024210601'),
('20241021161712'),
('20241018223753'),
('20241017174753'),
('20241009214736'),
('20240919170725'),
('20240917183334'),
('20240807162748'),
('20240701194303'),
('20240620215406'),
('20240618202411'),
('20240618202125'),
('20240618201518'),
('20240322084261'),
('20240322084260'),
('20240322084259'),
('20240322084258'),
('20240322084257'),
('20240322084256'),
('20240322084255'),
('20240322084254'),
('20240322084253'),
('20240322084252'),
('20240223144805'),
('20221012175221'),
('20221012160517'),
('20220915084147'),
('20220915020155'),
('20220912193952'),
('20220909184024'),
('20220908194547'),
('20220706164702'),
('20220628184617'),
('20220628184601'),
('20220627205514'),
('20220621170232'),
('20220617164554'),
('20220616001209'),
('20220615234049'),
('20220609235453'),
('20220609224200'),
('20220609161910'),
('20220609161857'),
('20220608003418'),
('20220608001957'),
('20220607230810'),
('20220607230041'),
('20220607211431'),
('20220607175341'),
('20220405210816'),
('20220405205111'),
('20220403150025'),
('20220328194136'),
('20220328181949'),
('20220325202253'),
('20220325152848'),
('20220323130711'),
('20220312044145'),
('20220312031343'),
('20220312003650'),
('20220312001049'),
('20220312000402'),
('20220309222458'),
('20220309205537'),
('20220308173141'),
('20220304214235'),
('20220303221906'),
('20220303220515'),
('20220221184512'),
('20220221160509'),
('20220221151923'),
('20220221150645'),
('20220218194143'),
('20220218193540'),
('20220216203224'),
('20220216150516'),
('20220214202309'),
('20220113044849'),
('20220112232400'),
('20220112215903'),
('20220110182540'),
('20220108054327'),
('20220107021523'),
('20220106184920'),
('20220106182503'),
('20220106181423'),
('20220105041448'),
('20220104185903'),
('20220103194312'),
('20211221054949'),
('20211221040948'),
('20211221040913'),
('20211221012913'),
('20211220173609'),
('20211216192600'),
('20211215202155'),
('20211215021446'),
('20211215020817'),
('20211215010843'),
('20211215001920'),
('20211215001720'),
('20211215001414'),
('20211214234914'),
('20211214172204'),
('20211211045110'),
('20211211033841'),
('20211211024506'),
('20211211022308'),
('20211211022216'),
('20211210200825'),
('20211209180555'),
('20211208020200'),
('20211203210512'),
('20211203210440'),
('20211202195122'),
('20211202013847'),
('20211202011224'),
('20211201182458'),
('20211124164728'),
('20211124013249'),
('20211123235058'),
('20211123211418'),
('20211110171716'),
('20211028180614'),
('20211028000854'),
('20211028000811'),
('20211027003925'),
('20211025193642'),
('20211025181924'),
('20211025041435'),
('20211021224948'),
('20211021224524'),
('20211021194549'),
('20211021190227'),
('20211019011930'),
('20211018235750'),
('20211018224246'),
('20211015191701'),
('20211015191012'),
('20211014234854'),
('20211014170459'),
('20211013235624'),
('20211013195329'),
('20211013193041'),
('20211013192548'),
('20211012220943'),
('20211012220659'),
('20211012214418'),
('20211005183352'),
('20211005160744'),
('20210913191623'),
('20210730191337'),
('20210730183719'),
('20210730182534'),
('20210730170535'),
('20210730165659'),
('20210730165055'),
('20210723204008'),
('20210720192518'),
('20210720192446'),
('20210720182529'),
('20210720182059'),
('20210720164944'),
('20210719160950'),
('20210715163909'),
('20210622224648'),
('20210612202131'),
('20210612191855'),
('20210612183500'),
('20210611172811'),
('20210611171455'),
('20210611171346'),
('20210611170915'),
('20210611170719'),
('20210611164947'),
('20210611164648'),
('20210611162913'),
('20210611162848'),
('20210611162020'),
('20210527225127'),
('20210526250050'),
('20210526213652'),
('20210526205224'),
('20210526196331'),
('20210526195425'),
('20210526193105'),
('20210526172947'),
('20210525151834'),
('20210525151826'),
('20210525151755'),
('20210521132542'),
('20210519201212'),
('20210519201206'),
('20210514175833'),
('20210514175749'),
('20210514175612'),
('20210514160917'),
('20210513141949'),
('20210513141936'),
('20210513141534'),
('20210513131220'),
('20210513131104'),
('20210513010953'),
('20210513005944'),
('20210504152025'),
('20210504151248'),
('20210428222916'),
('20210428222857');

