# frozen_string_literal: true

module Processing
  # A module that is included with {Processing::ModelIntegration.register_shrine_attachment!}.
  #
  # It sets up scopes and named methods for the attachment.
  class RegisteredAttachment < Support::SimpleDerivedModule
    include DefinesMonadicOperation

    param :attachment_name, Types::AttachmentName

    after_initialize :generate_methods!

    def included(base)
      super

      attachment_name = self.attachment_name

      base.scope :"with_attached_#{attachment_name}", -> { with_shrine_attachment(attachment_name) }
      base.scope :"with_stored_#{attachment_name}", -> { with_stored_shrine_attachment(attachment_name) }
      base.scope :"with_cached_#{attachment_name}", -> { with_cached_shrine_attachment(attachment_name) }
      base.scope :"sans_attached_#{attachment_name}", -> { sans_shrine_attachment(attachment_name) }
      base.scope :"sans_stored_#{attachment_name}", -> { sans_stored_shrine_attachment(attachment_name) }
      base.scope :"sans_cached_#{attachment_name}", -> { sans_cached_shrine_attachment(attachment_name) }
    end

    private

    # @return [void]
    def generate_methods!
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
      monadic_operation! def promote_#{attachment_name}(**options)
        promote_attachment(:#{attachment_name}, **options)
      end

      monadic_operation! def refresh_#{attachment_name}_derivatives(**options)
        refresh_attachment_derivatives(:#{attachment_name}, **options)
      end

      monadic_operation! def refresh_#{attachment_name}_metadata
        refresh_attachment_metadata(:#{attachment_name})
      end

      monadic_operation! def reprocess_#{attachment_name}(**options)
        reprocess_attachment(:#{attachment_name}, **options)
      end

      monadic_operation! def retry_promoting_#{attachment_name}
        retry_promoting_attachment(:#{attachment_name})
      end
      RUBY
    end
  end
end
