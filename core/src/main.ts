import "core-js"

import * as express from "express"
import * as bodyParser from "body-parser"
import * as session from "express-session"
import * as passport from "passport"

import LdapStrategy = require("passport-ldapauth")
const RedisStore = require("connect-redis")(session)

import {
	apps,
	domain,
	usersRouter,
	authRouter,
	loginRouter,
	logoutRouter,
} from "./routes"
import { getUser, IUser } from "./lib"
import { logger } from "./tools"

const PRODUCTION = process.env.NODE_ENV === "production"
const PORT = process.env.PORT || 80
const DOMAIN_NAME = process.env.DOMAIN_NAME || "localhost"

const LDAP_HOST = process.env.LDAP_HOST || "ldap://localhost"
const LDAP_BASE = process.env.LDAP_BASE || "ou=users,dc=flap,dc=local"

const REDIS_HOST = process.env.REDIS_HOST || "localhost"

// Use the ldap strategy to authenticate users
// It will try to bind to the ldap server using the username and password provided
// When the binding succeed, we map our user to our IUser interface so we now what we are dealing with
// http://www.passportjs.org/packages/passport-ldapauth/
passport.use(
	new LdapStrategy(
		{
			server: {
				url: LDAP_HOST,
				searchBase: LDAP_BASE,
				searchFilter: "sn={{username}}",
			},
		},
		async (user: any, done: any) => {
			try {
				done(null, await getUser(user.sn))
			} catch (error) {
				done(error)
			}
		},
	),
)

// Tell passport how to serialize and deserialize the user informations
// The user is a plain object so we don't need to serialize it
// It will be stored in redis by express-session
// The allow fast retrival of the user for each authenticated requests
// The user object will never be sent to the brower
passport.serializeUser((user: IUser, done) => done(null, user))
passport.deserializeUser(async (user: IUser, done) => done(null, user))

express()
	// Add some security HTTP headers
	// https://github.com/helmetjs/helmet
	.use(require("helmet")())

	// Parse JSON bodies and put the in request.body
	// https://github.com/expressjs/body-parser
	.use(bodyParser.json())
	// Same but for URL encoded body
	// TODO - remove when the login page send credentials in JSON
	.use(bodyParser.urlencoded({ extended: true }))

	// Trust first proxy, this is necessary to set a secure cookie behind a proxy
	.set("trust proxy", 1)
	// Configure how the sessions informations will be stored and what kind of cookie will be used
	// Here we chose the use redis as a store
	// And set some parameters to secure the cookie
	.use(
		// https://github.com/expressjs/session
		session({
			// https://github.com/tj/connect-redis
			store: new RedisStore({ host: REDIS_HOST, logErrors: true }),
			secret: "flap sso", // Secret to sign the cookie
			name: "flap-sso", // Name of the cookie
			resave: false,
			saveUninitialized: false,
			cookie: {
				domain: DOMAIN_NAME, // Available for the domain and subdomains
				sameSite: "strict",
				secure: DOMAIN_NAME !== "localhost", // HTTPS only if we are not on localhost
			},
		}),
	)

	// Initialize passport
	// http://www.passportjs.org/docs/
	.use(passport.initialize())
	.use(passport.session())

	// This is our routes
	.use("/apps", apps)
	.use("/domain", domain)
	.use("/users", usersRouter)
	.use("/auth", authRouter)
	.use("/login", loginRouter)
	.use("/logout", logoutRouter)

	// Custom error handler
	.use(
		(
			error: { code: number; message: string | Error } | string | Error,
			request: express.Request,
			response: express.Response,
			_next: any,
		) => {
			// Default HTTP code to 500
			if (typeof error === "string" || error instanceof Error) {
				error = { code: 500, message: error }
			}

			// Wrap the message into an Error object
			if (!(error.message instanceof Error)) {
				error.message = new Error(error.message)
			}

			// Log for debugging
			logger.error(
				`Error (${error.code}) in '${request.route.path}':`,
				error.message,
			)

			if (PRODUCTION) {
				response.status(error.code)
			} else {
				response.status(error.code).send(error.message.message)
			}

			response.end()
		},
	)

	// Start listening
	.listen(PORT, () => logger.info(`Listening on port ${PORT}`))
