# frozen_string_literal: true

require_relative "boot"

module Support
  # A container for holding pre-initialization support services, generator helpers, etc.
  class System < Dry::System::Container
    use :zeitwerk

    configure do |config|
      config.root = Pathname(__dir__)

      config.component_dirs.auto_register = true

      config.component_dirs.add "lib" do |dir|
        dir.auto_register = false

        dir.namespaces.add_root key: nil, const: "support"
      end

      config.component_dirs.add "operations" do |dir|
        dir.auto_register = true
        dir.memoize = true

        dir.namespaces.add_root key: nil, const: "support"
      end

      config.component_dirs.add "model_concerns" do |dir|
        dir.auto_register = false

        dir.namespaces.add_root key: nil, const: nil
      end

      config.component_dirs.add "models" do |dir|
        dir.auto_register = false

        dir.namespaces.add_root key: nil, const: nil
      end

      config.inflector = Dry::Inflector.new do |inflections|
        inflections.acronym("API")
        inflections.acronym("ANZ")
        inflections.acronym("GQL")
        inflections.acronym("GraphQL")
        inflections.acronym("HTTP")
        inflections.acronym("NGLP")
        inflections.acronym("SSL")
        inflections.acronym("TLS")
        inflections.acronym("TOC")
        inflections.acronym("WDP")
        inflections.acronym("URL")
      end
    end
  end

  Deps = Dry::AutoInject(System)
end

Support::System.start(:security)

Support::System.start(:active_model_types)

Support::System.start(:request_middleware)

Support::System.finalize!
