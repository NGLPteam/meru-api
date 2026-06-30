# frozen_string_literal: true

RSpec.shared_context "all roles" do
  def role_admin = fixture(:role_admin)

  def role_manager = fixture(:role_manager)

  def role_editor = fixture(:role_editor)

  def role_reviewer = fixture(:role_reviewer)

  def role_depositor = fixture(:role_depositor)

  def role_author = fixture(:role_author)

  def role_reader = fixture(:role_reader)
end

RSpec.shared_context "all standard users" do
  def admin_user = fixture(:admin_user)

  alias_method :admin, :admin_user

  def regular_user = fixture(:regular_user)

  def anonymous_user = @anonymous_user ||= AnonymousUser.new
end

RSpec.shared_context "authorization testing" do
  include_context "all roles"
  include_context "all standard users"
end

RSpec.shared_context "entity authorization testing" do
  include_context "authorization testing"

  def item_schema_version = fixture(:item_schema_version)

  def community = fixture(:community)
  def collection = fixture(:collection)
  def item = fixture(:item)

  def community_manager = fixture(:community_manager)
  def community_editor = fixture(:community_editor)
  def community_reader = fixture(:community_reader)
  def collection_editor = fixture(:collection_editor)

  let(:manager) { community_manager }
  let(:editor) { community_editor }
  let(:reader) { community_reader }
end

RSpec.shared_context "depositing authorization testing" do
  include_context "entity authorization testing"

  def submission_target = fixture(:submission_target)

  def reviewer = fixture(:reviewer)

  def submitter = fixture(:submitter)

  def submission = fixture(:submission)
end
