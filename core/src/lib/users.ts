import { Change } from "ldapjs"
import * as ldap from "./ldap"
import * as argon2 from "argon2"

const LDAP_HOST = process.env.LDAP_HOST || "ldap://localhost"
const LDAP_BASE = process.env.LDAP_BASE || "ou=users,dc=flap,dc=local"
const LDAP_ADMIN_DN = process.env.LDAP_ADMIN_DN || "cn=admin,dc=flap,dc=local"
const LDAP_ADMIN_PWD = process.env.LDAP_ADMIN_PWD || "admin"

interface IUser {
	fullname: string
	username: string
	email: string
}

export async function searchUsers(): Promise<IUser[]> {
	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)
	// Query the server
	const entries = await ldap.search(client, LDAP_BASE)
	// Unbind from the LDAP server
	await ldap.unbind(client)

	// Map users to our IUser interface
	return entries.map((entry: any) => ({
		fullname: entry.object.cn,
		username: entry.object.sn,
		email: entry.object.mail,
	}))
}

// TODO - this should be improved so we don't have to loop through all the users
export async function getUser(username: string): Promise<IUser> {
	// Get all users
	const users = await searchUsers()
	// Search for the user with the passed username
	const user = users.find(user => user.username === username)

	if (user === undefined) {
		throw new Error(`The user '${username}' does not exists`)
	}

	return user
}

export async function createUser(params: {
	username: string
	fullname: string
	password: string
}): Promise<IUser> {
	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)

	// Send the new entry to the LDAP server
	await ldap.add(client, `sn=${params.username},${LDAP_BASE}`, {
		objectClass: ["person", "mailAccount"],
		cn: params.fullname,
		sn: params.username,
		mail: `${params.username}@flap.local`,
		// Hash the user's password
		userPassword: await argon2.hash(params.password, {
			timeCost: 40,
			memoryCost: 2 ** 16,
			parallelism: 4,
			type: argon2.argon2d,
		}),
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
	let changes: Change[] = []

	if (params.password) {
		// Build Change object for the password
		changes.push(
			new Change({
				operation: "replace",
				modification: {
					// Hash the user's password
					userPassword: await argon2.hash(params.password, {
						timeCost: 40,
						memoryCost: 2 ** 16,
						parallelism: 4,
						type: argon2.argon2d,
					}),
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
	// Bind to the LDAP server
	const client = await ldap.bind(LDAP_HOST, LDAP_ADMIN_DN, LDAP_ADMIN_PWD)
	// Send the deletion order the LDAP server
	await ldap.del(client, `sn=${username},${LDAP_BASE}`)
	// Unbind from the LDAP server
	await ldap.unbind(client)
}
