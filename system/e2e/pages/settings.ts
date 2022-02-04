const { I } = inject()

export = {
	open(tab = "me") {
		I.click("#settings-link")
		I.waitInUrl(`https://home.${process.env.PRIMARY_DOMAIN_NAME}/settings`)
		I.waitForElement(`//li[@role='tab'][@aria-controls='${tab}']`)
		I.click(`//li[@role='tab'][@aria-controls='${tab}']`)
	},

	createUser(
		fullname: string,
		email: string,
		username: string,
		password: string,
	) {
		I.click("Add a user")

		within(".user-creation-form", () => {
			I.fillField("fullname", fullname)
			I.fillField("email", email)
			I.seeInField("username", username)
			I.fillField("password", password)
			I.click("Create the new user")
			I.dontSeeElement(".ui-alert")
		})

		I.waitForElement(`.${username}`)
		I.dontSee(".user-creation-form")
	},

	deleteUser(username: string) {
		I.seeElement(`.${username}`)

		within(`.${username}`, () => {
			I.click("Delete the user")
		})

		within(".ui-modal.is-open", () => {
			I.see("Do you really want to delete: user ?")
			I.click("delete")
		})

		I.dontSeeElement(`.${username}`)
	},

	updateMyInfo(fullname: string, email: string) {
		I.click("Update my information")

		I.waitForText("Profile modification")

		within("#profile-form", () => {
			I.clearField("fullname")
			I.fillField("fullname", fullname)
			I.clearField("email")
			I.fillField("email", email)
			I.click("update")
			I.dontSeeElement(".ui-alert")
		})

		I.waitForInvisible("#profile-form")
	},

	updateMyPassword(oldPassword: string, newPassword: string) {
		I.click("Update my password")

		I.waitForText("Password modification")

		within("#password-form", () => {
			I.fillField("oldPassword", oldPassword)
			I.fillField("newPassword", newPassword)
			I.click("update")
			I.dontSeeElement(".ui-alert")
		})

		I.waitForInvisible("#password-form")
	},
}
