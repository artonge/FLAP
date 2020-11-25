/// <reference path="../../home/e2e/steps.d.ts" />

Feature("matomo")

Scenario("launch matomo", async (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Matomo")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)
	I.wait(20)

	I.switchToNextTab()
	I.seeInCurrentUrl(`https://analytics.${process.env.FLAP_URL}`)

	I.fillField("form_login", "theadmin")
	I.fillField("form_password", "password")
	I.click("#login_form_submit")

	I.waitForNavigation({})
	I.seeInCurrentUrl(`https://analytics.${process.env.FLAP_URL}`)

	I.waitForText("All Websites")
	I.click("All Websites")

	I.waitForText("Example")
	I.click("Example")
})
