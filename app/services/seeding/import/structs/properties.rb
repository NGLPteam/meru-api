# frozen_string_literal: true

module Seeding
  module Import
    module Structs
      # An abstract base properties struct.
      # @abstract
      class Properties < Base
        include ::Support::Typing

        class << self
          def with_default
            default { new }
          end
        end
      end
    end
  end
end
