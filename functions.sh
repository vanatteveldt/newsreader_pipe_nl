####################
# HELPER FUNCTIONS #
####################

bold=`tput bold`
em=`tput bold;tput setaf 4`
green=`tput bold;tput setaf 2`
red=`tput bold;tput setaf 1`
reset=`tput sgr0`

function msg {
    COL=${2-$em} 
    echo -e "${COL}** ${reset}"
    echo -e "${COL}** $1${reset}"
    echo -e "${COL}** ${reset}"
}

WAS_INSTALLED=0
function install_git {
    REPO=https://github.com/$1
    SUBDIR="$MDIR/`basename $REPO`"
    if [ -d "$SUBDIR" ]; then 
	WAS_INSTALLED=0
    else
	msg "cloning $REPO into $SUBDIR"
	echo git clone $REPO $SUBDIR "${@:2}"
	git clone $REPO $SUBDIR "${@:2}"
	cd $SUBDIR
	WAS_INSTALLED=1
    fi
}

function install_mvn {
    install_git $1
    if [ $WAS_INSTALLED = 1 ]; then
	msg "compiling $1"
	mvn -Dmaven.compiler.target=1.7 -Dmaven.compiler.source=1.7 clean package
    fi
}

function install_tgz {
    dest=$1
    url=$2
    if [ ! -d "$dest" ]; then
	msg "Extracting $url to $dest"
	curl $url | tar xz -C $TDIR
    fi
}
