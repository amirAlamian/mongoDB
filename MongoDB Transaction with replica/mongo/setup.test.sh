#!/bin/bash

#MONGODB1=`ping -c 1 casitt-mongo-test | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
#MONGODB2=`ping -c 1 casitt-mongo-replica-test | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`


MONGODB1=casitt-mongo-test
MONGODB2=casitt-mongo-replica-test

echo "**********************************************" ${MONGODB1}
echo "Waiting for startup.."
until curl http://${MONGODB1}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

# echo curl http://${MONGODB1}:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
# echo "Started.."


echo SETUP.sh time now: `date +"%T" `
mongo --host ${MONGODB1}:27017 <<EOF
var cfg = {
    "_id": "my_custom_rep",
    "members": [
        {
            "_id": 0,
            "host": "${MONGODB1}:27017",
            "priority": 2
        },
        {
            "_id": 1,
            "host": "${MONGODB2}:27017",
            "priority": 0
        },
    ],settings: {chainingAllowed: true}
};
rs.initiate(cfg, { force: true });
rs.reconfig(cfg, { force: true });
rs.slaveOk();
db.getMongo().setReadPref('nearest');
db.getMongo().setSlaveOk(); 
EOF