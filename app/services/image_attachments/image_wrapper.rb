# frozen_string_literal: true

module ImageAttachments
  # This class wraps an {ImageUploader::Attacher} and presents it in a way
  # suitable for consumption by the GraphQL API.
  #
  # @see ImageUploader
  # @see Types::ImageAttachmentType
  class ImageWrapper
    include ::Support::Typing
    include Dry::Core::Memoizable
    include Dry::Initializer[undefined: false].define -> do
      param :attacher, ImageAttachments::Types::Attacher

      option :purpose, ImageAttachments::Types::Purpose, default: proc { "other" }
    end

    delegate :file, to: :attacher, prefix: :original
    delegate :alt, :original_filename, to: :original_file, allow_nil: true

    def metadata
      original_file&.graphql_metadata
    end

    # @return [ImageAttachments::Original]
    memoize def original
      OriginalWrapper.new self, original_file
    end

    # @!attribute [r] storage
    # Returns the storage associated with the file.
    # @return [:cache, :store, :derivatives, :remote, nil]
    def storage
      original_file&.storage_key
    end

    def method_missing(meth, *args, &)
      if ImageAttachments.image_size?(meth) && args.empty?
        size_wrapper meth
      else
        # :nocov:
        super
        # :nocov:
      end
    end

    def respond_to_missing?(meth, include_private = false)
      ImageAttachments.image_size?(meth) || super
    end

    private

    memoize def size_wrapper(size)
      SizeWrapper.new self, ImageAttachments.image_size(size)
    end
  end
end
