import * as express from "express"

const DOMAIN_NAME = process.env.DOMAIN_NAME || "flap.localhost"

export const apps = express
	.Router()

	.get("/", (_req, res) => {
		res.json([
			{
				name: "Administration",
				description: "Manage your FLAP box", // TODO - translate
				enabled: true,
				url: `https://${DOMAIN_NAME}/admin`,
				icon: "FlapIcon", // TODO - use a real icon
			},
			{
				name: "Seafile",
				description: "Sync all your files accross you all devices", // TODO - translate
				enabled: true,
				url: `https://files.${DOMAIN_NAME}`,
				icon: "seafileIcon", // TODO - use a real icon
			},
		]).end()
	})
