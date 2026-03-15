# frozen_string_literal: true

module Schemas
  module Properties
    module References
      # A schematic reference to a single model.
      #
      # @see SchematicCollectedReference
      module Collected
        extend ActiveSupport::Concern

        include Schemas::Properties::References::Model
        include Schemas::Properties::Scalar::ValidatesSizeSanity

        # The maximum amount of references. A simple, small number to start.
        MAX_SIZE = 20

        included do
          array! :model?

          attribute :min_size, :integer, default: 0

          attribute :max_size, :integer, default: MAX_SIZE

          validates :min_size, :max_size, presence: true

          validates :min_size, numericality: {
            integer_only: true,
            greater_than_or_equal_to: 0,
            less_than: MAX_SIZE
          }

          validates :max_size, numericality: {
            integer_only: true,
            greater_than: 1,
            less_than_or_equal_to: MAX_SIZE
          }
        end

        def extract_raw_value_from(context)
          context.collected_reference(full_path)
        end

        def write_values_within!(context)
          context.write_collected_references! path
        end
      end
    end
  end
end
