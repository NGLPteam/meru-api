# frozen_string_literal: true

module Harvesting
  module Extraction
    module LiquidTags
      module Contributors
        # @abstract
        class AbstractPropertyCaptor < Harvesting::Extraction::LiquidTags::Contributors::AbstractAttributeCaptor
          include Dry::Effects.State(:contributor_kind)
          include Dry::Effects.State(:contributor_properties)

          defines :contributor_kind_limit, type: ::Contributors::Types::Kind.optional

          contributor_kind_limit nil

          private

          def assign_value!(context)
            contributor_properties[self.class.attr_name] = parse_value_from(context)
          end

          # @return [void]
          def check!
            super

            raise Liquid::ContextError, "must only be rendered within a #{contributor_kind_limit}" unless contributor_kind_matches?
          end

          # @!attribute [r] contributor_kind_limit
          # @return [Contributors::Kinds::Type, nil]
          def contributor_kind_limit
            self.class.contributor_kind_limit
          end

          def contributor_kind_matches?
            # simplecov:disable
            return true if contributor_kind_limit.blank?
            # simplecov:enable

            contributor_kind_limit == contributor_kind
          end

          # @return [void]
          def track!
            tracked_properties << self.class.attr_name
          end

          class << self
            # @param [Contributors::Types::Kind] contributor_kind
            # @return [void]
            def only_for!(contributor_kind)
              contributor_kind_limit contributor_kind
            end
          end
        end
      end
    end
  end
end
