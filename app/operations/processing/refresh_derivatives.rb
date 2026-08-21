# frozen_string_literal: true

module Processing
  # @see Processing::Reprocessor
  class RefreshDerivatives
    include MeruAPI::Deps[
      reprocess: "processing.reprocess"
    ]

    def call(model, name)
      reprocess.(model, name, derivatives: true, metadata: false)
    end
  end
end
