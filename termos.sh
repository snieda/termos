#!/bin/bash
clear
cat <<EOM
##############################################################################
# install development-tools on linux (Thomas Schneider / 2023)
# 
# preconditions: linux (best: debian) or bsd system with package manager
# annotation   : on FreeBSD the bash is on: /usr/local/bin/bash
# tested on    : ubuntu, ghostbsd(freebsd), termux, msys2
#
# usage (on new system):
#  - apt update
#  - apt install sudo
#  - adduser <username>
#  - adduser <username> sudo
#  - login <username>
#  - sudo apt install wget
#  - wget https://raw.githubusercontent.com/snieda/termos/main/termos.sh
#  - chmod +x termos.sh
#  - ./termos.sh
##############################################################################


 _____     ______     __   __  
/\  __-.  /\  ___\   /\ \ / /  
\ \ \/\ \ \ \  __\   \ \ \'/   
 \ \____-  \ \_____\  \ \__|   
  \/____/   \/_____/   \/_/    
                                                                                           
         ______     __  __     ______     __         __       
        /\  ___\   /\ \_\ \   /\  ___\   /\ \       /\ \      
        \ \___  \  \ \  __ \  \ \  __\   \ \ \____  \ \ \____ 
         \/\_____\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\ 
          \/_____/   \/_/\/_/   \/_____/   \/_____/   \/_____/
                                                                                           

EOM

# ----------------------------------------------------
# system preparations
# ----------------------------------------------------
echo -------------------------------------------------------
echo "Thomas Schneider / 2023"
echo -------------------------------------------------------
echo

echo -------------------------------------------------------
echo "System : $(uname -a)"
echo "User   : $(id)"
echo "Dir    : $(pwd)"
echo -------------------------------------------------------
echo
ARCH=$(uname -m)
Os=$(uname -s)
os=${Os,,}
CC=$(pwd)

b=$(tput bold)
n=$(tput sgr0)

read -ep "Installer (apt,pacman,pkg,apk,dnf,yum,yast,zypper,snap,brew,port,scoop,apt-cyg): " -i "apt" PKG

if [ "$UID" == "0" ]; then # only on root priviledge
	$PKG install sudo > /dev/null #on minimized systems no sudo is available - you have to be root to install it!
fi
sudo -h > /dev/null #only to check, if available
if [ "$?" == "0" ]; then
	SUDO="sudo"
fi
echo

if [ "$PKG" == "apt" ];then #debian
	INST="$SUDO $PKG install -y --ignore-missing $*"
elif [ "$PKG" == "pacman" ];then #arch, msys2 (windows/cygwin)
	INST="$SUDO $PKG -S --noconfirm $*"
elif [ "$PKG" == "pkg" ];then #freebsd
	INST="$SUDO $PKG install -y --ignore-missing $*"
elif [ "$PKG" == "apk" ];then #alpine linux
	INST="$SUDO $PKG add $*"
elif [ "$PKG" == "yum" ];then #fedora
	INST="$SUDO $PKG install -y --skip-broken --tolerant $*"
elif [ "$PKG" == "yast" ];then #SUSE (old)
	INST="$SUDO $PKG --install $*"
elif [ "$PKG" == "zypper" ];then #openSUSE
	INST="$SUDO $PKG install --non-interactive --ignore-unknown --no-cd --auto-agree-with-licenses --allow-unsigned-rpm  $*"
else
  INST="$PKG install "
fi

system="sudo man htop ncurses-base ncurses-bin"
window_manager="tmux"
file_manager="mc broot"
file_search="fzy fzf tree locate ripgrep"
file_compress="archivemount grc tar rar p7zip"
file_tools="cifs-utils inotify-tools sshfs dos2unix poppler-utils"
office="docx2txt xlsx2csv xls2csv catdoc pandoc mupdf antiword printer-driver-cups-pdf"
editors="ne micro vim neovim"
viewers="bat lesspipe ffmpeg fim colordiff icdiff"
network="nethogs nmap netcat ncat tcpdump curl wget tinyproxy openssl openssh openvpn"
internet="w3m w3m-img elinks links2 googler"
develop="git podman expect progress bar pv gnupg"
languages="nodejs rust golang"
communication="himalaya weechat poezio iamb"
other="xclip xcompmgr ntp"

all=($system $window_manager $file_manager $file_search $file_compress $file_tools $office \
    $editors $viewers $network $internet $develop $languages $communication $other )

read -ep "Package Install Command  : " -i "$INST" INST
read -p  "System upgrade     (Y|n) : " INST_UPGRADE
read -ep "Install languages        : " -i "$languages" languages
read -p  "Install python-ext (Y|n) : " INST_PYTHON_EXT
read -p  "Check Package sizes(y|N) : " CHECK_PACKAGE_SIZES

echo "${all[@]}"

unavailables=()
if [ "$CHECK_PACKAGE_SIZES" == "y" ]; then
	echo "checking ${#all[@]} packages..."
	SHOW_DISK_SPACE="$PKG show "
	for i in ${!all[@]} ; do $SHOW_DISK_SPACE ${all[i]} &>/dev/null && printf "${all[i]}:OK " || { unavailables+=( ${all[i]} ) ; printf "${all[i]}:ERROR "; } ; done
	#for i in ${!unavailables[@]}; do ${all[@]/${unavailabes[i]}} ; done
	echo "available  : ${all[@]}"
	echo "unavailable: ${unavailables[@]}"

	echo "show disk space"
	$SHOW_DISK_SPACE ${all[@]} | grep -E "Package:|Installed-Size:"
fi

read -p  ">>>>>> !!! START INSTALLATION ? <<<<<<  (Y|n)  : " START

if [ "$START" == "n" ]; then
	exit
fi
echo "do some updates..."
$SUDO $PKG update
if [ "$INST_UPGRADE" != "n" ]; then
	$SUDO $PKG -y upgrade
fi

mkdir -p .local/bin

$INST git
git clone https://github.com/snieda/termos.git .config/termos
echo "copying termos configurations"
cd .config/termos && cp -ru $(ls -A -I README.MD -I LICENSE -I .git) $CC
cd $CC

echo "install packages ..."

for p in $system $window_manager $file_manager $file_search $file_compress $file_tools $office \
    $editors $viewers $network $internet $develop $communication $other ; do $INST $p || unavailables+=( $p ); done

b=$(tput bold)
n=$(tput sgr0)

echo "alias ll='ls -alF'" >> .profile

# ----------------------------------------------------
# additional terminal tools
# ----------------------------------------------------

curl https://www.gnu.org/software/bash/manual/bash.txt > bash.txt

mkdir -p .local/share/fonts

if [[ "$INST_PYTHON_EXT" != "n" ]]; then
  echo "installing python3 extensions"
  for i in python python-pip python3 python3-pip flake8 autopep8 pudb; do $INST $i; done
  for i in python-flake8 python-autopep8 python-pudb; do $INST $i; done #second try...
  pip install -U pip
  pip install flake8 autopep8 pudb # on some distributions, it may be available on pip
fi

if [ "$PKG" == "pkg" ]; then # mostly freenbsd
	for i in py37-pip; do $INST $i; done
fi

echo "installing developer font 'fantasque sans mono' to be used by terminal or vim/devicons"
curl -L https://github.com/belluzj/fantasque-sans/releases/download/v1.8.0/FantasqueSansMono-Normal.tar.gz | tar xzC $CC/.local/share/fonts

cd $CC/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
cd $CC

echo "broot and nnn filemanager with icons"
curl https://github.com/jarun/nnn/releases/download/v4.2/nnn-nerd-static-4.2.x86_64.tar.gz  | tar xzC $CC/.local/bin
curl https://dystroy.org/broot/download/$ARCH-$os/broot -o ~/bin/broot && chmod a+x $CC/.local/bin/broot
curl https://github.com/Canop/broot/raw/master/resources/icons/vscode/vscode.ttf > $CC/.local/share/fonts/vscode.ttf

if [[ "$(which fzf)" == "" ]]; then
  echo "installing Fuzzy Finder"
  wget -nc https://github.com/junegunn/fzf/raw/master/install
  mv install fzf-install.sh
  chmod a+x fzf-install.sh
  echo "yes\nyes\nyes\n\n" | ./fzf-install.sh
  curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash > shell/completion.bash
fi

if [[ "$(which micro)" == "" ]]; then
  echo "installing micro editor"
  micro -plugin install aspell editorconfig filemanager fish fzf jump lsp  quickfix wc autoclose comment diff ftoptions linter literate status
fi

echo "installing googler"
curl https://raw.githubusercontent.com/jarun/googler/v4.2/googler -o $CC/.local/bin/googler && chmod a+x $CC/.local/bin/goolger

curl https://www.benf.org/other/cfr/cfr-0.152.jar > .local/bin/cfr-0.152.jar
if [ "$INST_NODEJS" != "n" ]; then
	$INST nodejs
fi

if [ "$languages" ~= "rust" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# ----------------------------------------------------
# user/project dependent installations
# ----------------------------------------------------

if [ ! -f $CC/.ssh/id_rsa.pub ]; then 
	echo "prepare ssh key to be copied to server machines"
	echo -e "\n\n\n" | ssh-keygen -t rsa
	cat $CC/.ssh/id_rsa.pub | xclip -sel clip
fi

# reload profile
cd $CC
source .profile

[[ ${#unavailables[@]} > 0 ]] && echo "\nWARNING: couldn't install the following packages:\n\t${unavailables[@]}"

echo "$b-------------------------------------------------------"
echo "Installation finished successfull"
echo "Please have a look into your .profile"
echo "and source it with: source .profile"
echo "Input 'less bash.txt' to see shell help" 
echo "Use:"
echo " - htop as taskmananger"
echo " - <Ctrl+g> to select favorite/previous folder"
echo " - <Ctrl+h> to select command help"
echo " - <Ctrl+t> select any file in current folder hierarchy"
echo " - br or mc as filemanager"
echo " - micro, ne or vim/nvim as editor"
echo " - lvim will provide a full IDE"
echo "-------------------------------------------------------$n"
