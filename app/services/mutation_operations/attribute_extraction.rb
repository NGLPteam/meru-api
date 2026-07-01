# frozen_string_literal: true

module MutationOperations
  module AttributeExtraction
    extend ActiveSupport::Concern

    include MutationOperations::Contracts

    included do
      delegate :attribute_assigner, to: :class
    end

    # @see MutationOperations::AttributeAssigner#call
    def assign_attributes!(model, **args)
      attribute_assigner.call model, **args
    end

    module ClassMethods
      # @param [Symbol] name
      # @param [{ Symbol => Object }] options
      # @option options [Boolean] :image
      # @return [void]
      def attachment!(name, **options)
        attribute = Attachments::Attribute.new name, **options

        previous = attachments[name]

        if previous.present?
          # simplecov:disable
          warn "Overwriting #{self.class}.attachment #{attribute.name}"

          applicable_contracts.delete previous.contract
          # simplecov:enable
        end

        attachments[name] = attribute

        use_contract! attribute.contract

        rebuild_attribute_assigner!
      end

      # @api private
      # @return [{ Symbol => MutationOperations::Attachments::Attribute }]
      def attachments
        @attachments ||= {}
      end

      # @api private
      # @return [<MutationOperations::Attachments::Attribute>]
      def attachment_attributes
        attachments.values
      end

      # @api private
      # @return [MutationOperations::AttributeAssigner]
      def attribute_assigner
        @attribute_assigner ||= build_attribute_assigner
      end

      private

      # @return [MutationOperations::AttributeAssigner]
      def build_attribute_assigner
        AttributeAssigner.new attachments: attachment_attributes
      end

      # @return [void]
      def rebuild_attribute_assigner!
        @attribute_assigner = build_attribute_assigner
      end
    end
  end
end
