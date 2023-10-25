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
echo "Thomas Schneider / 2016 (refreshed 2022-10)"
echo -------------------------------------------------------
echo

echo -------------------------------------------------------
echo "System : $(uname -a)"
echo "User   : $(id)"
echo -------------------------------------------------------
echo
ARCH=$(uname -m)
$Os=$(uname -s)
$os=${$(uname -s),,}

read -ep "Installer (apt,pacman,pkg,apk,yum,yast,zypper): " -i "apt" PKG

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
cp -r .profile .vimrc  .tmux.* .config .local .termux ~

echo "install packages ..."
for p in fzf fzy tmux mc tree broot archivemount locate ripgrep expect git gnupg neovim micro ne htop nethogs nmap netcat tcpdump curl wget tinyproxy xclip dos2unix poppler-utils docx2txt xlsx2csv xls2csv catdoc pandoc bat lesspipe ffmpeg fim cifs-utils openssl openssh openvpn sshfs colordiff icdiff grc tar rar p7zip ntp xcompmgr w3m w3m-img elinks links2 googler inotify-tools fzf fzy mupdf antiword  printer-driver-cups-pdf; do $INST $p ; done

curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash > shell/key-bindings.bash
curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash > shell/completion.bash
echo "alias ll='ls -alF'" >> .profile

# ----------------------------------------------------
# additional terminal tools
# ----------------------------------------------------

curl https://www.gnu.org/software/bash/manual/bash.txt > bash.txt

mkdir -p .local/share/fonts

echo "python3"
for i in python python-pip python3 python3-pip flake8 autopep8 pudb; do $INST $i; done
for i in python-flake8 python-autopep8 python-pudb; do $INST $i; done #second try...
pip install -U pip
pip install flake8 autopep8 pudb # on some distributions, it may be available on pip

if [ "$PKG" == "pkg" ]; then # mostly freenbsd
	for i in py37-pip; do $INST $i; done
fi

echo "installing developer font 'fantasque sans mono' to be used by terminal or vim/devicons"
curl -L https://github.com/belluzj/fantasque-sans/releases/download/v1.8.0/FantasqueSansMono-Normal.tar.gz | tar xzC ~/.local/share/fonts

cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
cd ~

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
curl https://raw.githubusercontent.com/jarun/googler/v4.2/googler -o ~/.local/bin/googler && chmod a+x ~/.local/bin/goolger

curl https://www.benf.org/other/cfr/cfr-0.152.jar > .local/bin/cfr-0.152.jar
if [ "$INST_NODEJS" != "n" ]; then
	$INST nodejs
fi

# ----------------------------------------------------
# user/project dependent installations
# ----------------------------------------------------

if [ ! -f ~/.ssh/id_rsa.pub ]; then 
	echo "prepare ssh key to be copied to server machines"
	echo -e "\n\n\n" | ssh-keygen -t rsa
	cat ~/.ssh/id_rsa.pub | xclip -sel clip
fi

# reload profile
cd
source .profile

echo -------------------------------------------------------
echo "Installation finished successfull"
echo "Please have a look into your .profile"
echo "Use 'br' as filemanager and micro, ne or vim as editor"
echo -------------------------------------------------------
