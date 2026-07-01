# frozen_string_literal: true

module Harvesting
  module Entities
    # A struct of attributes and properties that have been built from
    # {Harvesting::Extraction::Mappings::Entities::Abstract}.
    class Struct
      extend ActiveModel::Callbacks

      include ActiveModel::Validations
      include Harvesting::Middleware::ProvidesHarvestData
      include Harvesting::WithLogger
      include Dry::Initializer[undefined: false].define -> do
        param :render_context, ::Harvesting::Types.Instance(::Harvesting::Extraction::RenderContext)
        param :entity_mapping, ::Harvesting::Types.Instance(::Harvesting::Extraction::Mappings::Entities::Abstract)

        option :parent, ::Harvesting::Types.Instance(::Harvesting::Entities::Struct).optional, optional: true
      end

      define_model_callbacks :render

      delegate :harvest_record, to: :render_context

      delegate :root?, :schema_identifier, to: :entity_mapping

      # @return [Harvesting::Entities::ExtractedAttributes]
      attr_reader :attributes

      alias extracted_attributes attributes

      # @return [<Harvesting::Entities::Struct>]
      attr_reader :children

      # @return [<Harvesting::Contributions::Proxy>]
      attr_reader :contributions

      # @return [::Entities::Types::ChildEntityKind]
      attr_accessor :entity_kind

      # @return [String]
      attr_accessor :identifier

      delegate *Harvesting::Entities::ExtractedAttributes.accessors, to: :attributes

      # @return [Boolean]
      attr_reader :rendered

      alias rendered? rendered

      # @return [Hash]
      attr_reader :scalar_assets

      # @return [SchemaVersion, nil]
      attr_reader :schema_version

      # Only applicable when root.
      #
      # @return [Hash]
      attr_reader :metadata_mappings_match

      validates :identifier, :schema_version, :title, presence: true

      around_render :provide_harvest_record!

      after_render :render_children!

      def initialize(...)
        super

        @rendered = false

        @metadata_mappings_match = {}

        @entity_kind = entity_mapping.entity_kind

        @attributes = Harvesting::Entities::ExtractedAttributes.new
        @children = []
        @contributions = []
        @props = ::Support::PropertyHash.new
        @assets = {}
        @entity_assets = Harvesting::Assets::EntityMapping.new
        @incoming_collections = []
        @scalar_assets = {}
        @collected_assets = {}
        @schema_version = nil

        render!
      end

      # @param [HarvestEntity] harvest_entity
      def assign_to!(harvest_entity)
        harvest_entity.assign_attributes to_harvest_entity_attributes
      end

      def has_metadata_mappings_match?
        @metadata_mappings_match.present?
      end

      private

      # @return [void]
      def render!
        run_callbacks :render do
          find_schema_version!

          render_metadata_mappings_match!

          render_attributes!

          render_properties!

          extract_contributions!
        end

        @rendered = true
      end

      # @return [void]
      def extract_contributions!
        return unless entity_mapping.has_contributions?

        handle_render! "contributions", entity_mapping.contributions.render_for(render_context) do |proxies|
          @contributions.concat(proxies)
        end
      ensure
        @contributions.freeze
      end

      # @return [void]
      def render_children!
        child_structs = entity_mapping.render_child_structs_for(render_context, parent: self)

        @children.concat child_structs
      end

      # @return [void]
      def find_schema_version!
        @schema_version = SchemaVersion[schema_identifier]
      rescue ActiveRecord::RecordNotFound
        # simplecov:disable
        logger.error "Could not find schema version: #{schema_identifier}"
        # simplecov:enable
      end

      # @return [void]
      def render_metadata_mappings_match!
        return unless entity_mapping.has_metadata_mapping?

        @metadata_mappings_match.merge! entity_mapping.metadata_mapping.value_for(render_context)

        @metadata_mappings_match.freeze
      end

      # @return [void]
      def render_attributes!
        entity_mapping.rendered_attributes_for(render_context).each do |name, result|
          render_attribute! name, result
        end
      end

      # @param [String] name the name of the attribute to assign
      # @param [Dry::Monads::Result] result
      # @return [self]
      def render_attribute!(name, result)
        handle_render! name, result do |value|
          case name
          when /\A(?<image>hero_image|logo|thumbnail)_remote_url\z/
            identifier = Regexp.last_match[:image]

            @entity_assets.assign_remote_url identifier, value
          else
            public_send(:"#{name}=", value)
          end
        end
      end

      def render_properties!
        entity_mapping.properties.each do |full_path, property_mapping|
          render_property! full_path, property_mapping.render_value_for(render_context)
        end
      end

      # @param [String] full_path
      # @param [Dry::Monads::Result] result
      # @return [void]
      def render_property!(full_path, result)
        handle_render! full_path, result do |value|
          case value
          when ::Harvesting::Extraction::Properties::AssetProxy
            scalar_asset_for! value
          else
            @props[full_path] = value
          end
        end
      end

      # @param [String] path
      # @param [Dry::Monads::Result] result
      # @return [void]
      def handle_render!(path, result)
        prefix = "Failed to render `#{path}`"

        Dry::Matcher::ResultMatcher.call result do |m|
          m.success do |value|
            yield value
          end

          m.failure(:cannot_coerce) do |_, message|
            logger.error "#{prefix}: #{message}", path:, tags: %w[value_coercion]
          end

          m.failure(:cannot_render) do |_, res|
            res.errors.each do |err|
              err.write_log!(prefix:, path:)
            end
          end

          m.failure(:properties_failed) do |_, errors|
            errors.each(&:write_log!)
          end

          m.failure(:properties_invalid) do |_, warnings|
            warnings.each(&:write_log!)

            logger.debug "#{prefix}: skipped because of warnings", tags: %w[properties_invalid]
          end

          m.failure do |*probs|
            # simplecov:disable
            logger.error "#{prefix}: Something went wrong", path:
            # simplecov:enable
          end
        end
      end

      def to_asset_source(identifier, url, name: nil, mime_type: nil)
        {
          identifier:,
          url:,
          name:,
          mime_type:
        }.compact
      end

      # @!group Harvest Entity Assignment Helpers

      def to_harvest_entity_attributes
        {
          entity_kind:,
          extracted_attributes:,
          extracted_properties:,
          extracted_assets:,
          extracted_links:,
          schema_version:,
        }
      end

      # @return [Hash]
      def extracted_properties
        @props.to_h
      end

      # @return [Hash]
      def extracted_assets
        scalar = @scalar_assets.each_with_object([]) do |(full_path, asset), ary|
          ref = { full_path:, asset: }

          ary << ref
        end

        collected = @collected_assets.each_with_object([]) do |(full_path, assets), ary|
          ref = { full_path:, assets: }

          ary << ref
        end

        {
          entity: @entity_assets,
          unassociated: @assets.values,
          scalar:,
          collected:,
        }
      end

      # @return [Hash]
      def extracted_links
        {
          incoming_collections: @incoming_collections,
        }
      end

      # @!endgroup

      # @!group Linkage helpers

      # @note Not yet re-implemented
      # @param [String] identifier
      # @param ["contains", "references"] operator
      # @return [self]
      def link_collection!(identifier, operator: "contains")
        @incoming_collections << Harvesting::Links::Source.new(identifier:, operator:)

        return self
      end

      # @!endgroup

      # @!group Asset Helpers

      # @note Not yet re-implemented
      # @return [self]
      def unassociated_asset!(identifier, url, **props)
        @assets[identifier] = to_asset_source(identifier, url, **props)

        return self
      end

      # @param [Harvesting::Extraction::Properties::AssetProxy] asset_proxy
      # @return [self]
      def scalar_asset_for!(asset_proxy)
        @scalar_assets[asset_proxy.full_path] = to_asset_source(asset_proxy.identifier, asset_proxy.url, **asset_proxy.props)

        return self
      end

      # @!endgroup
    end
  end
end
