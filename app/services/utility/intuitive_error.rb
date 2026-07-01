# frozen_string_literal: true

module Utility
  # @abstract
  class IntuitiveError < StandardError
    extend Dry::Core::ClassAttributes

    include Dry::Core::Constants

    defines :message_format, :prefix_format, type: Utility::Types::MessageFormat

    defines :message_keys, :prefix_keys, type: Utility::Types::MessageKeyMap

    defines :dym_needle, :dym_dict, type: Utility::Types::MethodName.optional

    defines :dym_enabled, type: Utility::Types::Bool

    message_format "Unspecified Error"

    message_keys EMPTY_HASH

    prefix_keys EMPTY_HASH

    prefix_format "%<prefix>s"

    dym_enabled false
    dym_needle nil
    dym_dict nil

    # @return [String]
    attr_reader :prefix

    # Corrections from the `DidYouMean` gem, if applicable.
    # @return [<String>]
    attr_reader :corrections

    # The message without any corrections (if applicable).
    #
    # @return [String]
    attr_reader :base_message

    def initialize(**)
      @corrections = build_corrections

      @base_message = build_base_message

      message = build_full_message

      super(message)
    end

    private

    # @return [String]
    def build_base_message
      [
        build_formatted_prefix,
        build_formatted_message,
      ].compact_blank.join(" ").freeze
    end

    # @return [<String>]
    def build_corrections
      return EMPTY_ARRAY unless dym_enabled?

      needle = public_send(self.class.dym_needle)

      dictionary = Array(public_send(self.class.dym_dict))

      DidYouMean::SpellChecker.new(dictionary:).correct(needle)
    rescue StandardError
      # simplecov:disable
      EMPTY_ARRAY
      # simplecov:enable
    end

    # @return [String]
    def build_formatted_prefix
      prefix_options = evaluate_key_mapping self.class.prefix_keys

      self.class.prefix_format % prefix_options
    end

    # @return [String]
    def build_formatted_message
      message_options = evaluate_key_mapping self.class.message_keys

      self.class.message_format % message_options
    end

    def build_full_message
      return base_message unless dym_enabled? && corrections.present?

      suggestion = DidYouMean.formatter.message_for(corrections)

      "#{base_message}#{suggestion}".freeze
    end

    def dym_enabled?
      self.class.dym_enabled
    end

    # @param [Utility::Types::MessageKeyMap] key_mapping
    # @return [{ Symbol => Object }]
    def evaluate_key_mapping(key_mapping)
      key_mapping.transform_values do |value|
        case value
        in Utility::Types::Callable
          instance_eval(&value)
        else
          __send__(value)
        end
      end
    end

    class << self
      # @return [void]
      def did_you_mean_with!(needle, dictionary)
        dym_needle needle

        dym_dict dictionary

        dym_enabled(dym_needle.present? && dym_dict.present?)
      end

      # @param [String] format
      # @return [void]
      def message_format!(format)
        message_format sanitize_format(format)
      end

      # @param [<#to_sym>] attr_keys
      # @param [{ #to_sym => Symbol, #call }]
      # @return [void]
      def message_keys!(...)
        message_keys wrap_keys(message_keys, ...)
      end

      def message_key!(...)
        message_keys wrap_key(message_keys, ...)
      end

      # @param [String] format
      # @return [void]
      def prefix_format!(format)
        prefix_format sanitize_format(format)
      end

      # @param [<#to_sym>] keys
      # @return [void]
      def prefix_keys!(*keys)
        prefix_keys wrap_keys(prefix_keys, *keys)
      end

      def prefix_key!(...)
        prefix_keys wrap_key(prefix_keys, ...)
      end

      private

      # @param [String] format
      # @return [String]
      def sanitize_format(format)
        format.to_s.strip.strip_heredoc
      end

      # @param [Utility::Types::MessageKeyMap] old_mapping
      # @param [<Symbol>] attr_keys
      # @param [Utility::Types::MessageKeyMap] mapped_keys
      # @return [Utility::Types::MessageKeyMap]
      def wrap_keys(old_mapping, *attr_keys, **mapped_keys)
        attr_keys.flatten!

        attr_map = attr_keys.index_with { _1.to_sym.to_proc }

        new_mapping = Utility::Types::MessageKeyMap[attr_map.merge(mapped_keys)]

        old_mapping.merge(new_mapping).freeze
      end

      # @param [Utility::Types::MessageKeyMap] old_mapping
      # @param [#to_sym] new_key
      # @return [Utility::Types::MessageKeyMap]
      def wrap_key(old_mapping, new_key, &block)
        key = Utility::Types::MessageKey[new_key]

        value = block_given? ? block : key

        old_mapping.merge(key => value)
      end
    end

    prefix_key! :prefix do
      next if prefix.blank?

      "[#{prefix}]" if prefix.present?
    end
  end
end
