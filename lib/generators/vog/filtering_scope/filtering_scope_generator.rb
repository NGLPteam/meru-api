# frozen_string_literal: true

module VOG
  class FilteringScopeGenerator < Rails::Generators::NamedBase
    namespace "vog:filtering_scope"

    source_root File.expand_path("templates", __dir__)

    FILTERING_INPUTS = Rails.root.join("app", "graphql", "types", "filtering")

    FILTER_SCOPE_SPECS = Rails.root.join("spec", "services", "filtering", "scopes")

    def build_filter_input_type
      template "filter_input.rb.tt", FILTERING_INPUTS.join(
        "#{file_name}_filter_input_type.rb"
      )
    end

    def build_filter_scope_spec
      spec_path = FILTER_SCOPE_SPECS.join("#{file_name}_filter_scope_spec.rb")

      # We don't want to overwrite existing specs when regenerating
      return if spec_path.exist?

      template "filter_scope_spec.rb.tt", spec_path
    end

    private

    def argument_call_for(key, dry_type)
      typing = dry_type.gql_typing
      input_key = typing.input_key_for key
      opts = typing.argument_options
      type = opts.delete :type
      raw_desc = opts.delete(:description) || "Filter by #{key.to_s.humanize.downcase}."
      desc = raw_desc.to_s.indent(2).strip

      opt_str = [].tap do |arr|
        arr << "loads: ::#{opts[:loads].name}" if opts[:loads].present?
        arr << "as: #{key.to_sym.inspect}" if input_key.to_s != key.to_s
        arr << "required: #{opts[:required].present?}"
        arr << "default_value: #{opts[:default_value].inspect}" if opts.key?(:default_value) && !opts[:default_value].nil?
        arr << "replace_null_with_default: true" if opts[:replace_null_with_default]
      end.join(", ")

      declaration = [].tap do |dec|
        dec << input_key.inspect
        dec << arg_type_inspect(type)
        dec << opt_str unless opt_str.empty?
      end.join(", ")

      <<~RUBY.indent(6).strip
      argument #{declaration} do
        description <<~TEXT
        #{desc}
        TEXT
      end
      RUBY
    end

    def arg_type_inspect(type)
      case type
      in Array
        type.map { arg_type_inspect(_1) }.join(", ").then { "[#{_1}]" }
      in Class
        "::#{type.name}"
      in Hash
        [].tap do |out|
          out << "{ "
          type.each do |k, v|
            out << "#{k}: #{arg_type_inspect(v)}"
          end
          out << " }"
        end.join
      else
        type.to_s
      end
    end

    def scope_klass
      @scope_klass ||= scope_klass_name.constantize
    end

    def scope_klass_name
      @scope_klass_name ||= derive_scope_klass_name
    end

    def derive_scope_klass_name
      "::Filtering::Scopes::#{class_name.pluralize}"
    end
  end
end
