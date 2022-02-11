/// <reference path='../steps.d.ts' />

Feature("create_user")

Scenario("test create and delete user", ({I, settingsPage}) => {
	I.amOnPage("/")
	I.login("theadmin", "password")

	settingsPage.open("users")
	settingsPage.createUser("User 1", "user1@example.com", "user", "password1")

	session("user", () => {
		I.amOnPage("/")
		I.login("user", "password1")

		settingsPage.open("me")

		I.see("User 1")
		I.see("user")
		I.see("user1@example.com")

		settingsPage.updateMyInfo(
			"User 1 new name",
			"user1_new_email@example.com",
		)

		I.see("User 1 new name")
		I.see("user1_new_email@example.com")

		settingsPage.updateMyPassword("password1", "newPassword")

		I.logout()

		I.login("user", "newPassword")
	})

	settingsPage.deleteUser("user")
})
