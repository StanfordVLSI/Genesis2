#!/bin/csh -f

# I dunno, maybe "verify_stewie.csh vlsiweb 8080"?

set server = $1
set port=$2
  if ("$port" != "") set port = ':'$port
set url = "http://$server$port"

echo "Checking fftgen for stewie at $url"
