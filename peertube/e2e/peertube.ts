/// <reference path="../../home/e2e/steps.d.ts" />

Feature("peertube")

xScenario("launch peertube", async (I) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Peertube")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)

	I.switchToNextTab()
	I.seeInCurrentUrl("https://video.flap.test")

	I.waitForText("Videos")
	I.see("Discover")
	I.see("Administration")
})
