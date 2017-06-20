FROM registry.access.redhat.com/jboss-amq-6/amq62-openshift:latest

USER root

COPY usr/local/bin/fix-permissions.sh /usr/local/bin/fix-permissions.sh
COPY lib/groovy-all-2.4.11.jar /opt/amq/lib/groovy-all-2.4.11.jar

RUN chmod 775 /usr/local/bin/* \
  && /usr/local/bin/fix-permissions.sh /usr/local/bin \
  && /usr/local/bin/fix-permissions.sh /opt/amq/lib \
  && chown -R jboss:jboss /opt/amq/lib

USER 185