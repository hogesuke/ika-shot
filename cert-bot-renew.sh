cd `dirname $0`

service nginx stop

certbot-auto renew --post-hook "service nginx start" >> ~/renew.log 2>&1
