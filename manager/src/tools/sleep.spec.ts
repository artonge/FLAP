import { sleep } from "."

describe("sleep", () => {
	jest.useFakeTimers()

	it("sleep should resolve after the setted duration", async () => {
		expect.assertions(6)
		const spy = jest.fn()

		// Used to make sure expectations are called in the correct order
		let order = 0

		await new Promise(resolve => {
			sleep(1000).then(() => {
				spy()
				expect(spy).toHaveBeenCalled()
				expect(order++).toBe(2)
				resolve()
			})

			expect(spy).not.toHaveBeenCalled()
			expect(order++).toBe(0)

			jest.advanceTimersByTime(999)

			expect(spy).not.toHaveBeenCalled()
			expect(order++).toBe(1)

			jest.advanceTimersByTime(1000)
		})
	})
})
