# frozen_string_literal: true

module SubmissionTargets
  # A section within an {SubmissionTargets::Description}.
  class Section
    include Support::EnhancedStoreModel

    # @!attribute [r] position
    #   The position of the section within the description,
    #   which can be used for ordering sections when rendering.
    #   @return [Integer]
    attribute :position, :integer

    # @!attribute [rw] identifier
    #   A unique identifier for the section, which can be used to reference it in the DOM.
    #   @return [String]
    attribute :identifier, :string, default: ""

    # @!attribute [rw] name
    #   The name of the section.
    #   @return [String]
    attribute :name, :string, default: ""

    # @!attribute [rw] content
    #   Markdown content for the section.
    #   @return [String]
    attribute :content, :string, default: ""

    strip_attributes only: %i[name], collapse_spaces: true, replace_newlines: true, allow_empty: true
    strip_attributes only: %i[content], allow_empty: true

    validates :name, :identifier, :content, :position, presence: true

    # @api private
    # @return [String, nil]
    def base_identifier
      return unless name?

      name.parameterize
    end
  end
end
