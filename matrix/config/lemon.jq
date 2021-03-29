{
	exportedHeaders: {
		"matrix.\($domain)": {}
	},
	locationRules: {
		"matrix.\($domain)": {
			default: "unprotect"
		}
	},
	vhostOptions: {
		"matrix.\($domain)": {
			vhostType: $vhostType
		}
	},
	samlSPMetaDataExportedAttributes: {
		"synapse_\($domain)": {
			"uid": "0;urn:mace:dir:attribute-def:uid;;uid",
			"cn": "0;urn:mace:dir:attribute-def:displayName;;displayName",
			"email": "0;urn:mace:dir:attribute-def:email;;email"
		}
	},
	samlSPMetaDataXML: {
		"synapse_\($domain)": {
			samlSPMetaDataXML: $samlMetadata
		}
	},
	samlSPMetaDataOptions: {
		samlSPMetaDataOptions: {
			"synapse_\($domain)": {
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
