# frozen_string_literal: true

module Support
  module GQL
    # @abstract For input objects that represent filtering options.
    # @see Support::Filtering::DefaultScope
    class BaseFilterScopeInputObject < Support::GQL::BaseInputObject
      # @return [Support::Filtering::DefaultScope, nil]
      def prepare
        options = to_h.symbolize_keys.compact.presence

        # :nocov:
        return nil if options.nil?
        # :nocov:

        self.class.filter_scope.new(**options)
      end

      class << self
        # @return [Class(Support::Filtering::DefaultScope)]
        attr_reader :filter_scope

        # @param [Class(Support::Filtering::DefaultScope)] filter_scope
        # @return [void]
        def inherit_from!(filter_scope)
          @filter_scope = filter_scope
        end
      end
    end
  end
end
