#!/bin/sh

# ------------------------------------------------------------
# NookMesh Subscriptions Service
# Executes periodic subscription maintenance tasks
# ------------------------------------------------------------

set -e

echo "== NookMesh Subscriptions Service =="

if [ -f /nookmesh/config/filtros.env ]; then
    . /nookmesh/config/filtros.env
fi

if [ "${ENABLE_SUBSCRIPTIONS:-true}" != "true" ]; then
    echo "== Subscriptions disabled =="
    tail -f /dev/null
fi

echo "== Subscriptions enabled =="

crond -f -l 8
