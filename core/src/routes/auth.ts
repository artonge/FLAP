import * as express from "express"

export const ssoAuthRouter = express
	.Router()
	.get("/ssoauth", (request, response) => {
		console.log(
			request.headers,
			request.params,
			request.body,
			request.cookies,
		)

		response.status(200)
		response.end()
	})
