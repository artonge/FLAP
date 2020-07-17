/// <reference path="../../home/e2e/steps.d.ts" />

Feature("nextcloud")

Scenario("launch nextcloud", (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Nextcloud")

	I.wait(2)
	I.switchToNextTab()
	I.seeInCurrentUrl("https://files.flap.test")

	I.see("All files")
	I.see("Deleted files")
	I.see("Settings")

	I.click(".button.new")
	I.click("New text document")
	I.fillField("#view13-input-file", "test.md")
	I.click(".icon-confirm")

	I.waitForText("Add notes, lists or links")
	I.wait(2)
	I.fillField(".editor__content", "New text document content.")
	I.click(".header-close")

	I.click(".app-sidebar__close")
	I.wait(1)
	I.click("test.md")
	I.waitForText("New text document content.")
	I.click(".header-close")

	I.wait(3)
	I.click(locate("tr").withAttr({ "data-file": "test.md" }).find(".fileactions .icon-more"))
	I.click("Delete file")
})
