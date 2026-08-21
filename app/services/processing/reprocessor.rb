# frozen_string_literal: true

module Processing
  # @see Processing::RefreshDerivatives
  # @see Processing::RefreshMetadata
  # @see Processing::Reprocess
  class Reprocessor < Processing::Actor
    param :model, Types::Model

    param :name, Types::AttachmentName

    option :derivatives, Types::Bool, default: proc { true }

    option :metadata, Types::Bool, default: proc { true }

    # @return [Shrine::Attacher]
    attr_reader :attacher

    # @return [Dry::Monads::Success(ApplicationRecord)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield refresh!
      end

      Success model
    end

    wrapped_hook! def prepare
      @attacher = model.shrine_attacher_for(name)

      super
    end

    wrapped_hook! def refresh
      attacher.file.open do
        attacher.refresh_metadata! if metadata
        attacher.create_derivatives(attacher.file.tempfile) if derivatives
      end

      attacher.atomic_persist

      super
    end
  end
end
