# frozen_string_literal: true

module Testing
  module GQL
    module BuildableObject
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Callbacks

        define_model_callbacks :build, :compile
      end

      UNSET = Object.new.freeze

      DEFAULT_UNAUTHORIZED_MESSAGE_PATTERN = /not authorized/i

      def initialize(...)
        super if defined?(super)
      end

      def build
        run_callbacks :build do
          yield self if block_given?
        end

        compiled = run_callbacks :compile do
          compile
        end

        return compiled
      end

      def []=(key, value)
        prop(key, value)
      end

      def prop(key, value = UNSET, &)
        if value == UNSET
          if block_given?
            object_at(key, &)
          else
            raise "must provide a value or a block"
          end
        elsif block_given?
          raise "cannot provide both a value and a block"
        else
          body[key] = value
        end

        return self
      end

      def auth_result(key, value, unauth_message_pattern: DEFAULT_UNAUTHORIZED_MESSAGE_PATTERN)
        prop key do |ar|
          ar[:value] = value

          if value
            ar[:message] = nil
          else
            ar[:message] = unauth_message_pattern
          end
        end
      end

      def auth_results(**pairs)
        pairs.each do |key, value|
          auth_result(key, value)
        end
      end

      def object_at(key, &)
        body[key] = ObjectShaper.build(&)

        return self
      end

      def array(key, &)
        body[key] = ObjectsShaper.build(&)

        return self
      end

      def schema_properties(key: "schema_properties", prefix: nil, &block)
        body[key] = SchemaPropertiesShaper.build(path_prefix: prefix, &block)

        return self
      end

      def typename(value)
        body["__typename"] = value

        return self
      end

      def compile
        body.to_h
      end

      private

      # @api private
      def body
        @body ||= Support::PropertyHash.new
      end

      module ClassMethods
        def build(*args, **kwargs, &)
          new(*args, **kwargs).build(&)
        end
      end
    end
  end
end
