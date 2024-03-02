#!/bin/bash

# Downloads the current version of all the libs

echo "Removing libs..."
rm *.lua

echo "Downloading libs..."

wget -q "https://raw.githubusercontent.com/rxi/autobatch/master/autobatch.lua"
wget -q "https://raw.githubusercontent.com/rxi/classic/master/classic.lua"
wget -q "https://raw.githubusercontent.com/rxi/coil/master/coil.lua"
wget -q "https://raw.githubusercontent.com/rxi/flux/master/flux.lua"
wget -q "https://raw.githubusercontent.com/rxi/log.lua/master/log.lua"
wget -q "https://raw.githubusercontent.com/rxi/lovebird/master/lovebird.lua"
wget -q "https://raw.githubusercontent.com/rxi/lovebpm/master/lovebpm.lua"
wget -q "https://raw.githubusercontent.com/rxi/lume/master/lume.lua"
wget -q "https://raw.githubusercontent.com/rxi/shash/master/shash.lua"
wget -q "https://raw.githubusercontent.com/rxi/tick/master/tick.lua"

echo "Done"
