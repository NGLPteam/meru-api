# frozen_string_literal: true

module Support
  module HookBased
    # @abstract
    class AbstractHookModule < Module
      include Dry::Initializer[undefined: false].define -> do
        param :hook_name, Types::HookName
      end

      def inspect
        # simplecov:disable
        "#{self.class}[#{hook_name.inspect}]"
        # simplecov:enable
      end
    end
  end
end
