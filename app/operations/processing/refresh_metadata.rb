# frozen_string_literal: true

module Processing
  # @see Processing::Reprocessor
  class RefreshMetadata
    include MeruAPI::Deps[
      reprocess: "processing.reprocess"
    ]

    def call(model, name)
      reprocess.(model, name, derivatives: false, metadata: true)
    end
  end
end
