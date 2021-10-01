{
	exportedHeaders: {
		"blog.\($domain)": {},
	},
	locationRules: {
		"blog.\($domain)": {
			default: "unprotect"
		}
	},
	vhostOptions: {
		"blog.\($domain)": {
			vhostType: $vhostType
		}
	},
	samlSPMetaDataExportedAttributes: {
		"nextcloud_\($domain)": {
			uid: "0;uid"
		}
	},
	samlSPMetaDataXML: {
		"nextcloud_\($domain)": {
			samlSPMetaDataXML: $samlMetadata
		}
	},
	samlSPMetaDataOptions: {
		samlSPMetaDataOptions: {
			"nextcloud_\($domain)": {
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