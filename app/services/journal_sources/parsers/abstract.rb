# frozen_string_literal: true

module JournalSources
  module Parsers
    # @abstract
    class Abstract
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

        parsed = catch :found do
          try_parsing_inputs!(inputs)

          None()
        end

        parsed.to_monad
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

        throw :found, parsed if parsed.known?
      rescue Dry::Struct::Error
        # :nocov:
        # intentionally left blank
        # :nocov:
      end

      # @!attribute [r] parsed_klass
      # @return [Class]
      def parsed_klass = self.class.parsed_klass

      delegate :mode, to: :parsed_klass

      def issue_only? = mode == :issue_only

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

      # @!endgroup Extraction Helpers

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
            # :nocov:
            # Not sure any examples exist of this case alone,
            # but it was something that existed in the original journal source parser.
            target[:volume] ||= ("%<title>s" % { title: }).strip
            # :nocov:
          in note: [/Issue/i => note, *] if looks_like_issue_only?(result, target)
            target[:issue] = maybe_combine_for_issue_only(note, **result)
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

      # @param [Hash] hash
      def has_issue_or_volume?(hash)
        hash[:issue].present? || hash[:volume].present?
      end

      # @param [Hash] result
      # @param [Hash] target
      def looks_like_issue_only?(result, target)
        issue_only? && !has_issue_or_volume?(target) && !has_issue_or_volume?(result)
      end

      # @param [<String>] note
      # @param [<String>, nil] publisher
      # @param [<String>, nil] location
      # @return [String]
      def maybe_combine_for_issue_only(note, publisher: nil, location: nil, **)
        n, p, l = [note, publisher, location].map { extract_first_string(_1) }

        suffix = [p, l].compact.join(", ")

        [n, suffix].compact_blank.join(" ").squish
      end

      # @!endgroup AnyStyle parsing
    end
  end
end
