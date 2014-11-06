#!/bin/bash 
CLUSTER_NODES=$(env|grep ":61616"|grep -v `hostname -i`|cut -d \= -f 2)
NC_DUPLEX=$(env|grep "NC_DUPLEX")
declare -i NC_TTL 
NC_TTL=$(env|grep "NC_TTL"|cut -d \= -f 2)

if [ -z $NC_DUPLEX ]
then 
	NC_DUPLEX=false
else
	NC_DUPLEX=true
fi

if [ $NC_TTL -lt 1 ]
then
	NC_TTL=1
fi

sed -i "s/brokerName=\"localhost\"/brokerName=\"\$\{activemq.brokername\}\"/g" activemq.xml
	
if [ -z $CLUSTER_NODES ]
then
	cp activemq.xml activemq-run.xml
else
	echo $CLUSTER_NODES
	echo "<networkConnectors>" > /tmp/file1
	for OUTPUT in $CLUSTER_NODES
  	do
    		echo "<networkConnector name=\""$OUTPUT"\" uri=\"static:("$OUTPUT")\" duplex=\""$NC_DUPLEX"\"  networkTTL=\""$NC_TTL"\" decreaseNetworkConsumerPriority=\"true\" >"  >> /tmp/file1
 			echo "<excludedDestinations> <topic physicalName=\"internal.>\" /> <queue physicalName=\"internal.>\" />  </excludedDestinations> "  >> /tmp/file1
			echo "<networkConnector/>">> /tmp/file1
 	done
	echo "</networkConnectors>" >> /tmp/file1

	sed '/<\/destinationPolicy/r /tmp/file1' activemq.xml > activemq-run.xml
fi

#Add interceptors
sed -i '/<\/persistenceAdapter>/a<plugins><statisticsBrokerPlugin\/><connectionDotFilePlugin file = "ActiveMQConnections.dot" \/><destinationDotFilePlugin file ="ActiveMQDestinations.dot"\/><traceBrokerPathPlugin\/><loggingBrokerPlugin logAll="false" logConnectionEvents="true"\/><\/plugins>' activemq-run.xml


cat activemq-run.xml
/home/activemq/apache-activemq-5.9.0/bin/activemq console -Dactivemq.brokername=$HOSTNAME xbean:file:./activemq-run.xml
