import { Request, Response } from "express"

const PRODUCTION = false

export function handleError(
	request: Request,
	response: Response,
	error: { code: number; message: string } | any,
) {
	if (!error.code || !error.message) {
		error = { code: 500, message: error }
	}

	console.error(`Error in '${request.route}':`, error.message)

	if (PRODUCTION) {
		response.status(error.code)
	} else {
		response.status(error.code).send(error.message)
	}
}
