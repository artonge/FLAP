import * as express from "express"

export const domain = express
	.Router()

	.get("/", (_req, res) => {
		res.json({
			domain: "flap.localhost",
		})
	})
// TODO - .put("/", (req, res) => {})
