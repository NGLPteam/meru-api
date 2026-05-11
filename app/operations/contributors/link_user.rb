# frozen_string_literal: true

module Contributors
  # @see Contributors::UserLinker
  class LinkUser < Support::SimpleServiceOperation
    service_klass Contributors::UserLinker
  end
end
