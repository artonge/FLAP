const { setHeadlessWhen } = require("@codeceptjs/configure")

require('ts-node/register')

// turn on headless mode when running with HEADLESS=true environment variable
// HEADLESS=true npx codecept run
setHeadlessWhen(process.env.HEADLESS)

exports.config = {
	tests: "./system/e2e/tests/**/*.ts",
	output: "./system/e2e/output",
	helpers: {
		Puppeteer: {
			url: `https://home.${process.env.PRIMARY_DOMAIN_NAME}`,
			show: !process.env.CI,
			getPageTimeout: 80000,
			waitForTimeout: 80000,
			waitForNavigation: "networkidle0",
			windowSize: "1920x1080",
			chrome: {
				ignoreHTTPSErrors: true,
				args: ["--no-sandbox", "--disable-dev-shm-usage"],
				...(process.profile === "chrome-ci"
					? {
						executablePath: "/usr/bin/chromium-browser",
					}
					: {}),
			},
		},
	},
	include: {
		I: "./system/e2e/steps_file.js",
		homePage: "./system/e2e/pages/home.ts",
		settingsPage: "./system/e2e/pages/settings.ts",
		createUserStep: "./system/e2e/steps/createUser.js",
	},
	bootstrap: null,
	mocha: {
		reporterOptions: {
			mochaFile: "./system/e2e/output/result.xml",
		},
	},
	name: "home",
	plugins: {
		autoDelay: {
			enabled: true
		},
		retryFailedStep: {
			enabled: true,
		},
		screenshotOnFail: {
			enabled: true,
		},
		pauseOnFail: {
			enabled: process.profile !== "chrome-ci",
		},
		stepByStepReport: {
			enabled: true
		}
	},
}
