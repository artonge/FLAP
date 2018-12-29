import * as express from "express"

import {
	searchUsers,
	createUser,
	deleteUser,
	getUser,
	updateUser,
} from "../lib"

function handleError(
	response: express.Response,
	context: string,
	error: { code: number; message: string } | any,
) {
	if (error.code && error.message) {
		console.error(`Error while ${context}:`, error.message)
		response.status(error.code).send(error.message)
	} else {
		console.error(`Error while ${context}:`, error)
		response.status(500).send(error)
	}
}

export const users = express
	.Router()

	.get("/", async (_request, response) => {
		try {
			response.json(await searchUsers())
		} catch (error) {
			handleError(response, "searching for users", error)
		} finally {
			response.end()
		}
	})

	.post("/", async (request, response) => {
		try {
			await createUser(request.body)
			response.status(201)
		} catch (error) {
			handleError(response, "creating a user", error)
		} finally {
			response.end()
		}
	})

	.get("/:userId", async (request, response) => {
		try {
			response.json(await getUser(request.params.userId))
		} catch (error) {
			handleError(response, "getting a user", error)
		} finally {
			response.end()
		}
	})

	.delete("/:userId", async (request, response) => {
		try {
			await deleteUser(request.params.userId)
		} catch (error) {
			handleError(response, "deleting a user", error)
		} finally {
			response.end()
		}
	})

	.patch("/:userId", async (request, response) => {
		try {
			response.json(await updateUser(request.params.userId, request.body))
		} catch (error) {
			handleError(response, "updating a user", error)
		} finally {
			response.end()
		}
	})
