# frozen_string_literal: true

module Metadata
  module Shared
    module Xsd
      class Base64Binary < Lutaml::Model::Type::String
        class << self
          def cast(value)
            return nil if value.nil?

            value = super
            pattern = %r{(?-mix:\A([A-Za-z0-9+/]+={0,2}|\s)*\z)}
            raise Lutaml::Model::Type::InvalidValueError, "The value #{value} does not match the required pattern: #{pattern}" unless value.match?(pattern)
            value
          end
        end
      end
    end
  end
end
