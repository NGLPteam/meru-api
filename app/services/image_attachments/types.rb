# frozen_string_literal: true

module ImageAttachments
  # Types related to working with image attachments of varying domains.
  module Types
    extend ::Support::Typespace

    extend Constants

    # A positive (non-zero) dimension for height or width.
    Dimension = Integer.constrained(gt: 0)

    # @see ImageAttachments::Constants::IMAGE_SIZES
    Format = Coercible::Symbol.enum(*Constants::FORMATS)

    # @see ImageUploader
    ImageAttacher = Instance(ImageUploader::Attacher)

    # @see ImageAttachments::Constants::IMAGE_SIZES
    ImageSize = Coercible::Symbol.enum(*Constants::IMAGE_SIZES.keys)

    # @see ImageUploader
    ImageUploadedFile = Instance(ImageUploader::UploadedFile)

    # The "purpose" a given image attachment serves
    #
    # @see Types::ImagePurposeType
    Purpose = String.enum("hero_image", "logo", "site_logo", "thumbnail", "other").fallback("other")

    # The "scope" for image uploaders
    #
    # * `:image` => {ImageAttachments::ImageWrapper}, {ImageUploader}
    # * `:site_logo` => {ImageAttachments::SiteLogoWrapper}, {SiteLogoUploader}
    Scope = Coercible::Symbol.enum(:image, :site_logo)

    # @see SiteLogoUploader
    SiteLogoAttacher = Instance(SiteLogoUploader::Attacher)

    # @see ImageAttachments::Constants::SITE_LOGO_SIZES
    SiteLogoSize = Coercible::Symbol.enum(*Constants::SITE_LOGO_SIZES.keys)

    # @see SiteLogoUploader
    SiteLogoUploadedFile = Instance(SiteLogoUploader::UploadedFile)

    # A sum type matching attachers
    Attacher = ImageAttacher | SiteLogoAttacher

    # A sum type for matching derivative sizes
    Size = ImageSize | SiteLogoSize

    # A sum type for matching uploaded files
    UploadedFile = ImageUploadedFile | SiteLogoUploadedFile

    # A hash type for matching image attachment metadata
    Metadata = Coercible::Hash.schema(
      alt?: String.optional,
    ).with_key_transform(&:to_sym)
  end
end
