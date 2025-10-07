# frozen_string_literal: true

module Harvesting
  module Extraction
    module Mappings
      module Props
        class ControlledVocabulary < Harvesting::Extraction::Mappings::Props::Base
          include Dry::Matcher.for(:lookup_item, with: Dry::Matcher::ResultMatcher)

          attribute :fallback, :string
          attribute :namespace, :string
          attribute :identifier, :string
          attribute :term, :string
          attribute :wants, :string

          render_attr! :fallback, :string
          render_attr! :namespace, :string
          render_attr! :identifier, :string
          render_attr! :term, :string
          render_attr! :wants, :string

          xml do
            root "controlled-vocabulary"

            map_attribute "wants", to: :wants

            map_element "namespace", to: :namespace

            map_element "identifier", to: :identifier

            map_element "term", to: :term
          end

          def build_property_value_with(**subproperties)
            lookup_item(**subproperties) do |m|
              m.success do |item|
                Dry::Monads.Success(item.to_gid.to_s)
              end

              m.failure(:no_vocabulary) do |_, query|
                logger.error("No controlled vocabulary found for query: #{query}", **subproperties)

                Dry::Monads.Success(nil)
              end

              m.failure(:no_match) do |_, term, fallback|
                if term.present? || fallback.present?
                  # :nocov:
                  logger.warn("No controlled vocabulary item found for term: #{term.inspect} (nor fallback: #{fallback.inspect})", **subproperties)
                  # :nocov:
                end

                Dry::Monads.Success(nil)
              end

              m.failure do
                # :nocov:
                logger.error("Unexpected failure looking up controlled vocabulary item", **subproperties)

                Dry::Monads.Success(nil)
                # :nocov:
              end
            end
          end

          def lookup_item(**subproperties)
            call_operation("controlled_vocabularies.lookup", **subproperties)
          end
        end
      end
    end
  end
end
