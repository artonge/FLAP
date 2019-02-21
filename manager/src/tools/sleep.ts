// Quick function to "sleep" a given time using async/await
// It's just a setTimeout call wrapped in a Promise
export async function sleep(duration: number) {
	return new Promise(resolve => setTimeout(() => resolve(), duration))
}
