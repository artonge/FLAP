{
	locationRules: {
		"audio.\($domain)": {
			default: "unprotect"
		}
	},
	vhostOptions: {
		"audio.\($domain)": {
			vhostType: $vhostType
		}
	}
}
