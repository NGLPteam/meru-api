# frozen_string_literal: true

module Assets
  class ParseKind
    include Dry::Monads[:result]

    # @param [File, IO, Shrine::UploadedFile] io
    # @return [Dry::Monads::Success(Assets::Types::Kind)]
    def call(io)
      case io
      when ::File, ::IO, ::Tempfile
        for_file(io)
      when Shrine::UploadedFile
        for_uploaded_file(io)
      else
        # simplecov:disable
        Success("unknown")
        # simplecov:enable
      end
    end

    private

    # @param [File, IO, Tempfile] file
    # @return [Dry::Monads::Success(Assets::Types::Kind)]
    def for_file(io)
      mime_type = Shrine.determine_mime_type(io)

      case mime_type
      when "application/pdf"
        Success("pdf")
      when %r{\Aimage/}
        Success("image")
      when %r{\Aaudio/}
        Success("audio")
      when %r{\Avideo/}
        Success("video")
      else
        # simplecov:disable
        Success("document")
        # simplecov:enable
      end
    end

    # @param [Shrine::UploadedFile] io
    # @return [Dry::Monads::Success(Assets::Types::Kind)]
    def for_uploaded_file(io)
      if io.image?
        Success("image")
      elsif io.video?
        Success("video")
      elsif io.audio?
        Success("audio")
      elsif io.pdf? || io.mime_type == "application/pdf"
        Success("pdf")
      else
        # simplecov:disable
        Success("document")
        # simplecov:enable
      end
    end
  end
end
