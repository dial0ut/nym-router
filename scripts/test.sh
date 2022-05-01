#!/bin/bash

## Colours variables for the installation script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT


# setting working directory
#set -x
WORK_DIR="${HOME}/nym-router-builder"
check_dep() {
if [ ! -e ${HOME}/.cargo/bin/cargo ]
then 
    printf "%b\n\n\n"  "We need ${YELLOW}Cargo for cross-compiling this program for your ${YELLOW}router ${WHITE}... Do you want to install it?" 
    printf "%b\n\n\n"  "For simple installation, press ${GREEN}1 ${WHITE}in the following section"
    while true ; do
        read -p  $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;37m] Do you want to continue \e[1;92mYes - (Yy) \e[1;37m or  \e[1;91mNo - (Nn)  ?? :  \e[0m' yn
        case $yn in
            [Yy]* ) curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && source $HOME/.cargo/env && break;;
            [Nn]* ) exit;;
        esac
    done
fi
}
check_dep
create_dir() {
  printf "%b\n\n\n" "${WHITE} --------------------------------------------------------------------------------"
  #printf "${WHITE}This script will create a directory in your ${LBLUE}${HOME} ${WHITE}directory${WHITE} called ${YELLOW}nym-router-builder${WHITE}\n"
  #echo
  printf "%b\n\n\n" " ${LGREEN}
  
o   o o   o o   o      o-o                o       o o--o  o-O-o 
|\  |  \ /  |\ /|     o   o               |       | |   |   |   
| \ |   O   | O | o-o |   | o-o  o-o o-o  o   o   o O-Oo    |   
|  \|   |   |   |     o   o |  | |-' |  |  \ / \ /  |  \    |   
o   o   o   o   o      o-o  O-o  o-o o  o   o   o   o   o   o   
                            |                                   
                            o                                    ${WHITE} " 
  
  if [ ! -d ${WORK_DIR} ]
  then 
  printf "${WHITE}This script will create a directory in your ${LBLUE}${HOME} ${WHITE}directory${WHITE} called ${YELLOW}nym-router-builder${WHITE}\n"
  printf "%b\n\n\n"  
    while true ; do
        read -p  $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;37m] Do you want to continue \e[1;92mYes - (Yy) \e[1;37m or  \e[1;91mNo - (Nn)  ?? :  \e[0m' yn
        case $yn in
            [Yy]* ) mkdir -p $HOME/nym-router-builder && break;;
            [Nn]* ) exit;;
        esac
    done
  printf "%b\n\n\n" 
  printf "%b\n\n\n" "${LGREEN}Nym-${LBLUE}OpenWRT${WHITE} will be built in ${YELLOW} $WORK_DIR ${WHITE}"
    
  else
    printf "%b\n\n\n"  "${YELLOW}${WORK_DIR} ${WHITE}already exists!!!"
  fi
}

download_openwrt() {
	cd ${WORK_DIR}

	# pull code
	if [ ! -d "openwrt" ]; then
  		git clone https://git.openwrt.org/openwrt/openwrt.git	
	fi
}

change_openwrt_branch() {
  set -x
  cd ${WORK_DIR}/openwrt
  printf "%b\n\n\n" 
  printf "%b\n\n\n" "${LBLUE}OpenWRT${WHITE} version will be ... ${YELLOW} ${OPENWRT_BRANCH} ... ${WHITE}"
  printf "%b\n\n\n" "${WHITE}To change this - pass the desired version with ${YELLOW}-V ${WHITE}flag as a string within ""..."
# setting branch
  if [ "${OPENWRT_BRANCH}" = "" ]
  then
	  DEFAULT_OPENWRT_BRANCH="openwrt-21.02"
  else
	  DEFAULT_OPENWRT_BRANCH="${OPENWRT_BRANCH}"

	  if [ "${1}" = "" ]
	  then
	  	echo "Building ${DEFAULT_OPENWRT_BRANCH}"
	  	git checkout -B ${DEFAULT_OPENWRT_BRANCH} origin/${DEFAULT_OPENWRT_BRANCH}
	  else
	  	echo "Building ${1}"
	  	git checkout -B ${1} origin/${1}
	  fi
  fi
}
init_openwrt_branch() {
	cd ${WORK_DIR}/openwrt

	git stash
	git pull --all
	git pull --tags
}

#init_openwrt_link() {
#	cd ${WORK_DIR}/openwrt
#
#	chown 1000:1000 /src -R
#
#	mkdir -p src/dl
#	mkdir -p src/staging_dir
#	mkdir -p src/build_dir
#	mkdir -p src/tmp
#	mkdir -p src/bin
#
#	ln -s /src/dl ${WORK_DIR}/openwrt/dl
#	ln -s /src/staging_dir ${WORK_DIR}/openwrt/staging_dir
#	ln -s /src/build_dir ${WORK_DIR}/openwrt/build_dir
#	ln -s /src/tmp ${WORK_DIR}/openwrt/tmp
#}

update_install_openwrt_feeds() {
	cd ${WORK_DIR}/openwrt

	./scripts/feeds update -a
	./scripts/feeds install -a
}

openwrt_init_config() {
	cd ${WORK_DIR}/openwrt

	echo "CONFIG_TARGET_aarch64-unknown-linux-musl=y" > ${WORK_DIR}/openwrt/.config
	echo "CONFIG_TARGET_armv7-unknown-linux-musl=y" >> ${WORK_DIR}/openwrt/.config
}

openwrt_make_build_env() {
	cd ${WORK_DIR}/openwrt

	make defconfig
	make -j4 download
 	make -j4 tools/install
 	make -j4 toolchain/install
}

openwrt_make() {
	cd ${WORK_DIR}/openwrt
  #git clone https://github.com/nymtech/nym.git
  #git checkout tags/v0.12.1
	#cross build --bins nym-gateway --release #--target aarch64-unknown-linux-musl  --features vendored-openssl
  make -j4
}
git_clone_nym(){
  cd ${WORK_DIR}/openwrt
  git clone https://github.com/nymtech/nym.git
  cd nym
  git checkout tags/v0.12.1
}

openwrt_install_nym-router_feeds() {
	cd ${WORK_DIR}/openwrt

	echo "src-git nym-router https://github.com/The-Pacific-NW-Rural-Broadband-Alliance/nym-router" >> feeds.conf.default

	./scripts/feeds update nym-router
	./scripts/feeds install nym-router
}

openwrt_install_package_nym-router_config() {
	cd ${WORK_DIR}/openwrt

	echo "CONFIG_FEED_nym-router=y" >> ${WORK_DIR}/openwrt/.config
	echo "CONFIG_PACKAGE_nym-router=m" >> ${WORK_DIR}/openwrt/.config
	echo "CONFIG_PACKAGE_nym-router-dev=m" >> ${WORK_DIR}/openwrt/.config
}

create_dir #&& mkdir -p $HOME/nym-router-builder && printf "%b\n\n\n" "${WHITE} ${LGREEN}Nym-${LBLUE}OpenWRT${WHITE} will be built in ${YELLOW} $WORK_DIR"

download_openwrt
change_openwrt_branch
init_openwrt_branch
init_openwrt_link
update_install_openwrt_feeds
openwrt_init_config
openwrt_make_build_env
openwrt_make
openwrt_install_nym-router_feeds
openwrt_install_package_nym-router_config
#cross build --bins nym-gateway --release --target aarch64-unknown-linux-musl  --features vendored-openssl



