import * as ldap from "ldapjs"
import * as argon2 from "argon2"

const BASE = "ou=users,dc=flap,dc=local"

const client = ldap.createClient({
	url: "ldap://localhost",
})

// We need to connect the client to the LDAP server using the admin account
// TODO - Make password dynammicentry.object
client.bind("cn=admin,dc=flap,dc=local", "admin", (error, _response) => {
	if (error) {
		console.error("Error while connecting to the LDAP server:", error)
	}
})

interface IUser {
	fullname: string
	username: string
}

export async function searchUsers(): Promise<IUser[]> {
	return new Promise((resolve, reject) => {
		let users: IUser[] = []

		client.search(BASE, { scope: "sub" }, (error, ldapResponse) => {
			if (error) {
				reject({ code: 500, message: error.message })
			}

			/** From the doc:
			 * > Responses from the search method are an EventEmitter where you will get a notification for each searchEntry that comes back from the server.
			 * > You will additionally be able to listen for a searchReference, error and end event.
			 * > Note that the error event will only be for client/TCP errors, not LDAP error codes like the other APIs.
			 * > You'll want to check the LDAP status code (likely for 0) on the end event to assert success.
			 * > LDAP search results can give you a lot of status codes, such as time or size exceeded, busy, inappropriate matching, etc., which is why this method doesn't try to wrap up the code matching.
			 **/
			ldapResponse.on("searchEntry", entry => {
				// The search return the organizationalUnit object, but we don't need it
				if (entry.object.objectClass === "organizationalUnit") {
					return
				}

				users.push({
					fullname: entry.object.cn,
					username: entry.object.sn,
				})
			})

			ldapResponse.on("error", error => {
				reject({ code: 500, message: error.message })
			})

			ldapResponse.on("end", result => {
				if (result.status !== 0) {
					reject({ code: 500, message: result.errorMessage })
				} else {
					resolve(users)
				}
			})
		})
	})
}

export async function getUser(username: string): Promise<IUser> {
	const users = await searchUsers()
	const user = users.filter(user => user.username === username)[0]

	if (!user) {
		throw { code: 404, message: "Unkown user" }
	}

	return user
}

export async function createUser(params: any): Promise<IUser> {
	// Check that all the needed properties are present
	;["username", "fullname", "password"].forEach(key => {
		if (!Object.keys(params).includes(key)) {
			throw { code: 400, message: `The property '${key}' is missing` }
		}
	})

	const hash = await argon2.hash(params.password, {
		timeCost: 40,
		memoryCost: 2 ** 16,
		parallelism: 4,
		type: argon2.argon2d,
	})

	const entry = {
		cn: params.fullname,
		sn: params.username,
		userPassword: hash,
		mail: `${params.username}@flap.local`,
		objectClass: ["person", "mailAccount"],
	}

	return new Promise((resolve, reject) => {
		client.add(`sn=${params.username},${BASE}`, entry, error => {
			if (error) {
				reject({ code: 500, message: error.message })
			} else {
				resolve({
					fullname: params.fullname,
					username: params.username,
				})
			}
		})
	})
}

// Allow the user to change its fullname and password.
// The username is imutable because it implies changing the username in all services, which can break things.
export async function updateUser(
	username: string,
	params: any,
): Promise<IUser> {
	// Get the user to check if the user exist
	const user = await getUser(username)

	let changes: ldap.Change[] = []

	if (params.password) {
		changes.push(
			new ldap.Change({
				operation: "replace",
				modification: {
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
		changes.push(
			new ldap.Change({
				operation: "replace",
				modification: {
					cn: params.fullname,
				},
			}),
		)
	}

	return new Promise((resolve, reject) => {
		client.modify(`sn=${user.username},${BASE}`, changes, async error => {
			if (error) {
				reject({ code: 500, message: error.message })
			} else {
				resolve(await getUser(user.username))
			}
		})
	})
}

export async function deleteUser(username: string): Promise<void> {
	// Get the user to check if the user exist
	const user = await getUser(username)

	return new Promise((resolve, reject) => {
		client.del(`sn=${user.username},${BASE}`, error => {
			if (error) {
				reject({ code: 500, message: error.message })
			} else {
				resolve()
			}
		})
	})
}
