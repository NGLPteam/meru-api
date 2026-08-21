# frozen_string_literal: true

class Shrine
  module Plugins
    module SelfRegistering
      module AttachmentMethods
        def included(klass)
          super

          klass.register_shrine_attachment! @name
        end
      end
    end

    register_plugin(:self_registering, SelfRegistering)
  end
end

# Enable the plugin automatically
Shrine.plugin :self_registering
