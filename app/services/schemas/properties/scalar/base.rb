# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      # @abstract
      class Base < Schemas::Properties::BaseDefinition
        extend Dry::Core::ClassAttributes

        KNOWN_FUNCTIONS = %w[
          content
          metadata
          presentation
          sorting
          unspecified
        ].freeze

        # @!scope class
        # @!attribute [r] always_wide
        # Declare whether this property type should always be rendered wide,
        # irrespective of its configured {#wide} property.
        # @return [Boolean]
        defines :always_wide, type: Schemas::Properties::Types::Bool

        always_wide false

        # @!scope class
        # @!attribute [r] array
        # Declare whether this property represents an `Array` of values, rather
        # than a single discrete type.
        #
        # When validating values, the truthiness of this value is taken into account
        # alongside {.base_type} / {.schema_type}.
        # @return [Boolean]
        defines :array, type: Schemas::Properties::Types::Bool

        array false

        # @!scope class
        # @!attribute [r] array_element_macros
        # When {.array}, this attribute can be set to an array of macros that should be
        # applied to each element of the array in the schema when validating with a contract.
        # @return [Array]

        defines :array_element_macros, type: Schemas::Properties::Types::Array

        array_element_macros Dry::Core::Constants::EMPTY_ARRAY

        # @!scope class
        # @!attribute [r] base_type
        # @return [Schemas::Properties::Types::BaseType]
        defines :base_type, type: Schemas::Properties::Types::BaseType

        base_type :any

        # @!scope class
        # @!attribute [r] complex
        # @return [Boolean]
        defines :complex, type: Schemas::Properties::Types::Bool

        complex false

        # @!scope class
        # @!attribute [r] custom_schema_predicates
        # @return [{ Symbol => Object }]

        defines :custom_schema_predicates, type: Schemas::Properties::Types::Hash

        custom_schema_predicates Dry::Core::Constants::EMPTY_HASH

        # @!scope class
        # @!attribute [r] fillable
        # Declare that this schema property type is _fillable_, per dry-schema's definition.
        #
        # @see https://dry-rb.org/gems/dry-schema/1.9/basics/macros/#filled
        # @return [Boolean]
        defines :fillable, type: Schemas::Properties::Types::Bool

        fillable false

        # @!scope class
        # @!attribute [r] graphql_value_key
        # The key used to access the GraphQL value for this specific property type.
        #
        # @api private
        # @note This attribute is primarily used for testing.
        # @return [Symbol]
        defines :graphql_value_key, type: Schemas::Properties::Types::Symbol

        graphql_value_key :content

        # @!scope class
        # @!attribute [r] kind
        # Declare the logical grouping _kind_ of property that this is. This is used for
        # introspection via the API.
        #
        # @return [Schemas::Properties::Types::Kind]
        defines :kind, type: Schemas::Properties::Types::Kind

        kind :simple

        # @!scope class
        # @!attribute [r] orderable
        # @return [Boolean]
        defines :orderable, type: Schemas::Properties::Types::Bool

        orderable false

        # @!scope class
        # @!attribute [r] reference
        # Declare whether this property type is a reference of some sort.
        #
        # @note A truthy value also implies {.complex}.
        # @return [Boolean]
        defines :reference, type: Schemas::Properties::Types::Bool

        reference false

        # @!scope class
        # @!attribute [r] searchable
        # @return [Boolean]
        defines :searchable, type: Schemas::Properties::Types::Bool

        searchable false

        # @!scope class
        # @!attribute [r] schema_type
        # @return [Schemas::Properties::Types::SchemaType]
        defines :schema_type, type: Schemas::Properties::Types::SchemaType

        schema_type :any

        # @!attribute [rw] label
        # @return [String]
        attribute :label, :string

        # @!attribute [rw] function
        # @return [Schemas::Properties::Types::Function]
        attribute :function, :string, default: "unspecified"

        # @!attribute [rw] mappings
        # @return [<Schemas::Properties::MappingDefinition>]
        attribute :mappings, Schemas::Properties::MappingDefinition.to_array_type

        # @!attribute [rw] required
        # @return [Boolean]
        attribute :required, :boolean, default: proc { false }

        # @!attribute [rw] wide
        # @return [Boolean]
        attribute :wide, :boolean, default: proc { false }

        alias wide? wide

        # @!attribute [rw] unorderable
        # @return [Boolean]
        attribute :unorderable, :boolean, default: proc { false }

        alias unorderable? unorderable

        validates :function, presence: true, inclusion: { in: Schemas::Properties::Types::Function.values }

        delegate :always_wide?, :array?, :complex?, :kind, :reference?, :simple?,
          :scalar_reference?, :collected_reference?,
          :base_type, :schema_type, :searchable?,
          to: :class

        def actually_required? = !exclude_from_schema? && required

        # @!attribute [r] dig_path
        # An array of strings suitable for use with `Enumerable#dig`, grabbing
        # the property's group's `path` when {#nested? nested}.
        # @return [<String>]
        def dig_path = nested? ? [parent.path, path] : [path]

        # @!attribute [r] full_path
        # The full `"dot.path"` for the property, based on whether the property is {#nested? nested}.
        # @return [String]
        def full_path = nested? ? "#{parent.path}.#{path}" : path

        # Determine whether this property has a `default`.
        def has_default? = respond_to?(:default) && !default.nil?

        # Whether this property is nested under a {Schemas::Properties::GroupDefinition group}.
        def nested? = parent.kind_of?(Schemas::Properties::GroupDefinition)

        # Determine if this specific property is orderable based on its type
        # as well as if the schema author expressed it should not be.
        #
        # @see .orderable
        # @see #unorderable?
        def orderable? = self.class.orderable? && !unorderable?

        # @!attribute [r] order_path
        # A condensed order path, that contains the type in order to ensure
        # the value is properly converted when sorting.
        # @return [String, nil]
        def order_path = orderable? ? prefixed_path_with_type : nil

        # @!attribute [r] search_path
        # @return [String, nil]
        def search_path = searchable? ? prefixed_path_with_type : nil

        def prefixed_path_with_type = "props.#{full_path}##{type}"

        # @api private
        # @return [void]
        def properties=(*); end

        # @!group Schema / Contract compilation

        def add_to_schema!(context)
          return if exclude_from_schema?

          apply_schema_type_to build_schema_macro context
        end

        # Determine if a property should be excluded because of some type of invalidity.
        def exclude_from_schema?
          return true if schema_type.blank? || type == "unknown"

          false
        end

        # @api private
        # @see {.fillable}
        def fillable_schema_type? = self.class.fillable?

        # @!attribute [r] schema_predicates
        # @return [{ Symbol => Object }]
        memoize def schema_predicates
          build_schema_predicates
        end

        # @!endgroup Schema / Contract compilation

        # @!group Context / Value Extraction

        # @param [Schemas::Properties::Context] context
        # @return [Dry::Monads::Result]
        def read_value_from(context)
          extracted_value = extract_raw_value_from context

          validated_value = validate_raw_value extracted_value

          normalize_read_value validated_value
        end

        # @api private
        # @abstract
        # @param [Schemas::Properties::Context] context
        # @return [Object]
        def extract_raw_value_from(context)
          context.values.dig(*dig_path)
        end

        # @api private
        # @abstract
        # @return [Object]
        def validate_raw_value(extracted_value)
          return extracted_value if base_type.valid?(extracted_value)

          return unless array? && Dry::Types["array"].of(base_type)

          extracted_value
        end

        # @api private
        # @abstract
        # @return [Object]
        def normalize_read_value(value) = array? ? Array(value) : value

        # @param [Schemas::Properties::WriteContext] context
        # @return [void]
        def write_values_within!(context)
          context.copy_value! path
        end

        # @!endgroup Context / Value Extraction

        # @!group Version Property Hooks

        def version_property_label
          label.presence || super
        end

        def to_version_property
          super.merge(function:)
        end

        def to_version_property_metadata
          super.merge(
            order_path:,
          ).tap do |metadata|
            metadata[:default] = default if has_default?
          end.compact
        end

        # @!endgroup Version Property Hooks

        private

        # @abstract
        def apply_schema_type_to(macro)
          return apply_schema_type_for_array_to(macro) if array?

          apply_schema_type_for_default_to(macro)
        end

        def apply_schema_type_for_array_to(macro)
          array_element_macros = build_array_element_macros

          if actually_required?
            macro.array(schema_type, **schema_predicates) do
              array? > each(*array_element_macros)
            end
          else
            macro.maybe(:array, **schema_predicates) do
              array? > each(*array_element_macros)
            end
          end
        end

        def apply_schema_type_for_default_to(macro)
          if actually_required? && fillable_schema_type?
            macro.filled(schema_type, **schema_predicates)
          elsif actually_required?
            macro.value(schema_type, **schema_predicates)
          else
            macro.maybe(schema_type, **schema_predicates)
          end
        end

        def build_array_element_macros
          [*self.class.array_element_macros, build_array_element_predicates].compact_blank
        end

        def build_array_element_predicates = {}

        # @return [Dry::Schema::Macros::Required]
        # @return [Dry::Schema::Macros::Optional]
        def build_schema_macro(context)
          if actually_required?
            context.required(key)
          else
            context.optional(key)
          end
        end

        # @abstract
        # @return [{ Symbol => Object }]
        def build_schema_predicates = base_schema_predicates.merge(custom_schema_predicates)

        # @abstract
        # @return [{ Symbol => Object }]
        def base_schema_predicates = {}

        def custom_schema_predicates = self.class.custom_schema_predicates

        class << self
          # Declare that this schema property type should {.always_wide always be wide}.
          #
          # @return [void]
          def always_wide!
            always_wide true
          end

          # @param [#to_sym] key
          # @param [Object] value
          # @return [void]
          def add_schema_predicate!(key, value)
            new_predicates = custom_schema_predicates.merge(key.to_sym => value).freeze

            custom_schema_predicates new_predicates
          end

          # Declare this schema property type to be an {.array}.
          #
          # @param [Array] new_array_element_macros
          # @return [void]
          def array!(*new_array_element_macros)
            array true

            array_element_macros new_array_element_macros.flatten.freeze
          end

          # Declare this schema property type to be {.fillable}.
          #
          # @return [void]
          def fillable!
            fillable true
          end

          # Declare that this schema property type is {.orderable}.
          #
          # @return [void]
          def orderable!
            orderable true
          end

          # @return [void]
          def searchable!
            searchable true
          end

          # Declare that this schema property type is a {.reference}.
          #
          # @note This hook will also redetect the {.kind}, if necessary.
          # @return [void]
          def reference!
            reference true

            redetect_kind!
          end

          # Declare the {.schema_type} and {.base_type} for this property type.
          #
          # @note This hook will also redetect the {.kind}, if necessary.
          # @param [String, Symbol, Dry::Types::Type] value
          # @return [void]
          def schema_type!(value)
            complex !(value.kind_of?(Symbol) || value.kind_of?(String))

            schema_type Schemas::Properties::Types::SchemaType[value]

            base_type Schemas::Properties::Types::BaseType[value]

            redetect_kind!
          end

          # @!group Introspection

          # @see {.always_wide}
          def always_wide? = always_wide.present?

          # @see {.array}
          def array? = array.present?

          # Detect whether this property type implements {Schemas::Properties::References::Collected}.
          def collected_reference? = self < Schemas::Properties::References::Collected

          # @see {.complex}
          def complex? = complex.present?

          # @see {.fillable}
          def fillable? = fillable.present?

          # @!attribute [r] graphql_typename
          # The type name for this schema property.
          #
          # @api private
          # @see Types::Schematic
          # @note This attribute is primarily used for testing.
          # @return [String]
          def graphql_typename = "#{name.demodulize}Property"

          # Whether or not this property type is orderable.
          #
          # @see {.orderable}
          def orderable? = orderable.present?

          # @see {.reference}
          def reference? = reference.present?

          # Detect whether this property type implements {Schemas::Properties::References::Scalar}.
          def scalar_reference? = self < Schemas::Properties::References::Scalar

          # @see {.searchable}
          def searchable? = searchable.present?

          def simple? = !complex? && !reference?

          # @!attribute [r] type_reference
          # The type of the schema property expressed in a format suitable to use
          # as a method or hash key.
          #
          # @api private
          # @note This attribute is primarily used for testing.
          # @return [Symbol]
          def type_reference = name.demodulize.underscore.to_sym

          # @!endgroup Introspection

          private

          # @return [Schemas::Properties::Types::Kind]
          def detect_kind
            if reference?
              "reference"
            elsif complex?
              "complex"
            else
              "simple"
            end
          end

          # Set the {.kind}.
          #
          # @return [void]
          def redetect_kind!
            kind detect_kind
          end
        end
      end
    end
  end
end
