#!/bin/bash

#test output from /api/execution/{id}

errorMsg() {
   echo "$*" 1>&2
}

DIR=$(cd `dirname $0` && pwd)

# accept url argument on commandline, if '-' use default
url="$1"
if [ "-" == "$1" ] ; then
    url='http://localhost:4440'
fi
apiurl="${url}/api"
VERSHEADER="X-RUNDECK-API-VERSION: 1.2"

# curl opts to use a cookie jar, and follow redirects, showing only errors
CURLOPTS="-s -S -L -c $DIR/cookies -b $DIR/cookies"
CURL="curl $CURLOPTS"


XMLSTARLET=xml

execid=$2
if [ "" == "$2" ] ; then
    execid="1"
fi

# now submit req
runurl="${apiurl}/execution/${execid}"

echo "TEST: /api/execution/${execid} ..."

params="project=${proj}"

# get listing
$CURL --header "$VERSHEADER" ${runurl}?${params} > $DIR/curl.out
if [ 0 != $? ] ; then
    errorMsg "ERROR: failed query request"
    exit 2
fi

sh $DIR/api-test-success.sh $DIR/curl.out || exit 2

#Check projects list
itemcount=$($XMLSTARLET sel -T -t -v "/result/executions/@count" $DIR/curl.out)
echo "$itemcount executions"
if [ "1" != "$itemcount" ] ; then
    errorMsg "FAIL: execution count should be 1"
    exit 2
fi
echo "OK"




#rm $DIR/curl.out

