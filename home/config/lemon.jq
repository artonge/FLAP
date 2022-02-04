{
	exportedHeaders: {
		"home.\($domain)": {
			"Remote-User": "$uid"
		}
	},
	locationRules: {
		"home.\($domain)": {
			default: "accept"
		}
	},
	vhostOptions: {
		"home.\($domain)": {
			vhostType: $vhostType
		}
	}
}
