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
	I.seeInCurrentUrl("https://music.flap.test")

	I.fillField("username", "theadmin")
	I.fillField("password", "password")
	within('.main', () => {
		I.click("Login")
	})

	I.see('My Library')
	I.see('Recently listened')
	
	I.click('.user-dropdown')
	I.wait(1)
	I.click('Logout')
	I.wait(1)
	I.click('Yes, log me out!')
	
	I.dontSee('My Library')
})
