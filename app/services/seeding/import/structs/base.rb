# frozen_string_literal: true

module Seeding
  module Import
    module Structs
      # @abstract
      class Base < ::Support::FlexibleStruct
        def slice(*keys)
          keys.flatten.index_with do |key|
            public_send key
          end
        end

        class << self
          # @return [Dry::Types::Type]
          def as_list
            Seeding::Types::Array.constructor do |arr|
              next [] if arr.blank?

              Array(arr).map do |value|
                case value
                when self then value
                when Hash, Seeding::Types::Interface(:to_h) then new(value.to_h)
                else
                  # :nocov:
                  raise TypeError, "cannot structify #{value}"
                  # :nocov:
                end
              end
            end.default { [] }
          end
        end
      end
    end
  end
end
