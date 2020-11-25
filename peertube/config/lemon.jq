{
	exportedHeaders: {
		"video.\($domain)": {}
	},
	locationRules: {
		"video.\($domain)": {
			default: "unprotect"
		}
	},
	vhostOptions: {
		"video.\($domain)": {
			vhostType: $vhostType
		}
	},
	samlSPMetaDataMacros: {
		"peertube_\($domain)": {
			"peertube_role": "$isAdmin ? 0 : 2"
		}
	},
	samlSPMetaDataExportedAttributes: {
		"peertube_\($domain)": {
			uid: "0;uid",
			mail: "0;mail",
			cn: "0;cn",
			peertube_role: "0;peertube_role"
		}
	},
	samlSPMetaDataXML: {
		"peertube_\($domain)": {
			samlSPMetaDataXML: $samlMetadata
		}
	},
	samlSPMetaDataOptions: {
		samlSPMetaDataOptions: {
			"peertube_\($domain)": {
				samlSPMetaDataOptionsCheckSLOMessageSignature: 1,
				samlSPMetaDataOptionsCheckSSOMessageSignature: 1,
				samlSPMetaDataOptionsEnableIDPInitiatedURL: 0,
				samlSPMetaDataOptionsEncryptionMode: "none",
				samlSPMetaDataOptionsForceUTF8: 1,
				samlSPMetaDataOptionsNameIDFormat: "",
				samlSPMetaDataOptionsNotOnOrAfterTimeout: 72000,
				samlSPMetaDataOptionsOneTimeUse: 0,
				samlSPMetaDataOptionsSessionNotOnOrAfterTimeout: 72000,
				samlSPMetaDataOptionsSignSLOMessage: -1,
				samlSPMetaDataOptionsSignSSOMessage: -1
			}
		}
	}
}
