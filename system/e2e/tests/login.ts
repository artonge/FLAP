/// <reference path='../steps.d.ts' />

Feature("login")

Scenario("test login valid credentials", ({I}) => {
	I.amOnPage("/")

	I.seeInCurrentUrl(`https://auth.${process.env.PRIMARY_DOMAIN_NAME}`)
	I.dontSeeCookie("flap-sso")

	I.login("theadmin", "password")

	I.seeInCurrentUrl(`https://home.${process.env.PRIMARY_DOMAIN_NAME}`)
	I.seeCookie("flap-sso")
	I.see("FLAP of Mr. Admin")
})

Scenario("test login wrong credentials", ({I}) => {
	I.amOnPage("/")

	I.login("wrong_user", "wrong_password", true)

	I.see("Wrong credentials")
	I.dontSeeCookie("flap-sso")
	I.seeInCurrentUrl(`https://auth.${process.env.PRIMARY_DOMAIN_NAME}`)
})

Scenario("test logout", ({I}) => {
	I.amOnPage("/")

	I.login("theadmin", "password")
	I.logout()

	I.seeInCurrentUrl(`https://auth.${process.env.PRIMARY_DOMAIN_NAME}`)
})

Scenario("test login logout login", ({I}) => {
	I.amOnPage("/")

	I.login("theadmin", "password")
	I.logout()
	I.login("theadmin", "password")

	I.seeInCurrentUrl(`https://home.${process.env.PRIMARY_DOMAIN_NAME}`)
})
