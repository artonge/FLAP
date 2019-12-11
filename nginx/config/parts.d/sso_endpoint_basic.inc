location = /lmauth_basic {
	internal;
	include fastcgi_params;
	fastcgi_pass lemon:9000;

	# Drop post datas
	fastcgi_pass_request_body off;
	fastcgi_param CONTENT_LENGTH "";

	# Keep original hostname
	fastcgi_param HOST $http_host;

	# Keep original request (LLNG server will receive /lmauth)
	fastcgi_param X_ORIGINAL_URI  $request_uri;

	# Enable AuthBasic handler.
	fastcgi_param VHOSTTYPE AuthBasic;
}
