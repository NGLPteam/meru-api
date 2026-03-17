# frozen_string_literal: true

module Entities
  # @see Entities::Maintainer
  class Maintain < Support::SimpleServiceOperation
    service_klass Entities::Maintainer
  end
end
