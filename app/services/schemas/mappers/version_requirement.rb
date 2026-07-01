# frozen_string_literal: true

module Schemas
  module Mappers
    # A scalar type that represents a semantic version (or range of such).
    class VersionRequirement < Shale::Type::Value
      TYPE = ::GlobalTypes::VersionRequirement.new

      OPERATOR_MAPPING = {
        eq: "=",
        neq: "!=",
        gt: ">",
        gteq: ">=",
        lt: "<",
        lteq: "<=",
        agt: "~>",
      }.with_indifferent_access.freeze

      OPERATOR_NAMES = OPERATOR_MAPPING.invert.with_indifferent_access.freeze

      class << self
        # @see ::GlobalTypes::VersionRequirement
        # @param [#to_s] value
        # @return [Gem::Requirement]
        def cast(value)
          TYPE.cast(value)
        end

        # @param [Gem::Requirement] version
        def as_xml(version)
          # simplecov:disable
          raise "only used for CDATA"
          # simplecov:enable
        end

        # @param [Gem::Requirement] version
        def as_xml_value(version)
          # simplecov:disable
          raise "only used for CDATA"
          # simplecov:enable
        end

        # @param [Shale::Adapter::Ox::Node] node
        # @return [Gem::Requirement]
        def of_xml(node, **opts)
          versions = node.children.map do |decl|
            operator = OPERATOR_MAPPING.fetch(decl.name)

            "#{operator} #{decl.text}"
          rescue KeyError
            nil
          end.compact_blank

          cast(versions)
        end

        # This is a custom hook method in order to use this as a polymorphic CDATA.
        #
        # @param [Gem::Requirement] version
        # @param [Ox::Element] parent
        # @param [Shale::Adapter::Ox::Document] doc
        # @return [void]
        def to_xml(version, parent, doc)
          return if version.none?

          version.as_list.each do |raw|
            operator, version = Gem::Requirement.parse(raw)

            name = OPERATOR_NAMES.fetch(operator, operator)

            v = doc.create_element name

            doc.add_text v, version.to_s

            doc.add_element parent, v
          end
        end
      end
    end
  end
end
