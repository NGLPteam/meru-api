# frozen_string_literal: true

module Support
  module StatesmanHelpers
    module Transition
      extend ActiveSupport::Concern

      included do
        extend Dry::Core::ClassAttributes

        defines :owner_association_name, :transitions_association_name, type: Support::StatesmanHelpers::Types::AssociationName

        after_destroy :update_most_recent!, if: :most_recent?
      end

      # @!attribute [r] owner_association
      # @return [ActiveRecord::Base]
      def owner_association
        __send__(owner_association_name)
      end

      # @!attribute [r] owner_association_name
      # @return [Symbol]
      def owner_association_name
        self.class.owner_association_name
      end

      # @return [ActiveRecord::Relation<Support::StatesmanHelpers::Transition>]
      def parent_transitions
        owner_association.__send__(transitions_association_name)
      end

      # @!attribute [r] transitions_association_name
      # @return [Symbol]
      def transitions_association_name
        self.class.transitions_association_name
      end

      private

      # @return [void]
      def update_most_recent!
        last_transition = parent_transitions.order(sort_key: :desc).first

        return if last_transition.blank?

        last_transition.update_column(:most_recent, true)
      end
    end
  end
end
