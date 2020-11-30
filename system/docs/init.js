window.$docsify = {
	name: 'FLAP',
	nameLink: "https://docs.flap.cloud",
	logo: "https://www.flap.cloud/logo.png",
	auto2top: true,
	loadSidebar: true,
	subMaxLevel: 3,
	maxLevel: 4,
	formatUpdated: '{MM}/{DD} {HH}:{mm}',
	search: 'auto',
	plugins: [
		EditOnGithubPlugin.create("https://gitlab.com/flap-box/flap/-/edit/master/system/docs/", undefined, "Edit on Gitlab")
	]
}
