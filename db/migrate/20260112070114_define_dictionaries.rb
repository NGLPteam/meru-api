# frozen_string_literal: true

class DefineDictionaries < ActiveRecord::Migration[7.2]
  def change
    # limited subset of `select * from pg_catalog.pg_ts_config;`
    create_enum :meru_dictionary, %w[simple english]

    reversible do |dir|
      dir.up do
        execute <<~SQL
        CREATE FUNCTION public.meru_dictionary_to_regconfig(public.meru_dictionary) RETURNS regconfig AS $$
        SELECT CASE $1
          WHEN 'simple' THEN 'simple'::regconfig
          WHEN 'english' THEN 'english'::regconfig
          ELSE 'simple'::regconfig
        END;
        $$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;

        CREATE FUNCTION public.meru_safe_dictionary(text) RETURNS public.meru_dictionary AS $$
        SELECT CASE $1
          WHEN 'simple' THEN 'simple'::public.meru_dictionary
          WHEN 'english' THEN 'english'::public.meru_dictionary
          ELSE 'simple'::public.meru_dictionary
        END;
        $$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;

        CREATE FUNCTION public.meru_tsvector(public.meru_dictionary, text, public.full_text_weight) RETURNS tsvector AS $$
        SELECT pg_catalog.setweight(pg_catalog.to_tsvector(public.meru_dictionary_to_regconfig($1), $2), $3::"char");
        $$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;

        CREATE FUNCTION public.meru_tsvector(public.meru_dictionary, text) RETURNS tsvector AS $$
        SELECT public.meru_tsvector($1, $2, 'D'::public.full_text_weight);
        $$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;

        CREATE FUNCTION public.meru_tsvector(text) RETURNS tsvector AS $$
        SELECT public.meru_tsvector('english'::public.meru_dictionary, $1, 'D'::public.full_text_weight);
        $$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;
        SQL
      end

      dir.down do
        execute <<~SQL
        DROP FUNCTION public.meru_tsvector(text);
        DROP FUNCTION public.meru_tsvector(public.meru_dictionary, text);
        DROP FUNCTION public.meru_tsvector(public.meru_dictionary, text, public.full_text_weight);
        DROP FUNCTION public.meru_safe_dictionary(text);
        DROP FUNCTION public.meru_dictionary_to_regconfig(public.meru_dictionary);
        SQL
      end
    end
  end
end
