Feature("peertube")

Scenario("launch peertube", async ({I}) => {
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

	I.waitForText("Login")

	I.see("Discover")
	I.see("Trending")

	I.click("FLAP SSO (flap.test)")

	I.waitForText("My account")
	I.see("My library")

	I.click("Remind me later")
	
	I.wait(2)
	I.click(".logged-in-more")

	I.click("Log out")

	I.see("Login")
})
