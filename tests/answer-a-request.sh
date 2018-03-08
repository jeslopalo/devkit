#!/bin/bash

usage() {
        echo "usage: answer-a-request.sh <requestId> <registrarId> <registryCode>"
}

answer_a_request() {
	declare requestId="$1"
	declare registrarId="$2"
	declare registryCode="$3"
	
	curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
	  "answerDate": "2017-03-12T16:30:21.135Z",
	  "negative": false,
	  "registrarId": '$registrarId',
	  "registryCode": '$registryCode',
	  "text": "Prueba cualquiera"
	}' 'http://publicidad-desarrollo.osrouter.dev.corpme.int:80/v0.1/requests/'$requestId'/answer'
}

if [ "$#" != 3 ]; then
	usage
	exit 1;
fi

answer_a_request $@
exit $?

