{
	exportedHeaders: {
		"audio.\($domain)": {
			"Remote-User": "$uid"
		},
	},
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
