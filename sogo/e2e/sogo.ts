Feature("sogo")

Scenario("launch sogo", async ({I}) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Sogo")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)

	I.switchToNextTab()
	I.seeInCurrentUrl(`https://mail.${process.env.PRIMARY_DOMAIN_NAME}`)

	I.waitForText("Inbox")

	I.click("Address Book")
	I.waitForText("Personal Address Book")

	I.click("Contacts FLAP")
	I.see("Mr. Admin")

	I.click("Calendar")
	I.waitForText("EVENTS")
	I.see("TASKS")
	I.see("Next 7 days")
})
