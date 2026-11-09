# frozen_string_literal: true

module Support
  module RailsApplicationVersion
    # @return [Module] the namespace module for the current Rails application
    def derived_namespace = self.class.name.deconstantize.constantize

    # @return [String] the human-readable name of the current Rails application
    def human_name = I18n.t("rails.app_name", default: name)

    # @return [Module(VersionGem::Basic)] the version module for the current Rails application
    def version
      @version ||= derived_namespace.const_get(:Version)
    end

    # @return [String] a human-readable declaration of the current Rails application and its version
    def version_declaration(prefix: human_name)
      "#{prefix} v#{version}"
    end
  end
end

Rails::Application.prepend Support::RailsApplicationVersion
