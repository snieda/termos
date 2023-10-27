#!/bin/bash
clear
cat <<EOM
##############################################################################
# install development-tools on linux (Thomas Schneider / 2023)
# 
# preconditions: linux (best: debian) or bsd system with package manager
# annotation   : on FreeBSD the bash is on: /usr/local/bin/bash
# tested on    : ubuntu, ghostbsd(freebsd), termux, msys2
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
$Os=$(uname -s)
$os=${$(uname -s),,}
$CC=$(pwd)

read -ep "Installer (apt,pacman,pkg,apk,dnf,yum,yast,zypper,snap,brew,port,scoop): " -i "apt" PKG

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

read -ep "Package Install Command                        : " -i "$INST" INST
echo "============ System and VirtualBox informations ============"

read -p  "System upgrade                           (Y|n) : " INST_UPGRADE
echo     "================== development IDE+Tools ===================="
read -p  "Install nodejs                           (Y|n) : " INST_NODEJS
read -ep "Install python                         Version : " -i 2022.05 INST_PYTHON_ANACONDA
read -p ">>>>>> !!! START INSTALLATION ? <<<<<<  (Y|n)  : " START
if [ "$START" == "n" ]; then
	exit
fi
echo "do some updates..."
$SUDO $PKG update
if [ "$INST_UPGRADE" != "n" ]; then
	$SUDO $PKG -y upgrade
fi

echo "copying configurations"
cp -r .bashrc .profile .vimrc  .tmux.* .config .local .termux $CC

echo "install packages ..."

task_manager="htop"
window_manager="tmux"
file_manager="mc broot"
file_search="fzy fzf tree locate ripgrep"
file_compress="archivemount grc tar rar p7zip"
file_tools="cifs-utils inotify-tools sshfs dos2unix poppler-utils"
office="docx2txt xlsx2csv xls2csv catdoc pandoc mupdf antiword printer-driver-cups-pdf"
editors="ne micro vim neovim"
viewers="bat lesspipe ffmpeg fim colordiff icdiff"
network="nethogs nmap netcat tcpdump curl wget tinyproxy openssl openssh openvpn"
internet="w3m w3m-img elinks links2 googler"
develop="git expect progress bar pv"
communication="himalaya weechat poezio iamb"
other="xclip gnupg xcompmgr ntp"

unavailables=()
for p in $task_manager $window_manager $file_manager $file_search $file_compress $file_tools $office \
    $editors $viewers $network $internet $develop $communication $other ; do $INST $p || unavailables += ( $p ); done


curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash > shell/key-bindings.bash
curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash > shell/completion.bash
echo "alias ll='ls -alF'" >> .profile

# ----------------------------------------------------
# additional terminal tools
# ----------------------------------------------------

curl https://www.gnu.org/software/bash/manual/bash.txt > bash.txt

mkdir -p .local/share/fonts

echo "nstalling python3 extensions"
for i in python python-pip python3 python3-pip flake8 autopep8 pudb; do $INST $i; done
for i in python-flake8 python-autopep8 python-pudb; do $INST $i; done #second try...
pip install -U pip
pip install flake8 autopep8 pudb # on some distributions, it may be available on pip

if [ "$PKG" == "pkg" ]; then # mostly freenbsd
	for i in py37-pip; do $INST $i; done
fi

echo "installing developer font 'fantasque sans mono' to be used by terminal or vim/devicons"
curl -L https://github.com/belluzj/fantasque-sans/releases/download/v1.8.0/FantasqueSansMono-Normal.tar.gz | tar xzC $CC/.local/share/fonts

cd $CC/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
cd $CC

echo "installing Fuzzy Finder"
wget -nc https://github.com/junegunn/fzf/raw/master/install
mv install fzf-install.sh
chmod a+x fzf-install.sh
echo "yes\nyes\nyes\n\n" | ./fzf-install.sh

echo "installing micro editor"
micro -plugin install aspell editorconfig filemanager fish fzf jump lsp  quickfix wc autoclose comment diff ftoptions linter literate status

echo "additional cli tools"
for i in progress autojump archivemount sshfs fzy locate apropos; do $INST $i; done

echo "installing googler"
curl https://raw.githubusercontent.com/jarun/googler/v4.2/googler -o $CC/.local/bin/googler && chmod a+x $CC/.local/bin/goolger

curl https://www.benf.org/other/cfr/cfr-0.152.jar > .local/bin/cfr-0.152.jar
if [ "$INST_NODEJS" != "n" ]; then
	$INST nodejs
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

[[ ${#unavailables[@]} > 0 ]] && echo " couldn't install the following packages: ${unavailables[@]}"

echo -------------------------------------------------------
echo "Installation finished successfull"
echo "Please have a look into your .profile"
echo "Use:"
echo " - htop as taskmananger"
echo " - br or mc as filemanager"
echo " - micro, ne or vim/nvim as editor"
echo " - lvim will provide a full IDE"
echo -------------------------------------------------------
