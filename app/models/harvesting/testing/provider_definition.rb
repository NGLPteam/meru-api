# frozen_string_literal: true

module Harvesting
  module Testing
    class ProviderDefinition < ::ApplicationFrozenRecord
      include Harvesting::Frozen::HasProtocolAndMetadata

      schema!(types: ::Harvesting::Testing::TypeRegistry) do
        required(:id).filled(:string)
        required(:name).filled(:string)
        required(:protocol_name).value(:protocol_name)
        required(:metadata_format_name).value(:metadata_format_name)
        required(:oai).value(:bool)
        required(:protocol).value(:protocol)
        required(:metadata_format).value(:metadata_format)
        required(:host).value(:string)
        required(:base_url).value(:string)
        required(:oai_endpoint).maybe(:string)
        required(:oai_record_prefix).maybe(:string)
        required(:extraction_mapping_template).filled(:string)
      end

      add_index :id, unique: true

      self.primary_key = :id

      calculates_id_from! :protocol_name, :metadata_format_name

      calculates! :oai_record_prefix do |record|
        "meru:oai:#{record["metadata_format_name"]}" if record["oai"]
      end

      calculates! :host do |record|
        "#{record["metadata_format_name"]}.#{record["protocol_name"]}.example.com"
      end

      calculates! :base_url do |record|
        "http://#{record["host"]}"
      end

      calculates! :oai_endpoint do |record|
        "#{record["base_url"]}/request" if record["oai"]
      end

      calculates! :extraction_mapping_template do |record|
        Harvesting::Example.default_or_generic_template_for(record["protocol_name"], record["metadata_format_name"])
      end

      klass_name_pair! :provider do
        "harvesting/testing/#{protocol_name}/#{metadata_format_name}/provider".classify
      end

      klass_name_pair! :record do
        "harvesting/testing/#{protocol_name}/#{metadata_format_name}_record".classify
      end

      # @return [::OAI::Provider::Base]
      def provider_instance
        @provider_instance ||= provider_klass.new
      end

      # @return [#call]
      def rack_app
        provider_instance.rack_app
      end

      # @return [<(Symbol, Regexp)>]
      def webmock_patterns
        [
          [:get, /\A#{base_url}/],
        ]
      end

      # @api private
      # @param [Class(::OAI::Provider::Base)]
      # @return [void]
      def set_up_oai!(provider_klass)
        # :nocov:
        return unless oai?
        # :nocov:

        provider_klass.repository_name name

        provider_klass.record_prefix oai_record_prefix

        provider_klass.repository_url oai_endpoint

        provider_klass.source_model record_klass.wrapped

        provider_klass.register_format metadata_format.oai_testing_format
      end
    end
  end
end
