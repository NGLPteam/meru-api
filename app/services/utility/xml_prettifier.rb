# frozen_string_literal: true

module Utility
  # Text nodes that contain newlines end up looking really
  # bad with the default prettification available in Nokogiri, Ox, etc.
  #
  # This service remedies that.
  class XMLPrettifier < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :raw_xml, Support::Types::String
    end

    CONTAINS_NEWLINES = /\w.*\n.*\w/m

    standard_execution!

    # @return [Nokogiri::XML::Document]
    attr_reader :doc

    # @return [String]
    def call
      run_callbacks :execute do
        yield prepare!

        yield pretty_indent_text!
      end

      return doc.to_xml
    end

    wrapped_hook! def prepare
      @doc = Nokogiri::XML(raw_xml)

      super
    end

    wrapped_hook! def pretty_indent_text
      doc.xpath("//text()").each do |node|
        next if skip_text?(node)

        adjust_text_node! node
      end

      super
    end

    private

    # @param [Nokogiri::XML::CDATA, Nokogiri::XML::Text] node
    def actual_cdata?(node)
      # simplecov:disable
      return false unless node.cdata?
      # simplecov:enable

      content = node.content

      return true if CONTAINS_NEWLINES.match?(content)

      fragment = Nokogiri::HTML.fragment(content)

      fragment.children.any?(&:element?)
    end

    # @param [String] content
    # @param [Integer] depth
    # @param [Integer] final
    # @return [String]
    def adjust_text_content(content, depth: 1, final: 0)
      "\n#{content.indent(depth * 2)}\n" + ("  " * final)
    end

    # @param [Nokogiri::XML::Text] node
    # @return [void]
    def adjust_text_node!(original_node)
      node = maybe_replace_cdata!(original_node)

      return unless node.cdata?

      depth = node.ancestors.size

      final = (depth - 1).clamp(0, depth)

      content = HtmlBeautifier.beautify(node.content.strip)

      node.content = adjust_text_content(content, depth:, final:)
    end

    # @return [Hash]
    def maybe_replace_cdata!(original_node)
      actual_cdata = actual_cdata?(original_node)

      if original_node.cdata? && !actual_cdata
        node = Nokogiri::XML::Text.new(original_node.content, doc)

        original_node.replace(node)

        return node
      end

      return original_node
    end

    # @param [Nokogiri::XML::Text] node
    def skip_text?(node)
      return false if node.cdata?

      skip_content?(node.content)
    end

    def skip_content?(content)
      content.blank? || CONTAINS_NEWLINES !~ content
    end
  end
end
