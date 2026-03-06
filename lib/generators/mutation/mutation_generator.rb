# frozen_string_literal: true

require_relative "../../support/system"

class MutationGenerator < Rails::Generators::NamedBase
  include Support::GeneratesCommonFields

  source_root File.expand_path("templates", __dir__)

  class_option :model, type: :string
  class_option :graphql_type, type: :string
  class_option :verb, type: :string
  class_option :mutation_parent, type: :string
  class_option :subaction, type: :boolean, default: false
  class_option :abstract, type: :boolean, default: false
  class_option :skip_contract, type: :boolean, default: false
  class_option :skip_operation, type: :boolean, default: false
  class_option :skip_spec, type: :boolean, default: false
  class_option :skip_implementation_logic, type: :boolean, default: false
  class_option :fields, type: :string
  class_option :required, type: :string
  class_option :rules, type: :string
  class_option :references, type: :string, default: ""

  DEFAULT_NAMING_PATTERN = /\A(?<model_name>\S+)(?<verb>Create|Update|Destroy|Mutate)\z/

  def create_mutation!
    if generates_abstract_mutator?
      template "parent_mutation.rb", Rails.root.join("app/graphql/mutations", "#{parent_file_name}.rb")
    end

    template "mutation.rb", Rails.root.join("app/graphql/mutations", "#{file_name}.rb")
  end

  def create_operation!
    return if options[:skip_operation]

    template "operation.rb", Rails.root.join("app/operations/mutations/operations", "#{file_name}.rb")
  end

  def create_contract!
    return if options[:skip_contract]

    if generates_abstract_mutator?
      template "mutate_contract.rb", Rails.root.join("app/operations/mutations/contracts", "#{mutate_contract_key}.rb")
    end

    template "contract.rb", Rails.root.join("app/operations/mutations/contracts", "#{file_name}.rb")
  end

  def create_spec!
    return if options[:skip_spec]

    template "spec.rb", Rails.root.join(spec_path, "mutations", "#{file_name}_spec.rb")
  end

  def expose_in_schema!
    return if options[:abstract]

    inject_into_file target_mutation, before: "  end\nend" do
      <<~RUBY.indent(4)

      field #{mutation_name.inspect}, mutation: #{mutation_class_name}
      RUBY
    end
  end

  private

  def target_mutation
    "app/graphql/types/mutation_type.rb"
  end

  def spec_path
    "spec/requests/graphql"
  end

  def abstract?
    options[:abstract]
  end

  def alters_model_counts?
    create_mutation? || destroy_mutation?
  end

  def contract_key
    class_name.underscore.to_sym
  end

  def create_mutation?
    naming[:verb] == :create
  end

  def changes_model?
    create_mutation? || update_mutation?
  end

  def default_expectation
    case naming
    in {verb:, human_model_name:}
      "#{verb}s the #{human_model_name}"
    else
      "works"
    end
  end

  def destroy_mutation?
    naming[:verb] == :destroy
  end

  def existing_model_key
    :"existing_#{model_key}"
  end

  def generates_abstract_mutator?
    changes_model? && !subaction? && !options[:mutation_parent]
  end

  def graphql_model_type
    options.fetch :graphql_type do
      "Types::#{model_name}Type" if standard_mutation?
    end
  end

  def graphql_mutation
    class_name.camelize(:lower)
  end

  def has_existing_attributes?
    has_common_fields?
  end

  def human_model_name
    naming[:human_model_name]
  end

  def input_name
    "#{class_name}Input"
  end

  def model_id_key
    :"#{model_key}_id"
  end

  def model_initial
    @model_initial ||= model_key.to_s.scan(/(?<=\b|_)[a-z]/).join.then do |initial|
      initial == ?m ? model_key.to_s : initial
    end
  end

  def model_key
    naming[:model_key]
  end

  alias model_factory model_key

  def model_name
    naming[:model_name]
  end

  def mutate_contract_class_name
    mutate_contract_key.to_s.classify
  end

  def mutate_contract_key
    :"mutate_#{model_key}"
  end

  def mutation_class_name
    "Mutations::#{class_name}"
  end

  def mutation_name
    file_name.to_sym
  end

  def mutation_verb
    naming[:verb]
  end

  def auth_predicate
    :"#{mutation_verb}?"
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def naming
    @naming ||= {}.tap do |hsh|
      case class_name
      when DEFAULT_NAMING_PATTERN
        hsh[:verb] = Support::Types::MutationVerb[Regexp.last_match[:verb]&.underscore]
        hsh[:model_name] = options.fetch(:model) { Regexp.last_match[:model_name] }
      else
        hsh[:model_name] = options.fetch(:model) { raise "Must specify --model for non-default mutations" }
      end

      hsh[:model_key] = hsh[:model_name]&.underscore&.to_sym
      hsh[:human_model_name] = hsh[:model_name]&.underscore&.humanize(capitalize: false)

      hsh[:verb] = options[:verb].to_sym if options[:verb].present?
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

  def operation_class_name
    "Mutations::Operations::#{class_name}"
  end

  def operation_call_signature
    if destroy_mutation?
      "#{model_key}:"
    elsif create_mutation?
      "**attrs"
    elsif update_mutation?
      "#{model_key}:, **attrs"
    else
      "**args"
    end
  end

  def operation_path
    "mutations.operations.#{mutation_name}"
  end

  def parent_mutation_class_name
    options.fetch :mutation_parent do
      if (create_mutation? || update_mutation?) && !subaction?
        "Mutations::#{parent_mutation_name}"
      else
        "Mutations::BaseMutation"
      end
    end
  end

  def parent_file_name
    parent_mutation_name.underscore
  end

  def parent_mutation_name
    "Mutate#{model_name}"
  end

  def query_name
    class_name.camelize(:upper)
  end

  def skip_implementation_logic?
    options[:skip_implementation_logic]
  end

  def should_add_common_fields?
    changes_model?
  end

  def should_use_contract?
    true
  end

  def standard_mutation?
    create_mutation? || update_mutation? || destroy_mutation?
  end

  def subaction?
    options[:subaction]
  end

  def update_mutation?
    naming[:verb] == :update
  end

  def updates_optional_description?
    update_mutation? && has_optional_description?
  end

  def updates_unique_identifier?
    update_mutation? && has_unique_identifier?
  end

  def fields
    return [] unless options[:fields]

    @fields ||= JSON.parse(options[:fields]).map { |h| h.with_indifferent_access }
  end

  def contract_has_rules?
    rules.any?
  end

  def rules
    @rules ||= [].tap do |rules|
      rules.concat(options[:rules] ? JSON.parse(options[:rules]).map { |h| h.with_indifferent_access } : [])
      rules.push({ field: :title, validate: :unique_title }.with_indifferent_access) if has_unique_title?
      rules.push({ field: :identifier, validate: :unique_identifier }.with_indifferent_access) if has_unique_identifier?
    end
  end

  def required?
    required.any?
  end

  def references
    options[:references].split(",").map(&:strip)
  end

  # rubocop:disable Metrics/AbcSize
  def required
    @required ||= [].tap do |required|
      required.concat(options[:required] ? JSON.parse(options[:required]).map { |h| h.with_indifferent_access } : [])
      required.push({ field: model_key.inspect, macro: :value, arg: model_key.inspect }.with_indifferent_access) if works_with_existing_model?
      required.push({ field: :title, macro: :filled, arg: :string }.with_indifferent_access) if has_unique_title?
      required.push({ field: :identifier, macro: :filled, arg: :string }.with_indifferent_access) if has_unique_identifier?
      required.push({ field: :description, macro: :maybe, arg: :string }.with_indifferent_access) if has_optional_description?
    end
  end
  # rubocop:enable Metrics/AbcSize

  def updates_unique_title?
    update_mutation? && has_unique_title?
  end

  def implementation_accepts_existing_model?
    create_mutation? || works_with_existing_model?
  end

  def works_with_existing_model?
    update_mutation? || destroy_mutation?
  end
end
