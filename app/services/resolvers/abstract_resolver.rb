# frozen_string_literal: true

module Resolvers
  # @abstract
  # @note If you rely upon argument authorization, you _cannot_ use this, as it doesn't appear to work.
  #   You will need to manually resolve a scope in some other way.
  #
  # @!attribute [r] context
  #   The GraphQL query context.
  #
  #   @return [GraphQL::Query::Context, Hash]
  #
  # @!attribute [rw] object
  #   The parent / source object for this resolver (may be nil).
  #   It acts as the origin of the request, which may have an effect on the resolved scope.
  #
  #   @note Provided by `GraphQL::Schema::Resolver`.
  #   @return [Object, nil]
  class AbstractResolver < GraphQL::Schema::Resolver
    extend Dry::Core::ClassAttributes

    include ActionPolicy::GraphQL::Behaviour

    include SearchObject.module(:graphql)
    include GraphQL::FragmentCache::ObjectHelpers
    include Resolvers::AbstractOrdering

    argument_class ::Types::BaseArgument

    # @!attribute [r] object
    # @!scope class
    # Whether this resolver applies an ActionPolicy policy scope to its base scope.
    # @return [Boolean]
    defines :applies_policy_scope, type: Resolvers::Types::Bool

    # @!attribute [r] can_resolve_from_object
    # @!scope class
    # Whether this resolver can resolve its scope from the {#object} (if provided).
    # @return [Boolean]
    defines :can_resolve_from_object, type: Resolvers::Types::Bool

    # @!attribute [r] must_resolve_from_object
    # @!scope class
    # Whether this resolver must resolve its scope from the {#object} (if provided).
    # If true, then the resolver will return an empty scope if no {#object} is provided.
    # @return [Boolean]
    defines :must_resolve_from_object, type: Resolvers::Types::Bool

    # @!attribute [r] default_object_association_name
    # @!scope class
    # The default association name to use when resolving from the {#object}.
    # @return [Symbol, nil]
    defines :default_object_association_name, type: Resolvers::Types::Symbol.optional

    # @!attribute [r] filter_scope_klass
    # @!scope class
    # The {Filtering::FilterScope} class to use for filtering.
    # @return [Class<Filtering::FilterScope>, nil]
    defines :filter_scope_klass, type: Resolvers::Types::FilterScopeKlass.optional

    # @!attribute [r] model_klass
    # @!scope class
    # The model class that this resolver resolves.
    # @return [Class<ApplicationRecord>]
    defines :model_klass, type: Support::Models::Types::ModelClass

    # @!attribute [r] params_order
    # @!scope class
    # The parameter reorderer to use for this resolver.
    # @return [Resolvers::Types::ParamsReorderer]
    defines :params_order, type: Resolvers::Types::ParamsReorderer

    scope { resolve_default_scope }

    applies_policy_scope false

    can_resolve_from_object true

    must_resolve_from_object false

    default_object_association_name nil

    model_klass ApplicationRecord

    params_order Support::Params::Reorderer.default

    # @return [User, AnonymousUser]
    attr_reader :current_user

    # @note Expose the SearchObject::Search object.
    # @return [SearchObject::Search]
    attr_reader :search

    # If the resolver's {#object} is a {User}, then this will be that.
    # Otherwise, it will be {#current_user}.
    #
    # @see #from_user?
    # @note This will be used for reviewing and other workflows.
    # @return [User, AnonymousUser]
    attr_reader :relative_user

    def initialize(**options)
      @object = options[:object]

      determine_user!(**options)

      options[:scope] = normalize_scope_option(**options)

      super

      reorder_search_params!
    end

    # An override for the default search_object `params` writer that
    # reorders the parameters after they have been set.
    # @param [{ Symbol => Object }] params
    # @return [void]
    def params=(params)
      super

      reorder_search_params!
    end

    # @!group Enhanced Introspection

    # Whether this resolver applies an ActionPolicy policy scope to its base scope.
    # @see .applies_policy_scope
    def applies_policy_scope? = self.class.applies_policy_scope

    # @!attribute [r] count
    # Fetch a count of the resolved records.
    # @return [Integer]
    def count
      @count ||= fetch_count
    end

    # Whether this resolver is resolving from a user record.
    #
    # @see #relative_user
    def from_user?
      object.present? && (object.kind_of?(User) || object.kind_of?(AnonymousUser))
    end

    # @!attribute [r] model_klass
    # The model class that this resolver resolves.
    # @see .model_klass
    # @return [Class<ApplicationRecord>]
    def model_klass = self.class.model_klass

    # The raw scope used by SearchObject.
    # @return [ActiveRecord::Relation]
    def raw_scope = @search.instance_variable_get(:@scope)

    # @return [Integer]
    def unfiltered_count
      @unfiltered_count ||= fetch_unfiltered_count
    end

    # @return [ActiveRecord::Relation]
    def unfiltered_scope = raw_scope

    # @!endgroup Enhanced Introspection

    # @!group Filtering

    # @see Filtering
    # @see ::Types::FilterScopeInputObject#prepare
    # @param [ActiveRecord::Relation] scope
    # @param [Filtering::FilterScope, nil] filters the filtered result (if present)
    # @return [ActiveRecord::Relation]
    def apply_filters(scope, filters)
      unless filters.nil?
        filters.apply_to scope
      else
        scope.all
      end
    end

    # @see Filtering
    # @see ::Types::FilterScopeInputObject#prepare
    # @param [ActiveRecord::Relation] scope
    # @param [<Filtering::FilterScope, nil>] values the filtered results (if present)
    # @return [ActiveRecord::Relation]
    def apply_or_filters(scope, values)
      first, *rest = values.compact.map(&:call)

      return scope.all if first.nil?

      base = scope.where(id: first)

      return base if rest.blank?

      rest.reduce base do |sc, value|
        sc.or(scope.where(id: value))
      end
    end

    # @!endgroup Filtering

    # @!group Default Scope Resolution

    def can_resolve_from_object?
      self.class.can_resolve_from_object && default_object_association_name.present?
    end

    def must_resolve_from_object? = self.class.must_resolve_from_object

    # @return [Symbol, nil]
    def default_object_association_name
      self.class.default_object_association_name
    end

    # @return [ActiveRecord::Relation]
    def resolve_default_scope
      if should_resolve_with_object?
        resolve_with_object
      else
        resolve_sans_object
      end
    end

    # @abstract
    # @return [ActiveRecord::Relation, nil]
    def resolve_from_object
      object.try(default_object_association_name)
    end

    # @return [ActiveRecord::Relation]
    def resolve_with_object
      resolve_from_object || model_klass.none
    end

    # @abstract
    # @return [ActiveRecord::Relation]
    def resolve_sans_object
      if must_resolve_from_object?
        model_klass.none
      else
        model_klass.all
      end
    end

    def should_resolve_with_object?
      can_resolve_from_object? && object.present?
    end

    # @!endgroup Default Scope Resolution

    private

    # This sets up {#current_user} and {#relative_user}.
    #
    # We need to do this _before_ applying any policy scoping logic.
    #
    # @param [{ Symbol => Object }] options
    # @option options [GraphQL::Query::Context] :context
    # @return [void]
    def determine_user!(**options)
      @current_user = options.dig(:context, :current_user) || AnonymousUser.new

      @relative_user = from_user? ? object : current_user
    end

    # @see #count
    # @return [Integer]
    def fetch_count = fetch_results.count_from_subquery

    # @see #unfiltered_count
    # @return [Integer]
    def fetch_unfiltered_count = unfiltered_scope.count_from_subquery

    # @note Used by ActionPolicy for implicit authorization target.
    # @return [Class<ApplicationRecord>]
    def implicit_authorization_target = model_klass

    # @param [ActiveRecord::Relation, nil] scope
    # @param [{ Symbol => Object }] options
    # @return [ActiveRecord::Relation]
    def normalize_scope_option(scope: nil, **options)
      # :nocov:
      # We may want to skip authorization in some cases.
      return scope unless applies_policy_scope?
      # :nocov:

      config = self.class.config

      base_scope = scope || (config[:scope] && instance_eval(&config[:scope]))

      # This is necessary to avoid a namespace conflict with `Action` / `ActionPolicy`.
      # For some reason, `ActionPolicy` obfuscates the `policy_class` on relations.
      with = implicit_authorization_target.try(:policy_class)

      authorized(base_scope.all, with:)
    end

    # @return [void]
    def reorder_search_params!
      new_params = self.class.params_order.(@search.params)

      @search.instance_variable_set(:@params, new_params)
    end

    # Check if the provided `scope` is wrapping models matching `model`.
    #
    # @param [ActiveRecord::Relation] scope
    # @param [Class<ActiveRecord::Base>] model
    def scope_wraps?(scope, model)
      # :nocov:
      case scope
      when ActiveRecord::Relation
        model == scope.model
      when model
        true
      else
        false
      end
      # :nocov:
    end

    class << self
      # Marks a resolver as something that should apply an ActionPolicy
      # policy scope to its base scope.
      #
      # @return [void]
      def applies_policy_scope!
        applies_policy_scope true
      end

      # @param [Class<Filtering::FilterScope>] filter_scope
      # @return [void]
      def filters_with!(filter_scope)
        filter_scope_klass filter_scope

        options = filter_scope.options_for_resolver.merge(with: :apply_filters)
        or_options = filter_scope.options_for_or_resolver.merge(with: :apply_or_filters)

        option :filters, **options
        option :or_filters, **or_options
      end

      # @!attribute [r] i18n_scope
      # @return [String]
      def i18n_scope
        @i18n_scope || find_i18n_scope
      end

      # A method for looking up the description for a given option
      # within locale files, an alternative to using the `description:` option
      # when defining an option.
      #
      # @param [String, Symbol] name
      # @return [String, nil]
      def option_description_for(name)
        scope = "#{i18n_scope}.options.#{name}"

        I18n.t(:description, scope:).try(:strip)
      end

      # A DSL method for defining the model this resolver wraps around.
      #
      # @param [Class<ApplicationRecord>] klass
      # @param [Symbol] association_name
      # @param [Boolean] from_object
      # @param [Boolean] must_have_object
      # @return [void]
      def resolves_model!(klass, association_name: klass.model_name.plural.to_sym, from_object: true, must_have_object: false, &)
        model_klass klass

        can_resolve_from_object from_object

        must_resolve_from_object must_have_object

        default_object_association_name association_name

        scope(&) if block_given?
      end

      private

      # @see .i18n_scope
      # @return [String]
      def find_i18n_scope
        infix = name.demodulize[/\A(\w+?)Resolver\z/, 1].underscore

        "gql.resolvers.#{infix}"
      end
    end
  end
end
