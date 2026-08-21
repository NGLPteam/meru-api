# frozen_string_literal: true

module ImageAttachments
  class ModelIntegration < Support::SimpleDerivedModule
    param :attachment_name, Types::AttachmentName

    after_initialize :generate_methods!

    def included(base)
      super

      base.delegate :alt, :graphql_metadata, to: attachment_name, prefix: attachment_name, allow_nil: true
    end

    private

    # @return [void]
    def generate_methods!
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
      def #{attachment_name}_metadata
        #{attachment_name}&.graphql_metadata
      end

      def #{attachment_name}_metadata=(new_metadata)
        #{attachment_name}&.merge_graphql_metadata! new_metadata
      end
      RUBY
    end
  end
end
