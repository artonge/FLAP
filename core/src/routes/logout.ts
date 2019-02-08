import * as express from "express"

export const logoutRouter = express.Router()

// /logout
logoutRouter.route("/").get(async (request, response) => {
	request.logout()
	response.redirect("/login")
	response.end()
})
