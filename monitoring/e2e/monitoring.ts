/// <reference path="../../home/e2e/steps.d.ts" />

Feature("monitoring")

Scenario("launch monitoring", (I) => {
	I.amOnPage(`https://monitoring.${process.env.PRIMARY_DOMAIN_NAME}`)

	I.waitForText("Welcome to Grafana")

	I.fillField("user", "admin")
	I.fillField("password", process.env.ADMIN_PWD)
	I.click("Log in")

	I.waitForText("Dashboards")

	I.amOnPage(`https://monitoring.${process.env.PRIMARY_DOMAIN_NAME}/?search=open`)
	I.see("Docker Containers")
	I.see("Docker Host")
	I.see("Monitor Services")
	I.see("Synapse")
	I.see("Nginx")
})
