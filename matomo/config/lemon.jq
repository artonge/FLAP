{
	exportedHeaders: {
		"analytics.\($domain)": {
			"Remote-User": "$uid"
		},
	},
	locationRules: {
		"analytics.\($domain)": {
			default: "unprotect"
		}
	},
	vhostOptions: {
		"analytics.\($domain)": {
			vhostType: $vhostType
		}
	}
}
