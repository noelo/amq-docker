#!/bin/bash 
CLUSTER_NODES=$(env|grep ":61616"|grep -v `hostname -i`|cut -d \= -f 2)
echo $CLUSTER_NODES
echo "<networkConnectors>" > /tmp/file1
for OUTPUT in $CLUSTER_NODES
  do
    echo "<networkConnector uri=\"static:("$OUTPUT")\"/>" >> /tmp/file1 
 done
echo "</networkConnectors>" >> /tmp/file1

sed '/destinationPolicy/r /tmp/file1' activemq.xml > activemq-run.conf
cat activemq-run.conf
/home/activemq/apache-activemq-5.9.0/bin/activemq console -Dactivemq.brokername=$HOSTNAME xbean:file:./activemqi-run.xml
