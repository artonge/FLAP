location = /lmauth_basic {
	internal;
	include fastcgi_params;
	# Use resolver and variable to prevent nginx to crash when it does not found the upstream host.
	resolver 127.0.0.11 valid=30s;
	set $upstream_lemon lemon;
	fastcgi_pass $upstream_lemon:9000;

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
