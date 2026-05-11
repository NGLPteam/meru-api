# frozen_string_literal: true

module Submissions
  # Attach the default contribution(s) for a submission.
  #
  # Presently, this will only attach an author contribution for the submission's associated {User},
  # but in the future we may allow other contributions to be attached to the {SubmissionTarget},
  # or via other logic.
  #
  # @see Submissions::AttachContributions
  class ContributionsAttacher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Types::Submission
    end

    standard_execution!

    delegate :entity, :user, to: :submission, prefix: :submission

    alias submitter submission_user

    # @return [Contributor]
    attr_reader :author

    # @return [ControlledVocabularyItem]
    attr_reader :author_role

    # @return [ControlledVocabulary]
    attr_reader :controlled_vocabulary

    # @return [ControlledVocabularyItem]
    attr_reader :default_role

    # @return [ContributionRoleConfiguration]
    attr_reader :system_configuration

    # @return [Dry::Monads::Success(void)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield persist!
      end

      Success()
    end

    wrapped_hook! def prepare
      @author = yield submitter.fetch_author

      load_role_config!

      super
    end

    wrapped_hook! def persist
      yield submission_entity.attach_contribution(author, role: author_role)

      super
    end

    private

    def load_role_config!
      @system_configuration = GlobalConfiguration.fetch.contribution_role_configuration

      @controlled_vocabulary = @system_configuration.controlled_vocabulary

      load_default_role!

      load_author_role!
    end

    # @return [void]
    def load_author_role!
      @author_role = find_candidate_role_within! do |y|
        y << controlled_vocabulary.first_tagged_with("author")
        y << default_role
      end
    end

    # @return [void]
    def load_default_role!
      @default_role = find_candidate_role_within! do |y|
        y << controlled_vocabulary.first_tagged_with("default")
        y << system_configuration.default_item
      end
    end

    def find_candidate_role_within!
      candidates = Enumerator.new do |y|
        yield y
      end.lazy

      candidates.detect(&:present?) or raise "No candidate found"
    end
  end
end
