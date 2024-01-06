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
# usage (on new system, e.g: docker run -it --rm bitnami/minideb):
#  - apt update
#  - apt install sudo
#  - adduser <username>
#  - adduser <username> sudo
#  - login <username>
#  - sudo apt install wget
#  - wget https://raw.githubusercontent.com/snieda/termos/main/termos.sh
#  - chmod +x termos.sh
#  - ./termos.sh
#
#  or as one-liner:
#
#  apt update; apt install -y sudo; devu=test && adduser --gecos "" --disabled-password $devu && chpasswd <<<"$devu:$devu" && adduser $devu sudo &&  su $devu -c "sudo -S apt install -y wget <<<$devu && cd /home/$devu && wget https://raw.githubusercontent.com/snieda/termos/main/termos.sh && . termos.sh"
#
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

START_TIME=$(date)
b=$(tput bold)
n=$(tput sgr0)

read -ep "Installer [apt,pacman,pkg,apk,dnf,yum,yast,zypper,snap,brew,port,scoop,apt-cyg]: " -i "apt" PKG

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

system="sudo man htop btop ncurses-base ncurses-bin ncurses-util software-properties-common make fuse"
window_manager="tmux"
file_manager="mc broot"
file_search="fzy fzf tree locate ripgrep"
file_compress="archivemount grc tar rar bsdtar p7zip libarchive-tools"
file_tools="cifs-utils inotify-tools sshfs dos2unix poppler-utils"
office="docx2txt xlsx2csv xls2csv catdoc pandoc mupdf antiword printer-driver-cups-pdf"
editors="ne micro vim neovim"
viewers="bat lesspipe ffmpeg fim colordiff icdiff"
network="telnet net-tools nethogs nmap netcat ncat tcpdump curl wget tinyproxy openssl openssh openvpn"
internet="w3m w3m-img elinks links2 googler"
develop="git lazygit podman expect autoexpect progress bar pv gnupg jq sqlline"
languages="nodejs cargo openjdk-17-jdk maven golang-go"
nvim_plugins="pynvim luarocks composer"
python_nvim_jupyter="python-full jupyter-client pyperclip cairosvg pnglatex plotly kaleido luajit libmagickwand-dev libgraphicsmagick1-dev"
communication="himalaya weechat poezio iamb finch"
media=mp3blaster
other="xclip xcompmgr ntp tmate"

unpackaged="dasel broot nnn carbonyl cfr"

read -ep "Package Install Command  : " -i "$INST" INST
read -p  "System upgrade     [Y|n] : " INST_UPGRADE
read -ep "Install languages        : " -i "$languages" languages
read -p  "Install python-ext [Y|n] : " INST_PYTHON_EXT
read -p  "Check Package sizes[y|N] : " CHECK_PACKAGE_SIZES

all=($system $window_manager $file_manager $file_search $file_compress $file_tools $office \
    $editors $viewers $network $internet $languages $develop $nvim_plugins $communication $media $other )

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

if [ "$PKG" == "apt" ]; then
echo "add repositories for neovim"
  $INST software-properties-common
  sudo add-apt-repository ppa:neovim-ppa/stable
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


for p in $all ; do $INST $p || unavailables+=( $p ); done

b=$(tput bold)
n=$(tput sgr0)

echo "alias ll='ls -alF'" >> .profile

# ----------------------------------------------------
# additional terminal tools
# ----------------------------------------------------

# dasel as data selector for json/yaml/xml
if [[ "$(which go)" != "" ]]; then
  go install github.com/tomwright/dasel/v2/cmd/dasel@master
fi

curl -L https://www.gnu.org/software/bash/manual/bash.txt > bash.txt

mkdir -p .local/share/fonts

if [[ "$INST_PYTHON_EXT" != "n" ]]; then
  $INST python3-venv
  VIRTUAL_ENV=~/.config/python3-venv
  python3 -m venv $VIRTUAL_ENV
  source $VIRTUAL_ENV/bin/activate

  echo "installing python3 extensions"
  for i in python python-pip python3 python3-pip flake8 autopep8 debugpy pudb; do $INST $i; done
  for i in python-flake8 python-autopep8 python-pudb; do $INST $i; done #second try...
  pip install -U pip
  pip install flake8 autopep8 pudb # on some distributions, it may be available on pip
  
  for i in $python_nvim_jupyter; do $INST $i; done
  for i in $python_nvim_jupyter; do pip install $i; done
  for i in $nvim_plugins; do $Inst $i; done
  for i in $nvim_plugins; do pip install $i; done
fi

if [ "$PKG" == "pkg" ]; then # mostly freenbsd
	for i in py37-pip; do $INST $i; done
fi

echo "installing developer font 'fantasque sans mono' to be used by terminal or vim/devicons"
curl -L https://github.com/belluzj/fantasque-sans/releases/download/v1.8.0/FantasqueSansMono-Normal.tar.gz | tar xzC $CC/.local/share/fonts

cd $CC/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
cd $CC

echo "broot and nnn filemanager with icons"
curl -L https://github.com/jarun/nnn/releases/download/v4.2/nnn-nerd-static-4.2.$ARCH.tar.gz  | tar xzC $CC/.local/bin
curl -L https://dystroy.org/broot/download/$ARCH-$os/broot -o $CC/.local/bin/broot && chmod a+x $CC/.local/bin/broot
curl -L https://github.com/Canop/broot/raw/master/resources/icons/vscode/vscode.ttf > $CC/.local/share/fonts/vscode.ttf

if [[ ! -f "$CC/shell/completion.bash" ]]; then
  echo "installing Fuzzy Finder"
  wget -nc https://github.com/junegunn/fzf/raw/master/install
  mv install fzf-install.sh
  chmod a+x fzf-install.sh
  echo "yes\nyes\nyes\n\n" | ./fzf-install.sh
  mkdir $CC/shell
  curl -L https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash > $CC/shell/key-bindings.bash
  curl -L  https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash > $CC/shell/completion.bash
fi

if [[ "$(which micro)" == "" ]]; then
  echo "installing micro editor"
  micro -plugin install aspell editorconfig filemanager fish fzf jump lsp  quickfix wc autoclose comment diff ftoptions linter literate status
fi

echo "installing googler"
curl -L https://raw.githubusercontent.com/jarun/googler/v4.2/googler -o $CC/.local/bin/googler && chmod a+x $CC/.local/bin/googler

echo "installing carbonyl terminal chromium browser"
curl -L https://github.com/fathyb/carbonyl/releases/download/v0.0.3/carbonyl.$os-amd64.zip | bsdtar -xvf - -C $CC
chmod +x $CC/carbonyl-0.0.3/carbonyl

curl https://www.benf.org/other/cfr/cfr-0.152.jar > $CC/.local/bin/cfr-0.152.jar

if [[ "$languages" == *"rust"* || "$languages" == *"cargo"* ]]; then
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

if [ "$(which lvim)" == "" ]; then
  if [ $(echo "$(nvim -v | sed -nE 's/.* v([0-9]+\.[0-9]+).*/\1/p') < 0.9" | bc -l) -eq 1 ]; then
    curl -sL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz | tar xzfv - -C $CC/.local/bin
    ln -s $CC/.local/bin/nvim-linux64/bin/nvim $CC/.local/bin/nvim
  fi
  echo "install lunarvim"
  LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
fi

# reload profile
cd $CC
source .profile

[[ ${#unavailables[@]} > 0 ]] && echo "\nWARNING: couldn't install the following packages:\n\t${unavailables[@]}"

echo "$b----------------------------------------------------------------------"
echo "$(date) - Installation finished successfull (started at: $START_TIME)"
echo "Please have a look into your .profile"
echo "and source it with: source .profile"
echo "Input \"less bash.txt\" to see shell help" 
echo "Use:"
echo " - btop or htop as taskmananger"
echo " - <Ctrl+g> to select favorite/previous folder"
echo " - <Ctrl+h> to select command help"
echo " - <Ctrl+t> select any file in current folder hierarchy"
echo " - br or mc as filemanager"
echo " - micro, ne or vim/nvim as editor"
echo " - telnet mapscii.me to show a map"
echo " - googler to search in internet"
echo " - carbonyl, w3m, links2 or elinks as browser"
echo " - lvim will provide a full IDE"
echo "-----------------------------------------------------------------------$n"
