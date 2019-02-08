import * as express from "express"
import passport = require("passport")

export const loginRouter = express.Router()

// /login
loginRouter
	.route("/")
	.get(async (request, response) => {
		if (request.user) {
			response.redirect("/apps")
		} else {
			response.write(`
<form action='/login' method="POST">
	<input type="text" name="username" placeholder="username">
	<input type="password" name="password" placeholder="password">

	<button type="submit">Login</button>
</form>`)
		}
		response.end()
	})
	.post(passport.authenticate("ldapauth"), (_request, response) => {
		response.redirect("/apps")
		response.end()
	})
