Feature("nextcloud")

Scenario("launch nextcloud", async ({I}) => {
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
	I.seeInCurrentUrl(`https://files.${process.env.PRIMARY_DOMAIN_NAME}`)

	I.wait(2)
	if (await I.grabNumberOfVisibleElements(".header-close") > 0) {
		I.waitForElement(".header-close")
		I.click(".header-close")
		I.waitToHide(".header-close")
	}

	I.waitForText("All files")
	I.see("All files")
	I.see("Deleted files")
	I.see("Settings")

	I.click(".button.new")
	I.waitForText("New text document")
	I.click("New text document")
	I.waitForElement("#view12-input-file")
	I.fillField("#view12-input-file", "test.md")
	I.click(".icon-confirm")
	I.click("Create")

	I.waitForElement(".editor__content")
	I.wait(2)
	I.fillField(".editor__content", "New text document content.")
	I.click(".header-close")

	I.waitUrlEquals(`https://files.${process.env.PRIMARY_DOMAIN_NAME}/apps/files/?dir=/`)
	I.wait(2)
	I.click("test.md")
	I.waitForText("New text document content.")
	I.click(".header-close")

	I.waitForText("All files")
	I.wait(2)
	I.click(locate("tr").withAttr({ "data-file": "test.md" }).find(".fileactions .icon-more"))
	I.click("Delete file")
})
