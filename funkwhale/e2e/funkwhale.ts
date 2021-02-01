/// <reference path="../../home/e2e/steps.d.ts" />

Feature("funkwhale")

Scenario("launch funkwhale", async (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Funkwhale")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)

	I.switchToNextTab()
	I.seeInCurrentUrl("https://audio.flap.test")

	this.fillField("user", "theadmin")
	this.fillField("password", "password")
	this.click("Connect")
})
