# frozen_string_literal: true

module Seeding
  module Export
    # @abstract
    class AbstractExporter
      extend ActiveModel::Callbacks
      extend Dry::Initializer

      include Dry::Effects.Interrupt(:skip)

      define_model_callbacks :export

      # @api private
      # @return [Jbuilder]
      attr_reader :builder

      def call
        builder = Jbuilder.new do |json|
          json.ignore_nil!

          @builder = json

          run_callbacks :export do
            export! json
          end
        end

        return builder
      end

      # @abstract
      # @param [Jbuilder] json
      # @return [void]
      def export!(json)
        # simplecov:disable
        raise NotImplementedError, "must implement #{self.class}##{__method__}"
        # simplecov:enable
      end

      # @param [Shrine::UploadedFile] uploaded_file
      # @return [Hash, nil]
      def uploaded_file!(uploaded_file)
        return if uploaded_file.blank?

        {
          format: "url",
          url: uploaded_file.url,
        }.stringify_keys
      end

      # @see Seeding::Export::Dispatch
      # @param [Object] object
      # @return [#as_json, nil]
      def dispatch_export!(object)
        MeruAPI::Container["seeding.export.dispatch"].(object)
      end
    end
  end
end
