# frozen_string_literal: true

module Harvesting
  module Extraction
    module LiquidTags
      # A Liquid tag that captures elements and builds a {Harvesting::Contributor::Proxy}.
      # @abstract
      class AbstractContributorCaptor < Harvesting::Extraction::LiquidTags::AbstractBlock
        include Dry::Effects::Handler.State(:contributor)
        include Dry::Effects::Handler.State(:contributor_kind)
        include Dry::Effects::Handler.State(:contributor_properties)
        include Dry::Effects::Handler.State(:tracked_attributes)
        include Dry::Effects::Handler.State(:tracked_properties)
        include Dry::Effects.State(:contribution)

        defines :contributor_kind, type: ::Contributors::Types::Kind.optional

        contributor_kind nil

        def render(context)
          raise Liquid::ContextError, "Contributor already set for this contribution" if contribution.has_contributor?

          contribution.contributor = contributor = Harvesting::Contributors::Proxy.new(kind: contributor_kind)

          capture_contributor!(contributor:) do
            super
          end

          return ""
        end

        private

        # @return [::Contributors::OrganizationProperties]
        # @return [::Contributors::PersonProperties]
        def build_contributor_properties
          case contributor_kind
          when :organization
            ::Contributors::OrganizationProperties.new
          when :person
            ::Contributors::PersonProperties.new
          else
            # simplecov:disable
            raise "Unset contributor property kind"
            # simplecov:enable
          end
        end

        # @param [Harvesting::Contributors::Proxy] contributor
        # @param [::Contributors::OrganizationProperties, ::Contributors::PersonProperties] properties
        # @return [::Contributors::Properties]
        def build_wrapped_properties(contributor, properties)
          ::Contributors::Properties.new.tap do |wrapped|
            wrapped.parent = contributor

            wrapped.__send__(:"#{contributor_kind}=", properties)
          end
        end

        # @!attribute [r] contributor_kind
        # @return [Contributors::Kinds::Type]
        def contributor_kind
          self.class.contributor_kind
        end

        def capture_contributor!(contributor:)
          properties = build_contributor_properties

          tracked_attributes = []
          tracked_properties = []

          with_contributor contributor do
            with_contributor_kind contributor_kind do
              with_contributor_properties properties do
                with_tracked_attributes tracked_attributes do
                  with_tracked_properties tracked_properties do
                    yield
                  end
                end
              end
            end
          end

          # simplecov:disable
          contributor.identifier = properties.digest unless contributor.identifier.present?
          # simplecov:enable

          contributor.properties = build_wrapped_properties(contributor, properties)
          contributor.tracked_attributes = normalize_tracked(tracked_attributes)
          contributor.tracked_properties = normalize_tracked(tracked_properties)
        end

        def normalize_tracked(value)
          Array(value).map(&:to_s).uniq.sort.freeze
        end
      end
    end
  end
end
