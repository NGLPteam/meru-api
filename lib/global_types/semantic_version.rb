# frozen_string_literal: true

module GlobalTypes
  # A wrapper around a [Semantic Version](https://semver.org).
  class SemanticVersion < ActiveRecord::Type::String
    # A schema for matching a version hash.
    #
    # @note Not used any more, but kept for posterity.
    VERSION_HASH = Dry::Types["hash"].schema(
      major: Dry::Types["coercible.integer"],
      minor: Dry::Types["coercible.integer"],
      patch: Dry::Types["coercible.integer"],
      pre: Dry::Types["string"].optional,
      build: Dry::Types["string"].optional,
    ).with_key_transform(&:to_sym)

    private_constant :VERSION_HASH

    # @param [String, Semantic::Version, Hash] value
    # @return [Semantic::Version, nil]
    # @overload cast(value)
    #   Parse a semver-formatted string
    #   @param [String] value
    #   @return [Semantic::Version] the parsed string.
    #   @return [nil] If the semantic version cannot be parsed, it will be nil instead of raising an error.
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
      when String
        begin
          Semantic::Version.new(value)
        rescue ArgumentError
          nil
        end
      when Semantic::Version
        # simplecov:disable
        value
        # simplecov:enable
      when VERSION_HASH
        # simplecov:disable
        cast version_string_from(**VERSION_HASH[value])
        # simplecov:enable
      else
        super
      end
    end

    # @param [Semantic::Version, nil] value
    # @return [String, nil]
    def serialize(value)
      value.nil? ? super : super(value.to_s)
    end

    alias serialize_for_store_model serialize

    # @!attribute [r] type
    # @return [:semantic_version]
    def type
      :semantic_version
    end

    private

    # Build a semantic version string from a hash.
    #
    # @see VERSION_HASH
    # @param [String] major
    # @param [String] minor
    # @param [String] patch
    # @param [String, nil] pre
    # @param [String, nil] build
    # @return [String]
    def version_string_from(major:, minor:, patch:, pre: nil, build: nil)
      # simplecov:disable
      [major, minor, patch].join(?.).then do |version|
        pre.present? ? "#{version}-#{pre}" : version
      end.then do |version|
        build.present? ? "#{version}+#{build}" : version
      end
      # simplecov:enable
    end
  end
end
