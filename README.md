amq-docker
==============

This project builds a [docker](http://docker.io/) container for running Apache ActiveMQ message broker

Try it out
----------
I haven't as yet added this to the Docker Repository so you'll have to follow the instructions for building it locally.

Once installed you should be able to try it out via

    docker run -P -d -t amq:amq

You can also add network connectors by using the --link argument when running the container. The duplex and TTL settings for these network connectors can also be set using --env variables.

For example the following code will setup and network of four activemq brokers capable of passing message back and forth

docker run  -d -P --name amq1 --env NC_DUPLEX=true --env NC_TTL=5 amq:amq
docker run  -d -P --name amq2 --env NC_DUPLEX=true --env NC_TTL=5 amq:amq
docker run  -d -P --name amq-central --link amq1:east1 --link amq2:east2  --env NC_DUPLEX=true --env NC_TTL=5 amq:amq
docker run  -d -P --name amq3  --link amq-central:central --env NC_DUPLEX=true --env NC_TTL=5 amq:amq

There is no security settings configured on the ActiveMQ brokers


Building the docker container locally
-------------------------------------
Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

git clone https://github.com/noelo/amq-docker.git
docker build -t amq:amq .


