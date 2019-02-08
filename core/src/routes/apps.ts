import * as express from "express"

const DOMAIN_NAME = process.env.DOMAIN_NAME || "localhost"

export const apps = express
	.Router()

	.get("/", (_request, response) => {
		response
			.json([
				{
					name: "Administration",
					description: "Manage your FLAP box", // TODO - translate
					enabled: true,
					url: `https://${DOMAIN_NAME}/admin`,
					icon: "FlapIcon", // TODO - use a real icon
				},
				{
					name: "Seafile",
					description: "Sync your files accross all your devices", // TODO - translate
					enabled: true,
					url: `https://files.${DOMAIN_NAME}`,
					icon: "seafileIcon", // TODO - use a real icon
				},
				{
					name: "Sogo",
					description:
						"Manage and sync your contacts and calendars accross all your devices", // TODO - translate
					enabled: true,
					url: `https://sogo.${DOMAIN_NAME}`,
					icon: "sogoIcon", // TODO - use a real icon
				},
			])
			.end()
	})
