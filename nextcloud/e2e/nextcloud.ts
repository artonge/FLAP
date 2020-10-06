/// <reference path="../../home/e2e/steps.d.ts" />

Feature("nextcloud")

Scenario("launch nextcloud", async (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Nextcloud")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)
	I.wait(20)

	I.switchToNextTab()
	I.seeInCurrentUrl("https://files.flap.test")

	I.waitForElement(".header-close")
	I.click(".header-close")

	I.wait(2)

	I.waitForText("All files")
	I.see("All files")
	I.see("Deleted files")
	I.see("Settings")

	I.click(".button.new")
	I.waitForText("New text document")
	I.click("New text document")
	I.waitForElement("#view13-input-file")
	I.fillField("#view13-input-file", "test.md")
	I.click(".icon-confirm")

	I.waitForElement(".editor__content")
	I.wait(2)
	I.fillField(".editor__content", "New text document content.")
	I.click(".header-close")
	I.click(".app-sidebar__close")

	I.waitForText("All files")
	I.click("test.md")
	I.waitForText("New text document content.")
	I.click(".header-close")

	I.waitForText("All files")
	I.wait(2)
	I.click(locate("tr").withAttr({ "data-file": "test.md" }).find(".fileactions .icon-more"))
	I.click("Delete file")
})
