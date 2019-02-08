import * as express from "express"

import {
	searchUsers,
	createUser,
	deleteUser,
	getUser,
	updateUser,
} from "../lib"

import {
	validate,
	minLengthValidator,
	maxLengthValidator,
	requiredValidator,
} from "../tools"

export const usersRouter = express.Router()

// Middlewares
usersRouter
	// Add the user object to the request
	.param("userId", async (request, _response, next) => {
		validate(request.params.userId, "userId", [
			requiredValidator,
			minLengthValidator(1),
			maxLengthValidator(32),
		])
		try {
			const user = await getUser(request.params.userId)
			;(request as any).targetedUser = user
			next()
		} catch (error) {
			throw { code: 404, message: error }
		}
	})

// /users
usersRouter
	.route("/")
	.get(async (_request, response) => {
		response.json(await searchUsers())
		response.end()
	})
	.post(async (request, response) => {
		// Check that all the needed properties are there and valid
		validate(request.body.username, "username", [
			requiredValidator,
			minLengthValidator(1),
			maxLengthValidator(32),
		])
		validate(request.body.fullname, "fullname", [
			requiredValidator,
			minLengthValidator(3),
			maxLengthValidator(64),
		])
		validate(request.body.password, "password", [
			requiredValidator,
			minLengthValidator(8),
			maxLengthValidator(256),
		])

		await createUser(request.body)
		response.status(201)
		response.end()
	})

// /users/:userId
usersRouter
	.route("/:userId")
	.get(async (request, response) => {
		response.json((request as any).targetedUser)
		response.end()
	})
	.delete(async (request, response) => {
		await deleteUser(request.params.userId)
		response.end()
	})
	.patch(async (request, response) => {
		// Check that submited properties are valid
		if (request.body.fullname) {
			validate(request.body.fullname, "fullname", [
				requiredValidator,
				minLengthValidator(3),
				maxLengthValidator(64),
			])
		}
		if (request.body.password) {
			validate(request.body.password, "password", [
				requiredValidator,
				minLengthValidator(8),
				maxLengthValidator(256),
			])
		}
		response.json(await updateUser(request.params.userId, request.body))
		response.end()
	})
