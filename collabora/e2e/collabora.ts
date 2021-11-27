// / <reference path='../../home/e2e/steps.d.ts' />
Feature("collabora")

Scenario("launch collabora", async ({I}) => {
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
	I.pressKey('Escape')

	I.waitForText("All files")

	I.click(".button.new")
	I.waitForText("New document")
	I.click("New document")
	const input = locate('input').withAttr({ value: 'New document.odt' })
	I.waitForElement(input)
	I.fillField(input, "rich file.odt")
	I.click(".icon-confirm")
	I.click("Create")

	I.wait(5)
	within({frame: ['#richdocumentsframe', '#loleafletframe'] as any}, () => {
		I.waitForText("File")
		I.see("Home")
		I.see("Insert")
		I.see("Layout")

		I.waitForElement("#document-canvas")
		I.fillField("#document-canvas", "New text document content.")
		I.click("#closebutton")
	})

	I.waitUrlEquals(`https://files.${process.env.PRIMARY_DOMAIN_NAME}/apps/files/?dir=/`)
})
