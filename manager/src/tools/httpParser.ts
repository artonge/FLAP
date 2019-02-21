import { logger } from "."

export function parseRequest(requestString: string) {
	logger.debug(`Parsing HTTP request`)

	if (requestString.length === 0) {
		throw new Error("Empty HTTP request")
	}

	const lines = requestString.split(/\r?\n/)

	let index = lines.findIndex(line => line === "")

	if (index === -1) {
		index = lines.length
	}

	return {
		...parseRequestLine(lines[0]),
		headers: parseHeaders(lines.slice(1, index)),
		body: lines.slice(index + 1).join("\n"),
	}
}

export function parseResponse(responseString: string) {
	logger.debug(`Parsing HTTP response`)

	if (responseString.length === 0) {
		throw new Error("Empty HTTP response")
	}

	const lines = responseString.split(/\r?\n/)

	const index = lines.findIndex(line => line === "")

	return {
		...parseStatusLine(lines[0]),
		headers: parseHeaders(lines.slice(1, index)),
		body: lines.slice(index).join("\n"),
	}
}

function parseHeaders(headerLines: string[]) {
	logger.silly(`Parsing HTTP headers: ${headerLines.join(", ")}`)

	return headerLines
		.map(line => line.split(":"))
		.reduce(
			(headers, [key, ...values]) => {
				return {
					...headers,
					[key.toLowerCase()]: values.join(":").trim(),
				}
			},
			{} as { [headerName: string]: string },
		)
}

function parseStatusLine(statusLine: string) {
	logger.silly(`Parsing HTTP status line: ${statusLine}`)

	const parts = statusLine.match(/^(.+) ([0-9]{3}) (.*)$/)

	if (!parts) {
		throw new Error(`Error parsing status line: ${statusLine}`)
	}

	return {
		protocol: parts[1].toUpperCase(),
		code: parts[2],
		message: parts[3],
	}
}

function parseRequestLine(requestLine: string) {
	logger.silly(`Parsing HTTP request line: ${requestLine}`)

	const parts = requestLine.split(" ")

	return {
		method: parts[0].toUpperCase(),
		uri: parts[1],
		protocol: parts[2].toUpperCase(),
	}
}
