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
})
