import * as express from "express"
import * as bodyParser from "body-parser"

import { apps, domain, users } from "./routes"

const PORT = 8080 // TODO - make port dynamic

express()
	.use(bodyParser.json())
	.use("/apps", apps)
	.use("/domain", domain)
	.use("/users", users)
	.listen(PORT, () => console.log(`Example app listening on port ${PORT}!`))
