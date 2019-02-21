import { promisify } from "util"
import { promises as fs } from "fs"
import * as path from "path"
import * as os from "os"

import { Change } from "ldapjs"

import { logger } from "../tools"
import * as ldap from "./ldap"

const LDAP_HOST = process.env.LDAP_HOST || "ldap://localhost"
const LDAP_BASE = process.env.LDAP_BASE || "ou=users,dc=flap,dc=local"
const LDAP_ADMIN_DN = process.env.LDAP_ADMIN_DN || "cn=admin,dc=flap,dc=local"
const LDAP_ADMIN_PWD = process.env.LDAP_ADMIN_PWD || "admin"

export interface IUser {
	fullname: string
	username: string
	email: string
}

export async function searchUsers(): Promise<IUser[]> {
	logger.debug(`Searching users in LDAP server`)
	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)
	// Query the server
	const entries = await ldap.search(client, LDAP_BASE)
	// Unbind from the LDAP server
	await ldap.unbind(client)

	// Map users to our IUser interface
	const users = entries.map((entry: any) => ({
		fullname: entry.object.cn,
		username: entry.object.sn,
		email: entry.object.mail,
	}))

	logger.debug(`Searching users in LDAP server`)
	logger.debug(`Found ${users.length} users: ${JSON.stringify(users)}`)

	return users
}

// TODO - this should be improved so we don't have to loop through all the users
export async function getUser(username: string): Promise<IUser> {
	logger.debug(`Getting user ${username}`)
	// Get all users
	const users = await searchUsers()
	// Search for the user with the passed username
	const user = users.find(user => user.username === username)

	if (user === undefined) {
		throw new Error(`The user '${username}' does not exists`)
	}

	logger.debug(`User found ${JSON.stringify(user)}`)

	return user
}

export async function createUser(params: {
	username: string
	fullname: string
	password: string
}): Promise<IUser> {
	logger.debug(
		`Creating a new user ${params.username} with fullname: ${
			params.fullname
		} `,
	)

	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)

	// Send the new entry to the LDAP server
	await ldap.add(client, `sn=${params.username},${LDAP_BASE}`, {
		// objectClass: ["person", "mailAccount"],
		objectClass: ["person", "inetOrgPerson"],
		cn: params.fullname,
		sn: params.username,
		mail: `${params.username}@flap.local`,
		userPassword: await hashPwd(params.password),
	})

	// Unbind from the LDAP server
	await ldap.unbind(client)

	// Return the created user by searching it with its username
	return await getUser(params.username)
}

// Allow the user to change its fullname and password.
// The username is imutable because it implies changing the username in all services, which can break things.
export async function updateUser(
	username: string,
	params: { password?: string; fullname?: string },
): Promise<IUser> {
	logger.debug(`Updating user ${username} with`)
	let changes: Change[] = []

	if (params.password) {
		// Build Change object for the password
		changes.push(
			new Change({
				operation: "replace",
				modification: {
					userPassword: await hashPwd(params.password),
				},
			}),
		)
	}

	if (params.fullname) {
		// Build Change object for the fullname
		changes.push(
			new Change({
				operation: "replace",
				modification: {
					cn: params.fullname,
				},
			}),
		)
	}

	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)
	// Send the changes to the LDAP server
	await ldap.modify(client, `sn=${username},${LDAP_BASE}`, changes)
	// Unbind from the LDAP server
	await ldap.unbind(client)

	return await getUser(username)
}

export async function deleteUser(username: string): Promise<void> {
	logger.debug(`Deleting user ${username}`)
	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)
	// Send the deletion order the LDAP server
	await ldap.del(client, `sn=${username},${LDAP_BASE}`)
	// Unbind from the LDAP server
	await ldap.unbind(client)
}

export async function getUserWithCredentials(
	username: string,
	password: string,
): Promise<IUser | undefined> {
	logger.debug(`Getting the user ${username} with its credentials`)
	// Bind to the LDAP server
	const client = await ldap.bind(
		LDAP_HOST,
		`sn=${username},${LDAP_BASE}`,
		password,
	)
	// Query the server
	const entries = await ldap.search(client, LDAP_BASE)
	// Unbind from the LDAP server
	await ldap.unbind(client)

	// Map users to our IUser interface
	const user = entries.map((entry: any) => ({
		fullname: entry.object.cn,
		username: entry.object.sn,
		email: entry.object.mail,
	}))[0]

	logger.debug(`User found: ${JSON.stringify(user)}`)

	return user
}

// Return a password hash compatible with crypt(3) format
// The password is salted with a random hash
// This uses the mkpasswd command from the whois package
// To prevent passing user input directly to the exec call we store the password in a tmp file that will be passed via stdin
export async function hashPwd(password: string) {
	logger.silly(`Hashing password`)
	// Create a tmp dir
	const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "flap-"))

	let hash: string | undefined

	// Wrapped in try/catch so we can delete the tmp dir even if there is an error
	try {
		// Write clear the text password in a password.txt file inside the tmp dir
		await fs.writeFile(`${tmpDir}/password.txt`, password, "utf8")
		// Exec the shell command
		const exec = promisify(require("child_process").exec)

		const { stdout, stderr } = await exec(
			`mkpasswd --method=sha-512 --rounds 999999 --stdin < ${tmpDir}/password.txt`,
		)

		if (stderr) {
			throw new Error(stderr)
		}

		// Stdout have a \n at its end, trimEnd will remove it
		// {CRYPT} is here to tell ldap it should use crypt(3) to check the password
		hash = `{CRYPT}${stdout.trimEnd()}`
	} finally {
		await fs.unlink(`${tmpDir}/password.txt`)
		await fs.rmdir(tmpDir)
	}

	return hash
}
