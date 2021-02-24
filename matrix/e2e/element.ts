/// <reference path="../../home/e2e/steps.d.ts" />

Feature("element")

Scenario("launch element", async (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Element")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)

	I.switchToNextTab()
	I.seeInCurrentUrl(`https://chat.${process.env.PRIMARY_DOMAIN_NAME}`)

	I.click("Sign In")
	I.click(".mx_SSOButton")
	I.click("I trust this address")

	// I.click(".mx_AccessibleButton_kind_danger")
	// I.click(".mx_AccessibleButton_kind_danger")
	// I.click(".mx_AccessibleButton_kind_danger")
	//
	// I.see("Mr. Admin")

	I.waitForText("#general:​flap.test")
	I.click(".mx_RoomSublist_tiles")
	I.seeElement(".mx_BasicMessageComposer_input")

	I.fillField(".mx_BasicMessageComposer_input", "Premier message")
	I.pressKey("Enter")

	I.see("Premier message")
})
