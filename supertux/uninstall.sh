#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present XargonWan (https://github.com/XargonWan)

INSTALLPATH="/storage/roms/ports"
PKG_NAME="supertux"

rm -rf "${INSTALLPATH}/${PKG_NAME}"
rm -f "${INSTALLPATH}/images/system-${PKG_NAME}*"
rm -f "${INSTALLPATH}/videos/system-${PKG_NAME}*"

CFG="/storage/.emulationstation/es_systems.cfg"
xmlstarlet ed -L -P -d "/systemList/system[name='SuperTux']" $CFG