// in this file you can append custom step methods to 'I' object

module.exports = function () {
	return actor({
		login: function (username, password, shouldFail = false) {
			this.amOnPage("/")
			this.fillField("user", username)
			this.fillField("password", password)
			this.click("Connect")

			if (shouldFail) {
				return
			}

			this.waitForNavigation({})
			this.seeInCurrentUrl(`https://home.${process.env.PRIMARY_DOMAIN_NAME}`)
		},

		logout: async function () {
			this.clearCookie()
			this.click("#logout-button")
			this.waitInUrl(`https://auth.${process.env.PRIMARY_DOMAIN_NAME}`)
			this.wait(5)
			this.amOnPage("/")
		},
	})
}
