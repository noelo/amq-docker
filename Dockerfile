FROM fedora:20
#RUN echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
#RUN /bin/systemctl stop firewalld.service

RUN yum install -y java-1.7.0-openjdk which unzip openssh-server sudo openssh-clients
# enable no pass and speed up authentication
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/;s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

# enabling sudo group
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
# enabling sudo over ssh
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

ENV JAVA_HOME /usr/lib/jvm/jre

ENV FABRIC8_KARAF_NAME root
ENV FABRIC8_BINDADDRESS 0.0.0.0
ENV FABRIC8_PROFILES docker

# add a user for the application, with sudo permissions
RUN useradd -m fabric8 ; echo fabric8: | chpasswd ; usermod -a -G wheel fabric8

# command line goodies
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /etc/profile
RUN echo "alias ll='ls -l --color=auto'" >> /etc/profile
RUN echo "alias grep='grep --color=auto'" >> /etc/profile


WORKDIR /home/fabric8

USER fabric8

#RUN curl --silent --output fabric8.zip https://repository.jboss.org/nexus/content/groups/fs-public-snapshots/io/fabric8/fabric8-karaf/1.1.0-SNAPSHOT/fabric8-karaf-1.1.0-20140408.090633-16.zip
RUN curl --silent --output apache-mq.zip http://central.maven.org/maven2/org/apache/activemq/apache-activemq/5.9.0/apache-activemq-5.9.0-bin.zip
RUN unzip apache-mq.zip
RUN rm apache-mq.zip
RUN chown -R fabric8:fabric8 apache-activemq-5.9.0

WORKDIR /home/fabric8/apache-activemq-5.9.0/conf
RUN mv activemq.xml activemq.xml.orig
RUN cp ../examples/conf/activemq-dynamic-network-broker1.xml activemq.xml  
RUN sed -i "s/brokerName=\"localhost\"/brokerName=\"\$\{activemq.brokername\}\"/g" activemq.xml
#RUN sed -i '/<destinationPolicy>/i <networkConnectors><networkConnector uri="multicast://224.0.0.251:6255?group=dockergroup&amp;trace=true"/></networkConnectors>'  activemq.xml

WORKDIR /home/fabric8/apache-activemq-5.9.0/bin
RUN chmod u+x ./activemq

WORKDIR /home/fabric8/apache-activemq-5.9.0/

# ensure we have a log file to tail
RUN mkdir -p data/
RUN echo >> data/activemq.log
EXPOSE 22 1099 61616 8161 5672 61613 1883 61614

USER root

#RUN echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
ENTRYPOINT  /home/fabric8/apache-activemq-5.9.0/bin/activemq console -Dactivemq.brokername=$HOSTNAME

#ENTRYPOINT /bin/systemctl stop firewalld.service
