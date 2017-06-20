FROM registry.access.redhat.com/jboss-amq-6/amq62-openshift:latest

USER root

COPY usr/local/bin/ /usr/local/bin/
COPY lib/ /opt/amq/lib

USER 185