# frozen_string_literal: true

module Metadata
  module Pressbooks
    module Books
      # Metadata embedded in a paginated book response.
      class EmbeddedMetadata < ::Metadata::Pressbooks::Books::CommonMetadata
        attribute :h5p_activity_count, :integer

        attribute :in_catalog, :boolean

        attribute :last_updated, :time

        attribute :network, ::Metadata::Pressbooks::Network

        attribute :storage_size, :integer

        attribute :word_count, :integer

        json do
          map "h5pActivities", to: :h5p_activity_count

          map "inCatalog", to: :in_catalog

          map "lastUpdated", to: :last_updated, with: { to: :encode_last_updated, from: :decode_last_updated }

          map "network", to: :network

          map "storageSize", to: :storage_size

          map "wordCount", to: :word_count
        end

        def decode_last_updated(model, value)
          model.last_updated = parse_json_time(value)
        end

        def encode_last_updated(model, doc)
          # simplecov:disable
          return if model.last_updated.nil?
          # simplecov:enable

          doc["lastUpdated"] = model.last_updated.to_i
        end
      end
    end
  end
end
