Feature("wordpress")

Scenario("launch wordpress", async ({I}) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	I.click(".Wordpress")

	let nb
	do {
		nb = await I.grabNumberOfOpenTabs()
		I.wait(1)
	} while (nb === 1)
	I.wait(20)

	I.switchToNextTab()
	I.seeInCurrentUrl(`https://blog.${process.env.PRIMARY_DOMAIN_NAME}`)
})
