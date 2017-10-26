#!/bin/bash

server_dir="$HOME/csgo_retakes/csgo"
configs="$HOME/github/CSGO-RETAKES/csgo/addons/sourcemod/configs/"
cd_dir="eval cd "$HOME/github/CSGO-RETAKES/csgo/""

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}Removing Existing Addons Directory if Applicable. If You Don't Have an installed server to csgo_retakes, then this will Do nothing and is safe. Script will continue in 10 Secs...${NC}" && sleep 10
rm -rf $server_dir/addons

# make addons folder
test -e $server_dir/addons || mkdir $server_dir/addons

# metamod
echo -e "${GREEN}Installing Metamod...${NC}" && sleep 2
for dest in $server_dir/addons
do
cp -rf $HOME/github/CSGO-RETAKES/csgo/addons/metamod $dest
cp -rf $HOME/github/CSGO-RETAKES/csgo/addons/metamod.vdf $dest
done 

# sourcemod
echo -e "${GREEN}Downloading & Installing Sourcemod...${NC}" && sleep 2
url=$(curl -s https://sm.alliedmods.net/smdrop/1.8/sourcemod-latest-linux)
wget "https://sm.alliedmods.net/smdrop/1.8/$url"
tar -xvzf "${url##*/}" -C $server_dir

echo -e "${GREEN}Copying Over Pre-Configured SourceMod Config & Plugins...${NC}" && sleep 2
for dest in $server_dir/addons/
do
cp -rf $HOME/github/CSGO-RETAKES/csgo/addons/sourcemod $dest
done

echo -e "${GREEN}Copying Over Pre-Configured Config Files...${NC}" && sleep 2
# cfg files
rm -rf "$configs\database.cfg" "$configs\admins.cfg" "$configs\admin_groups.cfg"
for dest in $server_dir/cfg/
do
cp -rf $HOME/github/CSGO-RETAKES/csgo/cfg/sourcemod $dest
cp -rf $HOME/github/CSGO-RETAKES/csgo/cfg/* $dest
done

# Copy start script and start server
echo -e "${GREEN}Copying Over Start Script and Starting Server...${NC}" && sleep 5
for dest in $HOME/csgo_retakes
do
cp -rf $HOME/github/CSGO-RETAKES/scripts/start.sh $dest && cd $dest && sh start.sh
done
