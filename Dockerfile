FROM centos:7
RUN yum -y update && \
    yum -y install NetworkManager iproute && \
    yum clean all
COPY setup-the-bridge.sh /setup-the-bridge.sh
CMD /setup-the-bridge.sh
