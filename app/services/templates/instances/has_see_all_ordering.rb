# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Definitions::HasSeeAllOrdering
    # @see Types::TemplateHasSeeAllOrderingType
    module HasSeeAllOrdering
      extend ActiveSupport::Concern
      extend DefinesMonadicOperation

      include RecordPreloading

      included do
        belongs_to_readonly :see_all_ordering, class_name: "Ordering", optional: true

        before_validation :infer_see_all_ordering!
      end

      # @api private
      # @return [void]
      def infer_see_all_ordering!
        self.see_all_ordering = entity.ordering(template_definition.see_all_ordering_identifier)
      end

      module ClassMethods
        def preloaded_for_record_loading
          super.includes(:see_all_ordering)
        end
      end
    end
  end
end
