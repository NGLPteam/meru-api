# frozen_string_literal: true

module VOG
  # @see VOG::FilteringScopeGenerator
  class FilteringScopesGenerator < Rails::Generators::Base
    namespace "vog:filtering_scopes"

    source_root File.expand_path("templates", __dir__)

    SCOPES = Rails.root.join("app", "services", "filtering", "scopes")

    def compile_existing_filtering_scopes
      SCOPES.children.each do |scope_file|
        require scope_file
      end

      scopes = Filtering::FilterScope.descendants.select { _1.name.present? }

      scopes.each do |scope_klass|
        model_name = scope_klass.model_klass.model_name.to_s

        generate "vog:filtering_scope", [model_name]
      end
    end
  end
end
