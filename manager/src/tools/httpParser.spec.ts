import { parseRequest, parseResponse } from "./httpParser"

const httpRequest = `GET /ip HTTP/1.1
User-Agent: curl/7.24.0 (x86_64-apple-darwin12.0) libcurl/7.24.0 OpenSSL/0.9.8x zlib/1.2.5
Host: httpbin.org
Accept: */*`

const httpResponse = `HTTP/1.1 200 OK
Content-Type: application/json
Date: Wed, 03 Jul 2013 13:30:53 GMT
Server: gunicorn/0.17.4
Content-Length: 30
Connection: keep-alive

{
	"origin": "94.113.241.2"
}`

const malformedHttpResponse = `HTTP/1.1 OK
Content-Type: application/json
Date: Wed, 03 Jul 2013 13:30:53 GMT
Server: gunicorn/0.17.4
Content-Length: 30
Connection: keep-alive

{
	"origin": "94.113.241.2"
}`

describe("httpParser", () => {
	describe("parseRequest", () => {
		it("should parse the request correctly", () => {
			expect(parseRequest(httpRequest)).toEqual({
				method: "GET",
				protocol: "HTTP/1.1",
				uri: "/ip",
				headers: {
					"user-agent":
						"curl/7.24.0 (x86_64-apple-darwin12.0) libcurl/7.24.0 OpenSSL/0.9.8x zlib/1.2.5",
					host: "httpbin.org",
					accept: "*/*",
				},
				body: "",
			})
		})

		it("should error on empty string", () => {
			expect.assertions(1)

			try {
				parseRequest("")
			} catch (error) {
				expect(error.message).toBe("Empty HTTP request")
			}
		})
	})

	describe("parseResponse", () => {
		it("should parse the request correctly", () => {
			expect(parseResponse(httpResponse)).toEqual({
				code: "200",
				message: "OK",
				protocol: "HTTP/1.1",
				headers: {
					"content-type": "application/json",
					date: "Wed, 03 Jul 2013 13:30:53 GMT",
					server: "gunicorn/0.17.4",
					"content-length": "30",
					connection: "keep-alive",
				},
				body: '\n{\n	"origin": "94.113.241.2"\n}',
			})
		})

		it("should error on empty string", () => {
			expect.assertions(1)

			try {
				parseResponse("")
			} catch (error) {
				expect(error.message).toBe("Empty HTTP response")
			}
		})

		it("should error on malformed response", () => {
			expect.assertions(1)

			try {
				parseResponse(malformedHttpResponse)
			} catch (error) {
				expect(error.message).toBe(
					"Error parsing status line: HTTP/1.1 OK",
				)
			}
		})
	})
})
