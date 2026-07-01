# frozen_string_literal: true

module Templates
  module Slots
    class Sanitize
      include Dry::Core::Constants
      include Dry::Monads[:result]

      WRAPPED_CONTENT = %w[display].freeze

      # @api private
      MDX_ATTRS = {
        "Asset" => :all,
        "CopyLink" =>  %w[label].freeze,
        "DotList" => WRAPPED_CONTENT,
        "DotItem" => WRAPPED_CONTENT,
        "EntityLink" => %w[kind slug].freeze,
        "LineBreak" => EMPTY_ARRAY,
        "MeruImage" => %w[src alt caption height width].freeze,
        "MetadataItem" => WRAPPED_CONTENT,
        "MetadataList" => WRAPPED_CONTENT,
        "MetadataLabel" => WRAPPED_CONTENT,
        "MetadataValue" => WRAPPED_CONTENT,
        "PDFViewer" => %w[name size slug url].freeze,
        "SidebarItem" => (WRAPPED_CONTENT | %w[icon url]).freeze,
        "SidebarList" => WRAPPED_CONTENT,
        "VariablePrecisionDate" => %w[precision value].freeze,
      }.freeze

      # @api private
      BLOCK_MDX_TAGS = %w[
        Asset
        CopyLink
        DotList
        DotItem
        EntityLink
        LineBreak
        MeruImage
        MetadataList
        MetadataItem
        MetadataLabel
        MetadataValue
        PDFViewer
        SidebarList
        SidebarItem
        VariablePrecisionDate
      ].freeze

      # @api private
      INLINE_MDX_TAGS = %w[
        CopyLink
        DotList
        DotItem
        EntityLink
        VariablePrecisionDate
      ].freeze

      # Sanitize will strip capitalization from MDX tags, which we do not want.
      # This will build a proc transform each node to restore the capitalization
      # for each slot type.
      BUILD_TRANSFORMER = ->(slot, tag_name) do
        attrs = MDX_ATTRS.fetch(tag_name, EMPTY_ARRAY)

        ->(env) do
          next unless tag_name.casecmp?(env[:node_name])

          env => { node:, }

          # Restore proper capitalization.
          node.name = tag_name

          # simplecov:disable
          node.attributes.each_key do |attr|
            node.remove_attribute(attr) unless attr.in?(attrs)
          end unless attrs == :all
          # simplecov:enable

          node.set_attribute(:slot, slot) if slot == "INLINE"

          { node_allowlist: [node], }
        end
      end

      BR_TO_LINEBREAK = ->(env) do
        next unless env[:node_name] == "br"

        env => { node:, }

        node.name = "LineBreak"

        node.content = "&nbsp;".html_safe

        { node_allowlist: [node], }
      end

      P_FIXER = ->(env) do
        next unless env[:node_name] == ?p

        env => { node:, }

        node.attributes.each do |name, _|
          node.remove_attribute(name)
        end

        node.children.each do |child|
          next unless child.text?

          content = child.content

          fixed = [].tap do |a|
            a << " " if content.match?(/\A\s+/)
            a << content.squish
            a << " " if content.match?(/\s+\z/)
          end.join

          child.content = fixed
        end

        { node_allowlist: [node], }
      end

      REFENCE_CODEBLOCK = ->(env) do
        next unless env[:node_name] == "pre" && env[:node].children.first.try(:name) == "code"

        env => { node:, }

        text = node.replace(ReverseMarkdown.convert(node.to_html, github_flavored: true))

        { node_allowlist: [text] }
      end

      BASE_BLOCK_TRANSFORMERS = [BR_TO_LINEBREAK, P_FIXER, REFENCE_CODEBLOCK].freeze

      # @api private
      # @see BUILD_TRANSFORMER
      BLOCK_MDX_TRANSFORMERS = (BASE_BLOCK_TRANSFORMERS + BLOCK_MDX_TAGS.map do |tag_name|
        BUILD_TRANSFORMER["BLOCK", tag_name]
      end).freeze

      # @api private
      # @see BUILD_TRANSFORMER
      INLINE_MDX_TRANSFORMERS = INLINE_MDX_TAGS.map do |tag_name|
        BUILD_TRANSFORMER["INLINE", tag_name]
      end.freeze

      # @api private
      EXTRA_BLOCK_TAGS = %w[h1 h2 h3 h4 h5 h6].freeze

      # @api private
      BLOCK = ::Sanitize::Config.merge(::Sanitize::Config::BASIC,
        elements: ::Sanitize::Config::BASIC[:elements] + EXTRA_BLOCK_TAGS,
        attributes: ::Sanitize::Config::BASIC[:attributes],
        transformers: BLOCK_MDX_TRANSFORMERS
      )

      # @api private
      INLINE = ::Sanitize::Config.merge(::Sanitize::Config::RESTRICTED,
        elements: ::Sanitize::Config::RESTRICTED[:elements],
        transformers: INLINE_MDX_TRANSFORMERS
      )

      # @param [String] content
      # @param [Templates::Types::SlotKind] kind
      # @return [Dry::Monads::Success(String)]
      def call(content, kind: "block")
        config = config_for(kind)

        return Failure[:unknown_slot_kind, kind] unless config

        Success ::Sanitize.fragment(content.strip, config).strip
      end

      private

      # @param [Templates::Types::SlotKind] kind
      # @return [Hash, false]
      def config_for(kind)
        case kind.to_s
        in "block"
          BLOCK
        in "inline"
          INLINE
        else
          false
        end
      end
    end
  end
end
