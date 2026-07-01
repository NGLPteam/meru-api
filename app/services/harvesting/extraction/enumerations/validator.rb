# frozen_string_literal: true

module Harvesting
  module Extraction
    module Enumerations
      # @api private
      class Validator < ::Support::FlexibleStruct
        include ActiveModel::Validations
        include Harvesting::WithLogger

        ELEMENT_FORMAT = /\A(?!_)(?!.*__)[a-z_]+(?<!_)\z/

        VALID_VAR_NAME = "must be a valid variable name"

        attribute? :element, Types::String.optional
        attribute? :expression, Types::String.optional
        attribute? :parent, Types.Instance(::Harvesting::Entities::Struct).optional
        attribute :render_context, Types.Instance(::Harvesting::Extraction::RenderContext)

        validates :element, :expression, presence: true

        validates :element, format: { allow_blank: true, with: ELEMENT_FORMAT, message: VALID_VAR_NAME }

        # @return [Boolean]
        def check!
          # simplecov:disable
          if invalid?
            errors.full_messages.each do |msg|
              logger.warn "Problem enumerating: #{msg}"
            end

            return false
          end

          return true
          # simplecov:enable
        end

        class << self
          # @api private
          # @return [Boolean]
          def check!(...)
            new(...).check!
          end
        end
      end
    end
  end
end
