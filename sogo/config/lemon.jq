{
	exportedHeaders: {
		"mail.\($domain)": {
			"Remote-User": "$uid",
			"Authorization": "\"Basic \".encode_base64(\"$uid:$_password\", '')"
		}
	},
	locationRules: {
		"mail.\($domain)": {
			default: "accept"
		}
	},
	vhostOptions: {
		"mail.\($domain)": {
			vhostType: $vhostType
		}
	}
}

# {
# 	exportedHeaders: {
# 		"mail.\($domain)": {}
# 	},
# 	locationRules: {
# 		"mail.\($domain)": {
# 			default: "unprotect"
# 		}
# 	},
# 	vhostOptions: {
# 		"mail.\($domain)": {
# 			vhostType: $vhostType
# 		}
# 	},
# 	samlSPMetaDataExportedAttributes: {
# 		"sogo_\($domain)": {
# 			# "uid": "0;urn:mace:dir:attribute-def:uid;;uid",
# 			# "cn": "0;urn:mace:dir:attribute-def:displayName;;displayName",
# 			# "email": "0;urn:mace:dir:attribute-def:email;;email"
# 		}
# 	},
# 	samlSPMetaDataXML: {
# 		"sogo_\($domain)": {
# 			samlSPMetaDataXML: $samlMetadata
# 		}
# 	},
# 	samlSPMetaDataOptions: {
# 		samlSPMetaDataOptions: {
# 			"sogo_\($domain)": {
# 				samlSPMetaDataOptionsCheckSLOMessageSignature: 1,
# 				samlSPMetaDataOptionsCheckSSOMessageSignature: 1,
# 				samlSPMetaDataOptionsEnableIDPInitiatedURL: 0,
# 				samlSPMetaDataOptionsEncryptionMode: "none",
# 				samlSPMetaDataOptionsForceUTF8: 1,
# 				samlSPMetaDataOptionsNameIDFormat: "",
# 				samlSPMetaDataOptionsNotOnOrAfterTimeout: 72000,
# 				samlSPMetaDataOptionsOneTimeUse: 0,
# 				samlSPMetaDataOptionsSessionNotOnOrAfterTimeout: 72000,
# 				samlSPMetaDataOptionsSignSLOMessage: -1,
# 				samlSPMetaDataOptionsSignSSOMessage: -1
# 			}
# 		}
# 	}
# }
