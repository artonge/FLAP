// Redirect to the login page when the loading of all ressources is done.
const interval = setInterval(() => {
	if (document.readyState === "complete") {
		window.location = `${location.origin}/?cancel=1`
		clearInterval(interval)
	}
}, 10)
