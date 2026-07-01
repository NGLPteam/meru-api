# frozen_string_literal: true

module Utility
  # Attempt to parse a personal name from a string.
  class ParseName
    include Dry::Monads[:result]

    # Some names with commas don't work as expected.
    #
    # We need to try parsing a different way.
    WEIRD = /\A(?<suffix>[^,]+),\s+(?<prefix>.+)\z/

    # @param [Namae::Name, String] name
    # @param [Boolean] allow_multiple
    # @return [Dry::Monads::Success(Namae::Name)]
    # @return [Dry::Monads::Success<Namae::Name>] when `allow_multiple` is set to true.
    # @return [Dry::Monads::Failure(:unparseable_name, Object)]
    def call(name, allow_multiple: false)
      return Success(name) if name.kind_of?(Namae::Name)

      return unparseable(name) unless name.kind_of?(String)

      parse_string(name).or do
        parse_noisy name
      end.or do
        parse_weird name
      end.or do
        unparseable name
      end
    end

    private

    def cleaner
      @cleaner ||= Utility::StringCleaner.build do |s|
        s.gsub(", and ", " and ")
        s.remove(/\A\.,\s+/)
        s.remove(/\s+'[^']+?'/)
        s.remove(/\s+"[^"]+?"/)
      end
    end

    def unparseable(name)
      Failure[:unparseable, name]
    end

    # @param [String]
    # @return [Dry::Monads::Result]
    def parse_string(name)
      validate Namae.parse(name)
    end

    def parse_noisy(name)
      parse_string cleaner.(name)
    end

    # @param [Namae::Name, <Namae::Name>] name
    # @return [Dry::Monads::Result]
    def validate(name)
      return validate(name.first) if name.kind_of?(Array)

      return Failure() if name.blank?

      return Failure() unless name.family.present? && name.given.present?

      return Success(name)
    end

    def parse_weird(name)
      match = WEIRD.match name

      return Failure() unless match

      parse_string("#{match[:prefix]}, #{match[:suffix]}").or do
        # simplecov:disable
        parse_string("#{match[:prefix]} #{match[:suffix]}")
        # simplecov:enable
      end
    end
  end
end
