# frozen_string_literal: true

require_relative "semantic_version"

module GlobalTypes
  # A parsed [Semantic Version](https://semver.org) used for ordering and comparison
  # within the database. It is backed by a composite type and used on {SchemaVersion}.
  class ParsedSemanticVersion < GlobalTypes::SemanticVersion
    # An encoder for a PG Record
    ENCODER = PG::TextEncoder::Record.new

    private_constant :ENCODER

    # A decoder for a PG Record
    DECODER = PG::TextDecoder::Record.new

    private_constant :DECODER

    # A regular expression for matching the SQL representation of a parsed semantic version.
    ENCODED = /\A\((?:"?\d*"?),(?:"?\d*"?),(?:"?\d*"?),(?:"?[^,]*"?),(?:"?[^,]*"?)\)\z/

    private_constant :ENCODED

    # @param [String, Semantic::Version, Hash] value
    # @return [Semantic::Version, nil]
    # @overload cast(encoded_value)
    #   Parse an {ENCODED encoded value} via {#decode_semantic_version}.
    #   @param [String] encoded_value
    #   @return [Semantic::Version]
    # @overload cast(value)
    #   Parse a semver-formatted string
    #   @param [String] value
    #   @raise [ArgumentError] if the value cannot be parsed
    #   @return [Semantic::Version]
    # @overload cast(version)
    #   @param [Semantic::Version] version
    #   @return [Semantic::Version]
    # @overload cast(major:, minor:, patch:, pre: nil, build: nil)
    #   Cast a semantic version using {VERSION_HASH}.
    #   @param [#to_i] major
    #   @param [#to_i] minor
    #   @param [#to_i] patch
    #   @param [String, nil] pre
    #   @param [String, nil] build
    #   @return [Semantic::Version]
    def cast(value)
      case value
      when ENCODED
        decode_semantic_version value
      when String
        # simplecov:disable
        Semantic::Version.new value
        # simplecov:enable
      when Semantic::Version
        # simplecov:disable
        value
        # simplecov:enable
      when VERSION_HASH
        # simplecov:disable
        cast version_string_from(**VERSION_HASH[value])
        # simplecov:enable
      end
    end

    # @param [Semantic::Version] new_value
    # @return [String] the SQL representation of the variable precision date (e.g. `(2021-01-01,year)`)
    def serialize(value)
      case value
      when Semantic::Version
        ENCODER.encode value.to_array
      end
    end

    # @param [String] raw_old_value
    # @param [Semantic::Version] new_value
    def changed_in_place?(raw_old_value, new_value)
      raw_old_value != serialize(new_value)
    end

    # @!attribute [r] type
    # @return [:parsed_semantic_version]
    def type
      :parsed_semantic_version
    end

    private

    # Parse a SQL representation of a parsed semantic version back into its component type.
    #
    # @param [String] value
    # @return [Semantic::Version]
    def decode_semantic_version(value)
      major, minor, patch, pre, build = DECODER.decode value

      version_string = version_string_from(major:, minor:, patch:, pre:, build:)

      Semantic::Version.new version_string
    end
  end
end
