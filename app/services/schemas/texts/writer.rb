# frozen_string_literal: true

module Schemas
  module Texts
    # Maintain {SchematicText} records for a {HierarchicalEntity}.
    #
    # This will compile both core and schematic text references
    # into a single query, also taking care of pruning any orphaned
    # references that should no longer exist.
    #
    # @see Schemas::Texts::Write
    class Writer < Support::HookBased::Actor
      include QueryOperation

      include Dry::Initializer[undefined: false].define -> do
        param :entity, Schemas::Types::Entity

        option :context, Schemas::Types.Instance(::Schemas::Properties::Context), default: proc { entity.read_property_context }
      end

      standard_execution!

      delegate :id, to: :entity, prefix: true

      # Core entity properties that get serialized into {SchematicText}
      # records with specific weights.
      #
      # @note The "tagline" property is only on {Community} records.
      # @return [<(Symbol, String)>]
      CORE_TEXTS = [
        [:title, ?A],
        [:subtitle, ?B],
        [:tagline, ?B],
        [:summary, ?C],
      ].freeze

      MERGE_QUERY = <<~SQL
      WITH derived_texts AS (
        %{source_query}
      )
      MERGE INTO schematic_texts AS target
      USING derived_texts AS source
      ON
        target.entity_type = source.entity_type
        AND
        target.entity_id = source.entity_id
        AND
        target.path = source.path
      WHEN MATCHED AND (
        target.content IS DISTINCT FROM source.content
        OR
        target.lang IS DISTINCT FROM source.lang
        OR
        target.kind IS DISTINCT FROM source.kind
        OR
        target.weight <> source.weight
        OR
        target.text_content IS DISTINCT FROM source.text_content
        OR
        target.dictionary <> source.dictionary
        OR
        target.schema_version_property_id IS DISTINCT FROM source.schema_version_property_id
      ) THEN UPDATE SET
        content = source.content,
        lang = source.lang,
        kind = source.kind,
        weight = source.weight,
        text_content = source.text_content,
        dictionary = source.dictionary,
        schema_version_property_id = source.schema_version_property_id,
        updated_at = CURRENT_TIMESTAMP
      WHEN NOT MATCHED BY TARGET THEN
        INSERT (entity_type, entity_id, path, content, lang, kind, weight, text_content, dictionary, schema_version_property_id, created_at, updated_at)
        VALUES (source.entity_type, source.entity_id, source.path, source.content, source.lang, source.kind, source.weight, source.text_content, source.dictionary, source.schema_version_property_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      WHEN NOT MATCHED BY SOURCE AND target.entity_id = %{entity_id} THEN
        DELETE
      ;
      SQL

      # @return [Hash]
      attr_reader :base_row

      # Markdown paths are not really to be used anymore,
      # but legacy schema versions may still have them
      # and we need to treat them like a full text.
      #
      # @return [<String>]
      attr_reader :markdown_paths

      # @return [{ String => { Symbol => String } }]
      attr_reader :property_mapping

      # @return [<Hash>]
      attr_reader :rows

      # @return [SchemaVersion]
      attr_reader :schema_version

      # @return [Dry::Monads::Success(HierarchicalEntity)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield build_rows!

          yield build_merge_query!

          yield execute_merge_query!
        end

        Success entity
      end

      wrapped_hook! def prepare
        @base_row = entity.to_entity_pair.freeze

        @query = nil

        @rows = []

        prepare_properties!

        super
      end

      wrapped_hook! def build_rows
        add_core_rows!

        add_markdown_rows!

        add_full_text_rows!

        super
      end

      wrapped_hook! def build_merge_query
        source_query = ::Utility::ValueSelectQuery.new(
          rows,
          model_class: SchematicText,
        )

        query_options = {
          source_query: source_query.to_sql,
          entity_id: ApplicationRecord.connection.quote(entity_id)
        }

        @query = MERGE_QUERY % query_options
      end

      wrapped_hook! def execute_merge_query
        sql_insert! @query

        super
      end

      private

      # @return [void]
      def add_core_rows!
        CORE_TEXTS.each do |(attr, weight)|
          add_core_row! attr, weight
        end
      end

      # @return [void]
      def add_markdown_rows!
        markdown_paths.each do |path|
          content = context.value_at(path)

          add_row!(path, content:, kind: "markdown", weight: ?D)
        end
      end

      # @return [void]
      def add_full_text_rows!
        context.full_texts.each do |path, raw|
          reference = MeruAPI::Container["full_text.normalizer"].(raw)

          add_row!(path, **reference)
        end
      end

      # @param [Symbol] attr
      # @param ["A", "B", "C", "D"] weight
      # @return [void]
      def add_core_row!(attr, weight)
        return unless entity.respond_to?(attr)

        content = Sanitize.fragment(entity.public_send(attr))

        path = "$#{attr}$"

        add_row!(path, content:, lang: "en", kind: "text", weight:)
      end

      # @param [String] path
      # @param [String] content
      # @param [String, nil] lang
      # @param ["text", "markdown", "html"] kind
      # @param ["A", "B", "C", "D"] weight
      # @return [void]
      def add_row!(path, content:, lang: nil, kind: "text", weight: ?D, **)
        return if content.blank?

        dictionary = dictionary_for(lang)

        text_content = text_content_for(content, kind)

        schema_version_property_id = property_mapping.dig(path, :id)

        row = base_row.merge(
          path:,
          content:,
          lang:,
          kind:,
          weight:,
          text_content:,
          dictionary:,
          schema_version_property_id:,
        )

        rows << row
      end

      # @return [{ String => { Symbol => String } }]
      def calculate_property_mapping
        schema_version.schema_version_properties.pluck(:path, :id, :type).to_h do |path, id, type|
          [path, { id:, type: }]
        end
      end

      # @param [String] lang
      def dictionary_for(lang) = MeruAPI::Container["full_text.derive_dictionary"].call(lang)

      # @return [void]
      def prepare_properties!
        @schema_version = entity.schema_version

        @property_mapping = schema_version.schema_version_properties.pluck(:path, :id, :type).to_h do |path, id, type|
          [path, { id:, type: }]
        end

        @markdown_paths = property_mapping.each_with_object([]) do |(path, mapping), arr|
          arr << path if mapping[:type] == "markdown"
        end
      end

      # @param [String] content
      # @param ["text", "markdown", "html"] kind
      # @return [String, nil]
      def text_content_for(content, kind) = MeruAPI::Container["full_text.extract_text_content"].call(content:, kind:)
    end
  end
end
