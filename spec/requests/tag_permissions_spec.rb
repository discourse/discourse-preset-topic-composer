# frozen_string_literal: true

describe "Preset Topic Composer | tag permissions" do
  fab!(:admin)
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:permitted_group) { Fabricate(:group, name: "permitted_group") }
  fab!(:restricted_tag) { Fabricate(:tag, name: "restricted-tag") }
  fab!(:open_tag) { Fabricate(:tag, name: "open-tag") }
  fab!(:tag_group) do
    Fabricate(:tag_group, name: "Restricted Tags", tags: [restricted_tag, open_tag])
  end
  fab!(:category) { Fabricate(:category, allowed_tag_groups: [tag_group.name]) }

  before do
    SiteSetting.discourse_preset_topic_composer_enabled = true
    SiteSetting.tagging_enabled = true

    TagGroupPermission.where(tag_group: tag_group, group_id: Group::AUTO_GROUPS[:everyone]).update(
      permission_type: TagGroupPermission.permission_types[:readonly],
    )
    TagGroupPermission.create!(
      tag_group: tag_group,
      group_id: permitted_group.id,
      permission_type: TagGroupPermission.permission_types[:full],
    )
  end

  def create_topic_with_tags_to_add(topic_user, tags_to_add)
    post =
      PostCreator.create!(
        topic_user,
        title: "a test topic with preset tags",
        raw: "this is a test body for the preset topic",
        category: category.id,
        tags_to_add: tags_to_add,
      )
    post.topic
  end

  it "does not add restricted tags for unpermitted users" do
    topic =
      create_topic_with_tags_to_add(
        user,
        { "Restricted Tags" => [restricted_tag.name, open_tag.name] },
      )

    expect(topic.tags.pluck(:name)).not_to include(restricted_tag.name)
  end

  it "adds restricted tags for users in the permitted group" do
    permitted_group.add(user)

    topic =
      create_topic_with_tags_to_add(
        user,
        { "Restricted Tags" => [restricted_tag.name, open_tag.name] },
      )

    tag_names = topic.tags.pluck(:name)
    expect(tag_names).to include(restricted_tag.name)
    expect(tag_names).to include(open_tag.name)
  end

  it "adds restricted tags for admins" do
    topic = create_topic_with_tags_to_add(admin, { "Restricted Tags" => [restricted_tag.name] })

    expect(topic.tags.pluck(:name)).to include(restricted_tag.name)
  end

  it "does not add hidden tags for unpermitted users" do
    hidden_tag = Fabricate(:tag, name: "hidden-tag")
    hidden_group = Fabricate(:tag_group, name: "Hidden Tags", tags: [hidden_tag])
    category.update!(allowed_tag_groups: [tag_group.name, hidden_group.name])
    TagGroupPermission.where(
      tag_group: hidden_group,
      group_id: Group::AUTO_GROUPS[:everyone],
    ).destroy_all
    TagGroupPermission.create!(
      tag_group: hidden_group,
      group_id: permitted_group.id,
      permission_type: TagGroupPermission.permission_types[:full],
    )

    topic = create_topic_with_tags_to_add(user, { "Hidden Tags" => [hidden_tag.name] })

    expect(topic.tags.pluck(:name)).not_to include(hidden_tag.name)
  end

  it "resolves tag synonyms and respects permissions on the target tag" do
    synonym = Fabricate(:tag, name: "restricted-synonym", target_tag: restricted_tag)
    permitted_group.add(user)

    topic = create_topic_with_tags_to_add(user, { "Restricted Tags" => [synonym.name] })

    expect(topic.tags.pluck(:name)).to include(restricted_tag.name)
  end
end
