cd `dirname $0`

certbot-auto renew >> ~/renew.log 2>&1
