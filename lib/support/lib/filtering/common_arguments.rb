# frozen_string_literal: true

module Support
  module Filtering
    # DSL methods for defining filtering arguments on a {Filtering::FilterScope}.
    #
    # They are extrapolated into this module to separate argument DSLs from the core
    # filtering logic.
    #
    # Type references used herein are resolved via {Filtering::TypeContainer}.
    module CommonArguments
      extend ActiveSupport::Concern

      # The class methods / DSL for defining filtering arguments.
      module ClassMethods
        # @note This method is largely called by the other argument-defining DSL methods.
        # @param [Symbol] key
        # @param [Symbol, Dry::Types::Type] type
        # @param [Object, nil] default_value
        # @param [Boolean, nil] replace_null
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def argument!(key, type, default_value: nil, replace_null: nil, **options)
          dry_type = arguments.add! key, type, **options do |arg|
            # simplecov:disable
            yield arg if block_given?
            # simplecov:enable

            arg.default(default_value, replace_null:)
          end

          option key, dry_type, optional: true
        end

        # @param [Symbol] key
        # @param [Symbol] truthy_scope
        # @param [Symbol, nil] falsey_scope
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def boolean_scope!(key, truthy_scope: key, falsey_scope: nil, **options, &)
          argument!(key, :bool, **options, &)

          on_true = "scope.#{truthy_scope}"

          on_false = falsey_scope.present? ? "scope.#{falsey_scope}" : "scope.all"

          uses_scopes! truthy_scope, falsey_scope

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            augment_scope! do |scope|
              case #{key}
              when true
                #{on_true}
              when false
                #{on_false}
              end
            end
          end
          RUBY
        end

        # Define a filter for matching date columns.
        #
        # @param [Symbol] key
        # @param [Symbol] column_name
        # @return [void]
        def date_match!(key, column_name: key)
          # simplecov:disable
          argument! key, :date_match do |arg|
            arg.description <<~TEXT
            Filter the model's `#{column_name}` with date constraints.
            TEXT
          end

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            attribute = self.class.model_klass.arel_table[#{column_name.to_sym.inspect}]

            augment_scope! do |scope|
              scope.where(#{key}.(attribute)) if #{key}.present?
            end
          end
          RUBY
          # simplecov:enable
        end

        # Define a filter for matching float / decimal columns.
        #
        # @param [Symbol] key
        # @param [Symbol] column_name
        # @return [void]
        def float_match!(key, column_name: key)
          # simplecov:disable
          argument! key, :float_match do |arg|
            arg.description <<~TEXT
            Filter the model's `#{column_name}` with various float / decimal constraints.
            TEXT
          end

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            attribute = self.class.model_klass.arel_table[#{column_name.to_sym.inspect}]

            augment_scope! do |scope|
              scope.where(#{key}.(attribute)) if #{key}.present?
            end
          end
          RUBY
          # simplecov:enable
        end

        # Define a full-text search filter that uses {Support::FullTextSearching}.
        # @param [Symbol] search_scope the name of a full-text search scope on the model
        # @param [Symbol] key the argument key to use
        # @return [void]
        def fts_scope!(search_scope, key: :q)
          argument! key, :full_text_search_query do |arg|
            arg.description <<~TEXT
            Perform a full-text search with the provided query.
            TEXT
          end

          uses_scope! search_scope

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          before_ranking def rank_#{search_scope}!
            augment_ranking! do |scope|
              scope.#{search_scope}(#{key}).with_pg_search_rank if #{key}.present? && #{key}.ranked_by_relevance?
            end
          end

          after_build def apply_#{search_scope}!
            augment_scope! do |scope|
              scope.#{search_scope}(#{key}) if #{key}.present?
            end
          end
          RUBY
        end

        # Define a full-text search filter.
        # @param [Symbol] search_scope the name of a full-text search scope on the model
        # @param [Symbol] key the argument key to use
        # @return [void]
        def fts_search!(search_scope, key: :q)
          argument! key, :string do |arg|
            arg.description <<~TEXT
            Perform a full-text search to approximately match the provided string.
            TEXT
          end

          uses_scope! search_scope

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          before_ranking def rank_#{search_scope}!
            augment_ranking! do |scope|
              scope.#{search_scope}(#{key}).with_pg_search_rank if #{key}.present?
            end
          end

          after_build def apply_#{search_scope}!
            augment_scope! do |scope|
              scope.#{search_scope}(#{key}) if #{key}.present?
            end
          end
          RUBY
        end

        # @return [void]
        def has_name_search!
          fts_scope! :search_name, key: :name_search
        end

        # Define a filter for matching integer columns.
        # @param [Symbol] key
        # @param [Symbol] column_name
        # @return [void]
        def integer_match!(key, column_name: key)
          # simplecov:disable
          argument! key, :integer_match do |arg|
            arg.description <<~TEXT
            Filter the model's `#{column_name}` with various integer constraints.
            TEXT
          end

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            attribute = self.class.model_klass.arel_table[#{column_name.to_sym.inspect}]

            augment_scope! do |scope|
              scope.where(#{key}.(attribute)) if #{key}.present?
            end
          end
          RUBY
          # simplecov:enable
        end

        # Define a nested filter for an associated model. This will use the filters
        # generated by another {Filtering::FilterScope} for the associated model
        # and allow you to filter by associations.
        #
        # @note In order to use this, you must first expose the associated model's
        #   filters within {Filtering::TypeContainer} under a key which is provided to `type_name`.
        #
        # @param [Symbol] association_name
        # @param [Symbol] type_name
        # @param [Symbol] key
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def nested_filter!(association_name, type_name: :"#{association_name}_filters", key: :"#{association_name}_filters", **options, &)
          key = key.to_sym

          argument!(key, type_name, **options, &)

          uses_scope! :filter_by_nested

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_nested_#{association_name}_filters!
            augment_scope! do |scope|
              scope.filter_by_nested #{association_name.to_sym.inspect}, #{key}
            end
          end
          RUBY
        end

        # Define a simple equality filter for a column.
        #
        # @param [Symbol] key
        # @param [Symbol] type_name
        # @param [Symbol] column_name
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def simple_filter!(key, type_name, column_name: key, **options, &)
          argument!(key, type_name, **options, &)

          column_name = column_name.to_sym

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            augment_scope! do |scope|
              scope.where(#{column_name.inspect} => #{key}) unless #{key}.nil? || (#{key}.respond_to?(:empty?) && #{key}.empty?)
            end
          end
          RUBY
        end

        # Define a simple scope-based filter for a column.
        # @param [Symbol] key
        # @param [Symbol] type_name
        # @param [Symbol] scope_name the name of the scope to call on the model, by default it will use a `lookup_by_#{key}` pattern
        #   which is created by {VOG::LookupHelpers}
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def simple_scope_filter!(key, type_name, scope_name: :"lookup_by_#{key}", **options, &)
          argument!(key, type_name, **options, &)

          uses_scope! scope_name

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            augment_scope! do |scope|
              scope.#{scope_name}(#{key}) unless #{key}.blank?
            end
          end
          RUBY
        end

        # Define a simple state filter for an enum column.
        #
        # @param [Symbol] enum_type the enum type to use for the argument
        # @param [Symbol] key the argument key to use
        # @param [Symbol] in_state_scope the name of the scope to call on the model
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def simple_state_filter!(enum_type, key: :in_state, in_state_scope: :in_state, **options, &)
          argument!(key, enum_type, **options, &)

          uses_scope! in_state_scope

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            augment_scope! do |scope|
              scope.#{in_state_scope}(#{key}) if #{key}.present?
            end
          end
          RUBY
        end

        # Define a simple truthy filter for a boolean column.
        #
        # @param [Symbol] key
        # @param [Symbol] column_name
        # @param [Boolean] filter_false whether to filter by false values when the argument is false
        # @yield [arg] a block to further configure the argument
        # @yieldparam [Filtering::ArgumentBuilder] arg
        # @yieldreturn [void]
        # @return [void]
        def simple_truthy_filter!(key, column_name: key, filter_false: false, **options, &)
          # simplecov:disable
          argument!(key, :bool, **options, &)

          column_name = column_name.to_sym

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_truthy_#{key}!
            augment_scope! do |scope|
              if #{key}
                scope.where(#{column_name.inspect} => true)
              elsif #{key} == false && #{filter_false}
                scope.where(#{column_name.inspect} => false)
              end
            end
          end
          RUBY
          # simplecov:enable
        end

        # @return [void]
        def taggable!
          argument! :external_tags, :tag_search do |arg|
            arg.description "Search external tags."
          end

          argument! :internal_tags, :tag_search do |arg|
            arg.description "Search internal tags."
          end

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build :apply_all_tags!
          RUBY
        end

        # Define a filter for matching time columns.
        #
        # @param [Symbol] key
        # @param [Symbol] column_name
        # @return [void]
        def time_match!(key, column_name: key)
          argument! key, :time_match do |arg|
            arg.description <<~TEXT
            Filter the model's `#{column_name}` with time constraints.
            TEXT
          end

          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          after_build def apply_#{key}!
            attribute = self.class.model_klass.arel_table[#{column_name.to_sym.inspect}]

            augment_scope! do |scope|
              scope.where(#{key}.(attribute)) if #{key}.present?
            end
          end
          RUBY
        end

        # Define filters for `created_at` and `updated_at` timestamp columns.
        # @see #time_match!
        # @return [void]
        def timestamps!
          time_match! :created_at
          time_match! :updated_at
        end

        # Define a filter for tracking mutations by users.
        #
        # @return [void]
        def tracks_mutations!
          # simplecov:disable
          simple_scope_filter! :user, :users, scope_name: :touched_by_user do |arg|
            arg.description "Filter by records that were created OR updated by these users."
          end
          # simplecov:enable
        end

        # @api private
        # @!attribute [r] arguments
        # @return [Filtering::Arguments] the argument set for this filter scope
        def arguments
          @arguments ||= Filtering::Arguments.new
        end

        # Duplicate the arguments for subclasses into a fresh {Filtering::Arguments} instance.
        #
        # @api private
        # @param [Class(Filtering::HasArguments)] subclass
        # @return [void]
        def inherited(subclass)
          super

          child_args = Filtering::Arguments.new.merge arguments

          subclass.instance_variable_set(:@arguments, child_args)
        end
      end
    end
  end
end
