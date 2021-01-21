#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present XargonWan (https://github.com/XargonWan)

INSTALLPATH="/storage/roms/ports"
PKG_NAME="SuperTux"
PKG_VERSION="1.0.0"
PKG_FILE="supertux.zip"
PKG_SHASUM="ADAA797276151B5275A300D8B9F8B57812DB26EDC079DFECFDD0D6179929AAE2"
PKG_URL="https://github.com/XargonWan/packages-351ELEC/"

cd ${INSTALLPATH}

curl -Lo ${PKG_FILE} ${PKG_URL}/${PKG_FILE}
BINSUM=$(sha256sum ${PKG_FILE} | awk '{print $1}')
if [ ! "${PKG_SHASUM}" == "${BINSUM}" ]
then
  echo "Checksum mismatch, please update the package."
  exit 1
fi

unzip -o "${PKG_FILE}"
rm -f "${PKG_FILE}"

mv -r ports ${INSTALLPATH}
mv -r supertux/gamedata /storage/roms/gamedata

### Create the start script
cat <<EOF >${INSTALLPATH}/"supertux.sh"
#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Xargon Wan (https://github.com/xargonwan)

# Source predefined functions and variables
. /etc/profile
export LD_LIBRARY_PATH=/storage/roms/ports/supertux/lib:/usr/lib PORT="supertux2"
export SUPERTUX_USER_DIR=/storage/roms/gamedata/supertux

# init_port binary audio(alsa. pulseaudio, default)
init_port ${PORT} alsa

/usr/bin/show_splash.sh "${PORT}"

clear >/dev/console

jslisten set "/usr/bin/killall ${PORT}"

cd /storage/roms/ports/supertux/games

./supertux2 -g 480x320 -f &>>/tmp/logs/emuelec.log

jslisten stop

ret_error=$?

end_port

exit

$ret_error
EOF

### Adding the gameslist entry
if [ ! "$(grep -q 'SuperTux' ${INSTALLPATH}/gamelist.xml)" ]
then
	### Add to the game list
	xmlstarlet ed --omit-decl --inplace \
		-s '//gameList' -t elem -n 'game' \
		-s '//gameList/game[last()]' -t elem -n 'path'        -v './supertux.sh'\
		-s '//gameList/game[last()]' -t elem -n 'name'        -v 'SuperTux'\
		-s '//gameList/game[last()]' -t elem -n 'desc'        -v 'A jump-and-run game starring Tux the Penguin. Run and jump through multiple worlds, fight off enemies by jumping on them, bumping them from below or tossing objects at them, grabbing power-ups and other stuff on the way.'\
		-s '//gameList/game[last()]' -t elem -n 'image'       -v './images/system-supertux.png'\
		-s '//gameList/game[last()]' -t elem -n 'thumbnail'   -v './images/system-supertux-thumb.png'\
        -s '//gameList/game[last()]' -t elem -n 'video'       -v './videos/system-supertux.mp4'\
		-s '//gameList/game[last()]' -t elem -n 'releasedate' -v '2016'\
		-s '//gameList/game[last()]' -t elem -n 'developer'   -v 'The SuperTux Team'\
		-s '//gameList/game[last()]' -t elem -n 'publisher'   -v 'non-commercial'\
		${INSTALLPATH}/gamelist.xml
fi