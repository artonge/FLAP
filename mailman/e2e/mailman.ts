/// <reference path="../../home/e2e/steps.d.ts" />

Feature("mailman")

Scenario("launch mailman", async (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Mailman")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)

	I.switchToNextTab()
	I.seeInCurrentUrl("https://lists.flap.test")

	I.click("Login")

	within("form", () => {
		I.fillField("login", "theadmin")
		I.fillField("password", "password")
		I.click("Sign In")
	})
	
	I.waitForNavigation({})
	I.seeInCurrentUrl(`https://list.${process.env.PRIMARY_DOMAIN_NAME}`)

	I.waitForText("Available lists")

	I.click("theadmin")
	I.click("Logout")
	I.click("Sign Out")
})
