{
	locationRules: {
		"music.\($domain)": {
			default: "unprotect"
		}
	},
	vhostOptions: {
		"music.\($domain)": {
			vhostType: $vhostType
		}
	}
}
