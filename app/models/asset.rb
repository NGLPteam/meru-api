# frozen_string_literal: true

class Asset < ApplicationRecord
  include GenericUploader::Attachment.new(:attachment)
  include GenericUploader::Attachment.new(:alternatives)
  include ImageUploader::Attachment.new(:preview)
  include HasEphemeralSystemSlug
  include Liquifies
  include SchematicReferent
  include ScopesForIdentifier
  include TimestampScopes

  drop_klass Templates::Drops::AssetDrop

  pg_enum! :kind, as: "asset_kind"

  MEDIA_KINDS = %w[audio video image].freeze

  belongs_to :attachable, polymorphic: true, inverse_of: :assets

  belongs_to :community, optional: true
  belongs_to :collection, optional: true
  belongs_to :item, optional: true

  before_validation :enforce_foreign_key!

  scope :by_kind, ->(kind) { where(kind:) }
  scope :audios, -> { by_kind(:audio) }
  scope :images, -> { by_kind(:image) }
  scope :videos, -> { by_kind(:video) }
  scope :media, -> { by_kind(MEDIA_KINDS) }
  scope :pdfs, -> { by_kind(:pdf) }
  scope :documents, -> { by_kind(:document) }

  scope :sans_preview, -> { where(%(preview_data ->> 'id' IS NULL)) }
  scope :with_preview, -> { where(%(preview_data ->> 'id' IS NOT NULL)) }

  scope :with_unpromoted_preview, -> { where(%(preview_data ->> 'storage' = 'cache')) }

  validates :attachment, :name, :content_type, :file_size, presence: true
  validates :identifier, uniqueness: { scope: %i[attachable_type attachable_id], if: :identifier? }

  delegate :original_filename, to: :attachment, allow_nil: true

  # @note Compatibility for {EntityChildRecordPolicy}
  def entity = attachable

  # We mask this with {#download_url} in order to track analytics of a download.
  #
  # @return [String]
  def actual_download_url
    attachment.url(
      public: false,
      expires_in: 15.minutes.to_i,
      response_content_disposition:,
    )
  end

  # @return [String]
  def content_disposition = ContentDisposition.attachment(download_name)

  alias response_content_disposition content_disposition

  # @return [String]
  def download_name
    # :nocov:
    return original_filename if original_filename.present?

    extension = Mime::Type.lookup(content_type).try(:symbol).try(:to_s)

    extension = ".#{extension}" if extension

    return name unless extension.present?

    base = File.basename(name, extension)

    "#{base}#{extension}"
    # :nocov:
  end

  # @api private
  # @note Only used for testing request specs.
  # @return [String, nil]
  def download_token
    url = download_url

    Rack::Utils.parse_query(URI(url).query)["token"]
  end

  # @return [String]
  def download_url = generate_download_url!(mode: "download")

  # @return [String]
  def view_url = generate_download_url!(mode: "view")

  def has_attachment? = persisted? && attachment.present?

  # @return [Class]
  def graphql_node_type
    if image?
      Types::AssetImageType
    elsif video?
      Types::AssetVideoType
    elsif audio?
      Types::AssetAudioType
    elsif pdf?
      Types::AssetPDFType
    elsif document?
      Types::AssetDocumentType
    else
      Types::AssetUnknownType
    end
  end

  # @return [void]
  def refresh_metadata!
    attachment_attacher.refresh_metadata!

    save!
  end

  # @!attribute [r] signature
  # @return [String, nil]
  def signature = attachment&.metadata&.[]("sha256")

  def to_schematic_referent_label = name

  # @param [String] token
  # @return [Dry::Monads::Success(Boolean)]
  monadic_operation! def decode_download_token(token)
    call_operation("assets.decode_download_token", self, token)
  end

  # @param [Hash] options
  # @return [Dry::Monads::Success(Boolean)]
  monadic_operation! def encode_download_token(**options)
    call_operation("assets.encode_download_token", self, **options)
  end

  # @param [Hash] options
  # @return [Dry::Monads::Success(String)]
  monadic_operation! def generate_download_url(**options)
    call_operation("assets.generate_download_url", self, **options)
  end

  private

  # @return [void]
  def enforce_foreign_key!
    case attachable
    when Community
      self.community = attachable
      self.collection = nil
      self.item = nil
    when Collection
      self.community = nil
      self.collection = attachable
      self.item = nil
    when Item
      self.community = nil
      self.collection = nil
      self.item = attachable
    else
      errors.add :attachable, "not a valid attachable"
    end
  end
end
