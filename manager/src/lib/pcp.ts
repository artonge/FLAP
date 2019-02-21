import { createSocket } from "dgram"
import { Buffer } from "buffer"
import * as os from "os"
import * as url from "url"
import * as http from "http"

import * as cheerio from "cheerio"

import { logger, sleep, parseResponse } from "../tools"

// A recuring string to put in UPnP requests
const WANIP = "urn:schemas-upnp-org:service:WANIPConnection:1"

export async function pcp() {
	const g = new PCP()
	await g.getExternalIP()
	await g.getPortMappings()
	await g.openPort(8081)
	await g.getPortMappings()
	await g.closePort(8081)
	await g.getPortMappings()
}

// The PCP (Port Control Protocol) class allow to open, close, and list port mappings using the UPnP protocol
export class PCP {
	private hostname = ""
	private port = 0
	private path = ""

	private inited = false

	private _wanIpConnectionPath?: string

	private ip = Object.values(os.networkInterfaces())
		.flat()
		.filter(i => !i.internal && i.family === "IPv4")
		.map(i => i.address)[0]

	/**
	 * Used to lazily get the IGD information
	 * @return a void promise
	 */
	async init() {
		if (this.inited) {
			return
		}

		logger.debug(`Initialiasing PCP object`)

		this.inited = true

		const location = await mSearch()

		if (location.hostname === undefined) {
			throw new Error("hostname not found")
		}

		if (location.port === undefined) {
			throw new Error("port not found")
		}

		if (location.path === undefined) {
			throw new Error("path not found")
		}

		this.hostname = location.hostname
		this.port = Number.parseInt(location.port)
		this.path = location.path

		logger.debug(
			`PCP object initialized with: ${this.hostname}:${this.port}${
				this.path
			}`,
		)
	}

	/**
	 * Get the external IP
	 * @return a promise containing the external IP as a string
	 */
	public async getExternalIP() {
		await this.init()

		logger.info(`Getting external IP`)

		const getExternalIPAddress = upnpQuery(
			`<u:GetExternalIPAddress xmlns:u="${WANIP}"></u:GetExternalIPAddress>`,
		)

		const externalIp = await cheerio
			.load(
				await fetch(
					{
						hostname: this.hostname,
						port: this.port,
						path: await this.getWanIpConnectionPath(),
						method: "POST",
						headers: {
							host: this.hostname,
							SOAPACTION: `"${WANIP}#GetExternalIPAddress"`,
							"content-type": "text/xml",
							"content-length": getExternalIPAddress.length,
						},
					},
					getExternalIPAddress,
				),
			)("NewExternalIPAddress")
			.text()

		logger.debug(`External IP found: ${externalIp}`)

		return externalIp
	}

	/**
	 * Get the first 1000 port mappings
	 * The 1000 limit is arbitrary
	 * @return a promise of an array containing port mappings
	 */
	public async getPortMappings() {
		logger.info(`Listing port mappings`)

		const portMappings: {
			externalPort: string
			internalPort: string
			internalClient: string
		}[] = []

		let i = 0
		try {
			while (i < 1000) {
				portMappings.push(await this._getPortMapping(i++))
			}
		} catch {}

		return portMappings
	}

	// Helper for getPortMapping
	private async _getPortMapping(index: number) {
		await this.init()

		logger.silly(`Querying for port mapping at index: ${index}`)

		const getListOfPortMappings = upnpQuery(`
			<u:GetGenericPortMappingEntry xmlns:u="${WANIP}">
				<NewPortMappingIndex>${index}</NewPortMappingIndex>
			</u:GetGenericPortMappingEntry>`)

		const xml = cheerio.load(
			await fetch(
				{
					hostname: this.hostname,
					port: this.port,
					path: await this.getWanIpConnectionPath(),
					method: "POST",
					headers: {
						host: this.hostname,
						SOAPACTION: `"${WANIP}#GetGenericPortMappingEntry"`,
						"content-type": "text/xml",
						"content-length": getListOfPortMappings.length,
					},
				},
				getListOfPortMappings,
			),
		)

		const portMapping = {
			externalPort: xml("NewExternalPort").text(),
			internalPort: xml("NewInternalPort").text(),
			internalClient: xml("NewInternalClient").text(),
		}

		logger.debug(
			`Found a port mapping: ${portMapping.externalPort} => ${
				portMapping.internalClient
			}:${portMapping.internalPort}`,
		)

		return portMapping
	}

	/**
	 * Delete a port mapping to the current host
	 * @param  port the port to close
	 * @return      a void promise
	 */
	public async closePort(port: number) {
		await this.init()

		logger.info(`Closing port ${port} to ${this.ip}`)

		const deletePortMappingQuery = upnpQuery(`
			<u:DeletePortMapping xmlns:u="${WANIP}">
				<NewRemoteHost></NewRemoteHost>
				<NewExternalPort>${port}</NewExternalPort>
				<NewProtocol>TCP</NewProtocol>
			</u:DeletePortMapping>`)

		return fetch(
			{
				hostname: this.hostname,
				port: this.port,
				path: await this.getWanIpConnectionPath(),
				method: "POST",
				headers: {
					host: this.hostname,
					SOAPACTION: `"${WANIP}#DeletePortMapping"`,
					"content-type": "text/xml",
					"content-length": deletePortMappingQuery.length,
				},
			},
			deletePortMappingQuery,
		)
	}

	/**
	 * Create a port mapping
	 * @param  port the port to open
	 * @return      a void promise
	 */
	public async openPort(port: number) {
		await this.init()

		logger.info(`Openning port ${port} to ${this.ip}`)

		const addPortMappingQuery = upnpQuery(`
			<u:AddPortMapping xmlns:u="${WANIP}">
				<NewRemoteHost></NewRemoteHost>
				<NewExternalPort>${port}</NewExternalPort>
				<NewProtocol>TCP</NewProtocol>
				<NewInternalPort>${port}</NewInternalPort>
				<NewInternalClient>${this.ip}</NewInternalClient>
				<NewEnabled>1</NewEnabled>
				<NewPortMappingDescription>Open port ${port}</NewPortMappingDescription>
				<NewLeaseDuration>0</NewLeaseDuration>
			</u:AddPortMapping>`)

		return fetch(
			{
				hostname: this.hostname,
				port: this.port,
				path: await this.getWanIpConnectionPath(),
				method: "POST",
				headers: {
					host: this.hostname,
					SOAPACTION: `"${WANIP}#AddPortMapping"`,
					"content-type": "text/xml",
					"content-length": addPortMappingQuery.length,
				},
			},
			addPortMappingQuery,
		)
	}

	/**
	 * IGD query are made to a given path.
	 * This function retreive this path.
	 * @return the path to query for IGD queries
	 */
	private async getWanIpConnectionPath() {
		if (this._wanIpConnectionPath) {
			return this._wanIpConnectionPath
		}

		logger.debug(`Getting wanIpConnectionPath`)

		let response = await fetch({
			hostname: this.hostname,
			port: this.port,
			path: this.path,
			method: "GET",
		})

		// Find path to query for the public IP address
		// TODO - This is an naive approche, it might not be the same data structure in all cases.
		// Maybe change the logic be looking up SSPD response's data structure.
		const wanIpConnectionPath = cheerio
			.load(response)(
				"root device deviceList device deviceList device serviceList controlURL",
			)
			.text()

		if (wanIpConnectionPath === "") {
			throw new Error("wanIpConnectionPath not found")
		}

		this._wanIpConnectionPath = wanIpConnectionPath

		logger.debug(`WanIpConnectionPath found ${wanIpConnectionPath}`)

		return wanIpConnectionPath
	}
}

/**
 * Utility to find the IGD
 * Broadcast a M-SEARCH query and return the IGD.
 * The listening will timeout after 3 seconds.
 * @return a promise containing the IGD
 */
export async function mSearch() {
	logger.debug(`Searching for IGD`)

	return new Promise<url.UrlWithStringQuery>(async (resolve, reject) => {
		const socket = createSocket("udp4")

		socket.addListener("message", message => {
			// UPNP is HTTP over UDP, so we need to parse the message as an HTTP response
			let httpResponse
			try {
				httpResponse = parseResponse(message.toString())
			} catch (error) {
				logger.error(error)
				return
			}

			if (
				httpResponse.code === "200" &&
				httpResponse.headers.location !== undefined &&
				httpResponse.headers.usn !== undefined &&
				httpResponse.headers.usn.includes(
					"urn:schemas-upnp-org:device:InternetGatewayDevice:1",
				)
			) {
				socket.close()
			} else {
				return
			}

			// Parse the location
			const parsedLocation = url.parse(httpResponse.headers.location)

			if (!parsedLocation.href) {
				reject(
					new Error(
						`Location's href is undefined: ${parsedLocation}`,
					),
				)
			}

			logger.debug(`IGD found: ${parsedLocation.href}`)

			resolve(parsedLocation)
		})

		socket.addListener("error", error => {
			socket.close()
			reject(error)
		})

		socket.addListener("listening", () => {
			logger.silly(`Broadcasting M-SEARCH query`)

			// WARNING: do not unindent
			// This is an HTTP request and it is white spaces sensitive
			const query = Buffer.from(
				`M-SEARCH * HTTP/1.1
Host:239.255.255.250:1900
ST:urn:schemas-upnp-org:device:InternetGatewayDevice:1
MAN:"ssdp:discover"
MX:1

`,
				"ascii",
			)

			// Broadcast the M-SEARCH query to 239.255.255.250:1900
			socket.send(
				query,
				0,
				query.length,
				1900,
				"239.255.255.250",
				error => {
					if (error) {
						reject(error)
					}
				},
			)
		})

		socket.bind()

		// Wait 3 seconds, then close the socket
		await sleep(3000)
		// Wrapped in a try/catch to avoid exception when the socket is already closed
		try {
			socket.close()
			reject(new Error("M-SEARCH timeout after 3 seconds"))
		} catch {}
	})
}

/**
 * Utility to make a HTTP request
 * @param  options options og the HTTP request
 * @param  body    the body of the request
 * @return         a promise containing the body of the response
 */
async function fetch(options: http.RequestOptions, body?: string) {
	logger.silly(
		`Fetching ${options.method} ${options.hostname}:${options.port || 80}${
			options.path
		}`,
	)

	const request = http.request(options)

	request.end(body)

	return new Promise<string>((resolve, reject) => {
		request.addListener("response", response => {
			if (response.statusCode !== 200) {
				reject(
					new Error(
						`Bad status code: ${response.statusCode} ${
							response.body
						}`,
					),
				)
			}

			let buffer = ""

			response.addListener("data", (chunk: string) => (buffer += chunk))
			response.addListener("end", () => resolve(buffer))
		})
	})
}

/**
 * Utility to create an UPnP query
 * @param  query the query to wrap
 * @return       a UPnP query
 */
function upnpQuery(query: string) {
	return `
		<?xml version="1.0"?>
		<s:Envelope
			xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
			s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
		>
			<s:Body>
				${query}
			</s:Body>
		</s:Envelope>`
}
