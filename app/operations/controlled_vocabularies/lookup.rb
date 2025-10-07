# frozen_string_literal: true

module ControlledVocabularies
  # @see ControlledVocabularies::Finder
  class Lookup < Support::SimpleServiceOperation
    service_klass ControlledVocabularies::Finder
  end
end
