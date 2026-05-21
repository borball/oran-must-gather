FROM registry.redhat.io/openshift4/ose-must-gather:latest

COPY collection-scripts/ /usr/bin/

RUN chmod +x /usr/bin/gather

ENTRYPOINT /usr/bin/gather
