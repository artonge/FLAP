import * as express from "express"
import * as bodyParser from "body-parser"

import { apps, domain, usersRouter } from "./routes"

const PORT = process.env.PORT || 80

express()
	.use(bodyParser.json())
	.use("/apps", apps)
	.use("/domain", domain)
	.use("/users", usersRouter)
	.listen(PORT, () => console.log(`Example app listening on port ${PORT}!`))
