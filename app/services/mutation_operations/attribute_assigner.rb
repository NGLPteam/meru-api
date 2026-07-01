# frozen_string_literal: true

module MutationOperations
  # @api private
  class AttributeAssigner
    include Dry::Initializer[undefined: false].define -> do
      option :attachments, ::Support::GlobalTypes::Array.of(::Support::GlobalTypes.Instance(MutationOperations::Attachments::Attribute))
    end

    # @param [ApplicationRecord] model
    # @param [{ Symbol => Object }] args
    # @return [ApplicationRecord]
    def call(model, **args)
      attributes = process_attachments_for model, **args

      model.assign_attributes(attributes)

      return model
    end

    private

    # @see MutationOperations::Attachments::Attribute#assign!
    # @param [ApplicationRecord] model
    # @param [{ Symbol => Object }] args
    # @return [{ Symbol => Object }]
    def process_attachments_for(model, **args)
      # simplecov:disable
      return args if attachments.blank?
      # simplecov:enable

      attachments.each do |attachment|
        # NOTE: this will mutate `args`
        attachment.assign! model, args
      end

      return args # remaining attributes
    end
  end
end
