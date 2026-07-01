# frozen_string_literal: true

module MutationOperations
  module Attachments
    class Attribute
      include Dry::Core::Equalizer.new(:name)

      include Dry::Initializer[undefined: false].define -> do
        param :name, ::Support::GlobalTypes::Symbol

        option :image, ::Support::GlobalTypes::Bool, default: false, optional: true
      end

      # Assign attachment values to a given model and mutably
      # alter the provided `args`, so that they can later be used
      #
      # @note `args` is mutated by this method, as it deletes keys
      #   that are consumed by attachments.
      # @param [ApplicationRecord] model
      # @param [{ Symbol => Object }] args
      # @return [void]
      def assign!(model, args)
        attacher = attacher_for model

        file = args.delete name

        should_clear = args.delete clear

        new_metadata = prepare_metadata args.delete metadata

        if file.present?
          # Replace file and maybe update metadata
          attacher.model_assign file

          attacher.add_metadata new_metadata if new_metadata.present?
        elsif should_clear
          # Clear the file, ignore metadata
          attacher.assign nil
        elsif attacher.attached? && new_metadata.present?
          # Update metadata only
          attacher.add_metadata new_metadata
        end
      end

      def attacher_for(model)
        model.public_send(:"#{name}_attacher")
      end

      def clear
        :"clear_#{name}"
      end

      def contract
        @contract ||= build_contract
      end

      def metadata
        :"#{name}_metadata"
      end

      private

      def build_contract
        ContractBuilder.new(name, image:).call
      end

      # @param [MutationOperations::Attachments::Attribute] attachment
      # @param [Hash, nil] value
      # @return [{ String => Object }, nil]
      def prepare_metadata(value)
        # simplecov:disable
        return nil unless image
        # simplecov:enable

        MeruAPI::Container["image_attachments.sanitize_metadata"].call value
      end
    end
  end
end
