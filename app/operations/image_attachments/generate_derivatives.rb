# frozen_string_literal: true

module ImageAttachments
  # Generate derivatives for a specific uploader
  #
  # @see ImageAttachments.each_scoped_size
  class GenerateDerivatives
    include Dry::Monads[:result]

    # @param [IO] original
    # @param [ImageAttachments::Types::Scope] scope
    # @return [Dry::Monads::Success(Hash)]
    def call(original, scope: :image)
      vips = ImageProcessing::Vips.source(original)

      derivatives = ImageAttachments.each_scoped_size(scope).each_with_object({}) do |size, sizes|
        resized = vips.resize_to_limit(size.width, size.height)

        sizes[size.name] = ImageAttachments.each_format.to_h do |format|
          [format.to_sym, resized.convert!(format.to_s)]
        end
      end

      Success derivatives
    end
  end
end
