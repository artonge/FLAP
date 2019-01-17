import * as express from "express"

import {
	searchUsers,
	createUser,
	deleteUser,
	getUser,
	updateUser,
} from "../lib"

import {
	handleError,
	validate,
	minLengthValidator,
	maxLengthValidator,
	requiredValidator,
} from "../tools"

export const usersRouter = express.Router()

// Middlewares
usersRouter
	// Add the user object to the request
	.param("userId", async (request, response, next) => {
		try {
			try {
				validate(request.params.userId, "userId", [
					requiredValidator,
					minLengthValidator(1),
					maxLengthValidator(32),
				])
			} catch (error) {
				throw {
					code: 400,
					message: error,
				}
			}

			const user = await getUser(request.params.userId)
			;(request as any).user = user
			next()
		} catch (error) {
			handleError(request, response, error)
			response.end()
		}
	})

// /
usersRouter
	.route("/")
	.get(async (request, response) => {
		try {
			response.json(await searchUsers())
		} catch (error) {
			handleError(request, response, error)
		} finally {
			response.end()
		}
	})
	.post(async (request, response) => {
		try {
			// Check that undefinedall the needed properties are valid
			validateBody(request.body)
			await createUser(request.body)
			response.status(201)
		} catch (error) {
			handleError(request, response, error)
		} finally {
			response.end()
		}
	})

// /:userId
usersRouter
	.route("/:userId")
	.get(async (request, response) => {
		console.log()
		try {
			response.json((request as any).user)
		} catch (error) {
			handleError(request, response, error)
		} finally {
			response.end()
		}
	})
	.delete(async (request, response) => {
		try {
			await deleteUser(request.params.userId)
		} catch (error) {
			handleError(request, response, error)
		} finally {
			response.end()
		}
	})
	.patch(async (request, response) => {
		try {
			// Check that all the needed properties are valid
			validateBody(request.body)
			response.json(await updateUser(request.params.userId, request.body))
		} catch (error) {
			handleError(request, response, error)
		} finally {
			response.end()
		}
	})

// Helpers
function validateBody(body: any) {
	// Check that all the needed properties are there and valid
	try {
		validate(body.username, "username", [
			requiredValidator,
			minLengthValidator(1),
			maxLengthValidator(32),
		])
		validate(body.fullname, "fullname", [
			requiredValidator,
			minLengthValidator(3),
			maxLengthValidator(64),
		])
		validate(body.password, "password", [
			requiredValidator,
			minLengthValidator(8),
			maxLengthValidator(256),
		])
	} catch (error) {
		throw {
			code: 400,
			message: error,
		}
	}
}
