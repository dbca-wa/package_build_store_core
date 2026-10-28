#!/usr/bin/env bash

set -euo pipefail

export LIBREOFFICE_HOME="/opt/libreoffice"
export PATH="/opt/libreoffice/program:${PATH}"
export PYTHONPATH="/opt/libreoffice/program${PYTHONPATH:+:${PYTHONPATH}}"
export LD_LIBRARY_PATH="/opt/libreoffice/program${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

exec /opt/libreoffice/program/soffice "$@"
