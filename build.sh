#!/bin/bash
docker build \
    --rm=true --force-rm=true \
    --build-arg MISP_FQDN=localhost \
    --build-arg MISP_ADMIN_PASSWORD=Ciao1234567890 \
    -t prova/misp web
