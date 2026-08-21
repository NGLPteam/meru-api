# frozen_string_literal: true

module Processing
  # @see Processing::PromoteAttachment
  # @see Processing::PromoteAttachmentJob
  class AttachmentPromoter < Processing::Actor
    param :model, Types::Model

    param :name, Types::AttachmentName

    option :file_data, Types::AttachmentData, default: proc { model.shrine_file_data_for(name) }

    # @return [Shrine::Attacher]
    attr_reader :attacher

    # @return [Dry::Monads::Success(ApplicationRecord)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield promote!
      end

      Success model
    end

    wrapped_hook! def prepare
      @attacher = Shrine::Attacher.retrieve(model:, name:, file: file_data)

      super
    end

    wrapped_hook! def promote
      attacher.atomic_promote(metadata: true)

      super
    end
  end
end
