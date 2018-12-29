import * as express from "express"

export const apps = express
	.Router()

	.get("/", (_req, res) => {
		res.json([
			{
				name: "Administration",
				description: "Manage your FLAP box", // TODO - translate
				enabled: true,
				url: "https://flap.localhost/admin", // TODO - make the URL dynamic
				icon: "FlapIcon", // TODO - use a real icon
			},
			{
				name: "Seafile",
				description: "Sync all your files accross you all devices", // TODO - translate
				enabled: true,
				url: "https://files.flap.localhost", // TODO - make the URL dynamic
				icon: "seafileIcon", // TODO - use a real icon
			},
		]).end()
	})
