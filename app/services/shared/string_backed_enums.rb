# frozen_string_literal: true

module Shared
  module StringBackedEnums
    extend ActiveSupport::Concern

    module ClassMethods
      def string_enum(name, *values, **options)
        mapping = values.flatten.to_h do |value|
          sym = value.to_sym

          [sym, sym]
        end

        enum(name, mapping, **options)
      end
    end
  end
end
