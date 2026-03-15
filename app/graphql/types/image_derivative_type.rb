# frozen_string_literal: true

module Types
  # @see ImageAttachments::FormatWrapper
  class ImageDerivativeType < Types::BaseObject
    disable_auth_checks!

    description "A derivative of the image with a specific size and format."

    implements Types::ImageType

    field :format, Types::ImageDerivativeFormatType, null: false do
      description "The format of this derivative"
    end

    field :size, Types::ImageDerivativeSizeType, null: false, method: :size_name do
      description "The size of this derivative"
    end

    field :max_height, Int, null: true do
      description "The maximum height this size can occupy"
    end

    field :max_width, Int, null: true do
      description "The maximum width this size can occupy"
    end
  end
end
