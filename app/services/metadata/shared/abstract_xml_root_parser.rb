# frozen_string_literal: true

module Metadata
  module Shared
    # @abstract
    class AbstractXMLRootParser < Support::HookBased::Actor
      extend Dry::Core::ClassAttributes
      extend Dry::Initializer

      defines :enforced_namespaces, type: ::Metadata::Types::NamespaceMap
      defines :root_klass, type: ::Metadata::Types::Class

      enforced_namespaces Dry::Core::Constants::EMPTY_HASH

      root_klass Lutaml::Model::Serializable

      param :xml_content, ::Metadata::Types::String.optional

      standard_execution!

      # @return [String, nil]
      attr_reader :content

      # @return [Nokogiri::XML::Document]
      attr_reader :doc

      # @return [Lutaml::Model::Serializable]
      attr_reader :root

      # @return [Dry::Monads::Success(Lutaml::Model::Serializable)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield parse_doc!

          yield check_namespaces!

          yield create_root!
        end

        Success root
      end

      wrapped_hook! def prepare
        @content = @doc = @root = nil

        # simplecov:disable
        return Failure[:no_content] if xml_content.blank?
        # simplecov:enable

        super
      end

      wrapped_hook! def parse_doc
        @doc = Nokogiri::XML(xml_content)

        super
      end

      wrapped_hook! def check_namespaces
        self.class.enforced_namespaces.each do |prefix, href|
          maybe_add_namespace! prefix, href
        end

        super
      end

      wrapped_hook! def create_root
        @content = doc.to_xml

        @root = self.class.root_klass.from_xml content

        super
      end

      private

      # @param [String] prefix
      # @param [String] href
      # @return [void]
      def maybe_add_namespace!(prefix, href)
        # simplecov:disable
        return if doc.root.namespace_definitions.any? { _1.prefix == prefix }
        # simplecov:enable

        doc.root.add_namespace_definition(prefix, href)
      end

      class << self
        # @param [String] raw_prefix
        # @param [String] raw_value
        # @return [void]
        def enforced_namespace!(raw_prefix, raw_value)
          prefix = raw_prefix&.to_s

          value = raw_value.to_s

          merged = enforced_namespaces.merge(prefix => value)

          enforced_namespaces merged.freeze
        end

        # @return [void]
        def add_xsi!
          enforced_namespace! "xsi", "http://www.w3.org/2001/XMLSchema-instance"
        end
      end
    end
  end
end
