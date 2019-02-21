import * as winston from "winston"

const PRODUCTION = process.env.NODE_ENV === "production"
const TEST = process.env.NODE_ENV === "test"
const LOG_LEVEL = process.env.LOG_LEVEL || (PRODUCTION ? "warn" : "debug")

export const logger = winston.createLogger({
	level: LOG_LEVEL,
	transports: [new winston.transports.Console({ silent: TEST })],
	format: winston.format.combine(
		winston.format.timestamp(),
		winston.format.printf(({ level, message, timestamp }) => {
			return `[${timestamp}][${level.toUpperCase().padEnd(7)}] ${message}`
		}),
	),
})
