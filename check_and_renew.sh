#! /bin/bash

DOMAIN=${DOMAIN}
RENEW_BEFORE_DAYS=${RENEW_BEFORE_DAYS}
EMAIL=${EMAIL}
TIMEOUT=${TIMEOUT:-10}
export DP_Id=${DP_Id}
export DP_Key=${DP_Key}

CERT_EXPIRE_DATE=`curl --connect-timeout $TIMEOUT -I -s -v https://www.$DOMAIN/ 2>&1 | grep '^*  expire date:' | cut -d" " -f 5-`

echo "$DOMAIN certificate expire at $CERT_EXPIRE_DATE"

if [ $FORCE ] || [ `date +%s` -ge `date -d "$CERT_EXPIRE_DATE $RENEW_BEFORE_DAYS days ago" +%s` ]; then

  # install acme.sh
  git clone https://github.com/Neilpang/acme.sh.git
  ./acme.sh/acme.sh --install --accountemail $EMAIL
  alias acme.sh=~/.acme.sh/acme.sh

  # renew cert files
  acme.sh --issue --dns dns_dp -d $DOMAIN  -d "*.$DOMAIN"
  (cd ~/.acme.sh/$DOMAIN/ && openssl x509 -in $DOMAIN.cer -out $DOMAIN.crt)

  # package cert files
  ARCHIVE_FILE=$DOMAIN.`date +%Y%m%d`.zip
  zip -rj $ARCHIVE_FILE ~/.acme.sh/$DOMAIN/*

  # TODO:push to servers

  # archive cert files
  echo "$CERT_EXPIRE_DATE" | mail -s "Renew $DOMAIN certificate successful" -a $ARCHIVE_FILE $EMAIL
fi
