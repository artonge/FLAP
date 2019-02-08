// Here we are proxying the ldapjs lib so we can use it with promises
import * as ldap from "ldapjs"

export function bind(
	url: string,
	dn: string,
	pwd: string,
): Promise<ldap.Client> {
	return new Promise((resolve, reject) => {
		const client = ldap.createClient({ url })

		client.bind(dn, pwd, (error, _response) => {
			if (error) {
				reject(error)
			} else {
				resolve(client)
			}
		})
	})
}

export function unbind(client: ldap.Client) {
	// Unbind does not have response and does not call the callback on success
	// So we can only log the error if their is one
	client.unbind(error => {
		if (error) {
			console.log("Error while unbinding:", error)
		}
	})
}

export function search(
	client: ldap.Client,
	base: string,
	filter?: string | ldap.Filter,
): Promise<any[]> {
	return new Promise((resolve, reject) => {
		let entries: any[] = []

		client.search(base, { scope: "sub", filter }, (error, ldapResponse) => {
			if (error) {
				return reject(error)
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

				entries.push(entry)
			})

			ldapResponse.on("error", error => {
				reject(error.message)
			})

			ldapResponse.on("end", result => {
				if (result.status !== 0) {
					reject(result.errorMessage)
				} else {
					resolve(entries)
				}
			})
		})
	})
}

export function add(
	client: ldap.Client,
	dn: string,
	entry: any,
): Promise<void> {
	return new Promise((resolve, reject) => {
		client.add(dn, entry, error => {
			if (error) {
				reject(error)
			} else {
				resolve()
			}
		})
	})
}

export function modify(
	client: ldap.Client,
	dn: string,
	changes: ldap.Change[],
): Promise<any> {
	return new Promise((resolve, reject) => {
		client.modify(dn, changes, error => {
			if (error) {
				reject(error)
			} else {
				resolve()
			}
		})
	})
}

export function del(client: ldap.Client, dn: string): Promise<void> {
	return new Promise((resolve, reject) => {
		client.del(dn, error => {
			if (error) {
				reject(error)
			} else {
				resolve()
			}
		})
	})
}
