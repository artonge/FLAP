import * as express from "express"

import { IUser } from "../lib"

export const authRouter = express.Router()

/**
 * - /auth
 * This route can be called by the nginx auth_request directive for SSO
 * It sets an Basic Authorization HTTP header when the request comes with a valid flap-sso cookie
 * This header can then be used by the targeted application to authenticate the user
 * Access to the targeted application is still possible without a valid flap-sso cookie
 * but the user will not be authenticated.
 */
authRouter.route("/").get(async (request, response) => {
	// If request.user is set, it means that the express-session middleware detected a valid SSO cookie.
	if (request.user) {
		const user: IUser = request.user
		// Set the Authorization HTTP header
		// Authorization: Basic base64(username)
		// Used in SOGo
		response.setHeader(
			"Authorization",
			`Basic ${Buffer.from(`${user.username}`).toString("base64")}`,
		)
		// Set various identification HTTP headers
		response.setHeader("Remote-User", user.username)
		// Used in seafile
		response.setHeader("Email", user.email)
	}

	// Always set the status to 200 because
	response.status(200)
	response.end()
})
