import { getOwner } from "@ember/owner";
import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import selectKit from "discourse/tests/helpers/select-kit-helper";

acceptance(
  "DiscoursePresetTopicComposer - new topic dropdown",
  function (needs) {
    needs.user();
    needs.site({
      topic_preset_buttons: [{ id: "NEW_BUG", name: "Report a bug" }],
    });

    test("app event on change", async function (assert) {
      const appEvents = getOwner(this).lookup("service:app-events");
      appEvents.on(
        "discourse-preset-topic-composer:new-topic-preset-selected",
        () => {
          assert.step("triggered");
        }
      );

      await visit("/");

      const newTopicDropdown = selectKit(".new-topic-dropdown");
      await newTopicDropdown.expand();
      await newTopicDropdown.selectRowByValue("NEW_BUG");

      assert.verifySteps(["triggered"]);
    });
  }
);
