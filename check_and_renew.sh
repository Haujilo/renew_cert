#! /bin/bash -x

set -e

RENEW_BEFORE_DAYS=${RENEW_BEFORE_DAYS}
EMAIL=${EMAIL}
export DOMAIN=${DOMAIN}
export TIMEOUT=${TIMEOUT:-10}
export DP_Id=${DP_Id}
export DP_Key=${DP_Key}

CERT_EXPIRE_DATE=`curl --connect-timeout $TIMEOUT -I -s -v https://www.$DOMAIN/ 2>&1 | grep 'expire date:' | cut -d" " -f 5-`

echo "$DOMAIN certificate expire at $CERT_EXPIRE_DATE"

if [ $FORCE ] || [ `date +%s` -ge `date -d "$CERT_EXPIRE_DATE $RENEW_BEFORE_DAYS days ago" +%s` ]; then

  # install acme.sh
  git clone https://github.com/Neilpang/acme.sh.git
  (cd acme.sh && ./acme.sh --install --accountemail $EMAIL)
  export ACME_INSTALL_DIR=~/.acme.sh

  # renew cert files
  $ACME_INSTALL_DIR/acme.sh --issue --dns dns_dp -d $DOMAIN  -d "*.$DOMAIN"

  # package cert files
  ARCHIVE_FILE=$DOMAIN.`date +%Y%m%d`.zip
  zip -rj $ARCHIVE_FILE $ACME_INSTALL_DIR/$DOMAIN/*

  # archive cert files
  echo "$CERT_EXPIRE_DATE" > mail
  mpack -s "Renew $DOMAIN certificate successful" -d mail $ARCHIVE_FILE $EMAIL

  # push to servers
  scripts=`ls ./scripts | sort`
  for script in $scripts; do
    ./scripts/$script
  done
fi
