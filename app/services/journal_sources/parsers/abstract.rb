# frozen_string_literal: true

module JournalSources
  module Parsers
    # @abstract
    class Abstract
      include Dry::Effects::Handler.Interrupt(:found_known, as: :catch_known)
      include Dry::Effects.Interrupt(:found_known)
      include Dry::Monads[:maybe]
      include MeruAPI::Deps[
        extract: "journal_sources.extract"
      ]

      extend Dry::Core::ClassAttributes

      YEAR_PATTERN = /(?<year>\d{4})/

      defines :parsed_klass, type: JournalSources::Types::Class

      parsed_klass JournalSources::Parsed::Abstract

      # @param [<String>] inputs
      # @return [Dry::Monads::Maybe(JournalSources::Parsed::Abstract)]
      def call(*inputs)
        inputs.flatten!

        caught, parsed = catch_known do
          try_parsing_inputs!(inputs)
        end

        if caught
          parsed.to_monad
        else
          None()
        end
      end

      # @param [<String>] inputs
      # @return [void]
      def try_parsing_inputs!(inputs)
        inputs.each do |input|
          # :nocov:
          next if input.blank?
          # :nocov:

          try_parsing! input
        end
      end

      # @abstract
      # @param [String] input
      # @return [void]
      def try_parsing!(input); end

      private

      # @param [Hash] attrs
      # @return [JournalSources::Parsed::Abstract]
      def build_parsed(**attrs)
        parsed_klass.new(**attrs)
      end

      # @param [Hash] attrs
      # @return [void]
      def check_parsed!(**attrs)
        parsed = build_parsed(**attrs)

        found_known(parsed) if parsed.known?
      rescue Dry::Struct::Error
        # :nocov:
        # intentionally left blank
        # :nocov:
      end

      # @!attribute [r] parsed_klass
      # @return [Class]
      def parsed_klass
        self.class.parsed_klass
      end

      # @!group Extraction Helpers

      def extract_first_string(input)
        extract.first_string(input).value_or(nil)
      end

      # @return [Hash]
      def extract_pages(input)
        extract.pages(input).value_or({ fpage: nil, lpage: nil })
      end

      def extract_year(input)
        extract.year(input).value_or(nil)
      end

      # @!endgroup

      # @!group AnyStyle parsing

      # @param [String] input
      # @return [Harvesting::Utility::ParsedVolumeSource, nil]
      def try_anystyle!(input)
        results = ::AnyStyle.parse input

        results.each do |result|
          # :nocov:
          next if result.blank? || !result.kind_of?(Hash)
          # :nocov:

          normalized = normalize_anystyle(result)

          check_parsed!(**normalized, input:)
        end

        return
      end

      # @param [Hash] result
      # @param [Hash] target
      # @return [void]
      def anystyle_process_result!(result, target)
        result.each do |key, value|
          case key
          when :volume, :issue
            target[key] = extract_first_string(value)
          when :pages
            extract_pages(value) => { fpage:, lpage:, }

            target[:fpage] = fpage
            target[:lpage] = lpage
          when :date
            target[:year] = extract_year(value)
          end
        end
      end

      # @param [Hash] result
      # @param [Hash] target
      # @param [String, nil] type
      # @return [void]
      def anystyle_process_type!(result, target, type: target[:type])
        case type
        when "article-journal"
          target[:journal] = extract_first_string(result[:"container-title"])

          case result
          in volume: [String => volume, *]
            target[:volume] = volume
          in date: [String => date, *], title: [String => title, *]
            target[:volume] ||= ("%<date>s %<title>s" % { date:, title:, }).strip
          in title: [String => title, *]
            target[:volume] ||= ("%<title>s" % { title: }).strip
          else
            # Intentionally left blank
          end
        else
          target[:journal] = extract_first_string(result[:title])
        end
      end

      # @param [Hash] result
      # @return [Hash]
      def normalize_anystyle(result)
        type = result.fetch(:type, nil)

        { type: }.tap do |target|
          anystyle_process_result!(result, target)

          anystyle_process_type!(result, target, type:)
        end
      end

      # @!endgroup
    end
  end
end
