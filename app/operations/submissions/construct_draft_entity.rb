# frozen_string_literal: true

module Submissions
  # @see Submissions::DraftEntityFactory
  class ConstructDraftEntity < Support::SimpleServiceOperation
    service_klass Submissions::DraftEntityFactory
  end
end
