# frozen_string_literal: true

module Harvesting
  module Extraction
    module Mappings
      module Entities
        # @abstract
        class Abstract < Harvesting::Extraction::Mappings::Abstract
          defines :entity_kind, type: ::Entities::Types::ChildEntityKind
          defines :root, type: ::Entities::Types::Bool

          entity_kind "collection"

          root false

          attribute :requirements, Harvesting::Extraction::Mappings::Entities::Requirements

          attribute :schema_identifier, :string

          attribute :identifier, :string

          attribute :title, :string

          attribute :subtitle, :string

          attribute :summary, :string

          attribute :doi, :string

          attribute :published, :string

          attribute :hero_image_remote_url, :string

          attribute :thumbnail_remote_url, :string

          attribute :contributions, Harvesting::Extraction::Mappings::Entities::Contributions

          attribute :property_list, Harvesting::Extraction::Mappings::SchemaProperties

          render_attr! :identifier, :string

          render_attr! :title, :string
          render_attr! :subtitle, :string
          render_attr! :summary, :string

          render_attr! :doi, :doi do |result|
            result.output.to_s.presence
          end

          render_attr! :published, :variable_date

          render_attr! :hero_image_remote_url, :url
          render_attr! :thumbnail_remote_url, :url

          xml do
            map_element "requires", to: :requirements

            map_attribute "schema", to: :schema_identifier

            map_element "identifier", to: :identifier
            map_element "title", to: :title
            map_element "subtitle", to: :subtitle
            map_element "summary", to: :summary

            map_element "doi", to: :doi
            map_element "published", to: :published
            map_element "hero-image-url", to: :hero_image_remote_url
            map_element "thumbnail-url", to: :thumbnail_remote_url

            map_element "contributions", to: :contributions
            map_element "properties", to: :property_list
          end

          # @return [::Entities::Types::ChildEntityKind]
          def entity_kind
            self.class.entity_kind
          end

          def has_contributions?
            contributions.present?
          end

          def has_metadata_mapping?
            root? && metadata_mapping.present?
          end

          # @return [{ String => Harvesting::Extraction::Mappings::Props::Base }]
          def properties
            @properties ||= property_list.try(:props) || EMPTY_HASH
          end

          def root?
            self.class.root
          end

          # @param [Harvesting::Extraction::RenderContext] render_context
          # @param [Harvesting::Entities::Struct, nil] parent
          # @return [Harvesting::Entities::Struct]
          def render_struct_for(render_context, parent: nil)
            return unless requirements_met?(render_context)

            ::Harvesting::Entities::Struct.new(render_context, self, parent:)
          end

          # @param [Harvesting::Extraction::RenderContext] render_context
          # @param [Harvesting::Entities::Struct] parent
          # @return [<Harvesting::Entities::Struct>]
          def render_child_structs_for(render_context, parent:)
            [].tap do |structs|
              if respond_to?(:enumerations)
                structs.concat(enumerations.flat_map { _1.render_structs_for(render_context, parent:) })
              end

              if respond_to?(:collections)
                structs.concat(collections.map { _1.render_struct_for(render_context, parent:) })
              end

              if respond_to?(:items)
                structs.concat(items.map { _1.render_struct_for(render_context, parent:) })
              end
            end.compact # remove any child structs whose requirements were not met
          end

          def requirements_met?(render_context)
            requirements.blank? || requirements.met?(render_context)
          end

          # @return [<String>]
          def schema_declarations
            [*try(:collections), *try(:items)].compact.reduce([schema_identifier]) do |d, ent|
              d | ent.schema_declarations
            end
          end

          class << self
            # @param [::Entities::Types::ChildEntityKind] kind
            # @return [void]
            def entity_kind!(kind)
              kind = ::Entities::Types::ChildEntityKind[kind]

              entity_kind kind
            end
          end
        end
      end
    end
  end
end
