set -e 

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
    SUBDIR="$DIR/modules/`basename $REPO`"
    if [ -d "$SUBDIR" ]; then 
	WAS_INSTALLED=0
    else
	msg "cloning $REPO into $SUBDIR"
	git clone $REPO $SUBDIR
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

#####################
# INSTALL FUNCTIONS #
#####################

function install_nerc {
    if [ ! -d "$TDIR/nerc-models-1.5.4/" ]; then
	msg "Downloading NERC models"
	# nl models only, can download original from http://ixa2.si.ehu.es/ixa-pipes/models/nerc-models-1.5.4.tgz
	curl http://i.amcat.nl/nerc-models-1.5.4-nl.tgz | tar xz -C $TDIR
    fi
    install_mvn ixa-ehu/ixa-pipe-nerc
}

function install_ned {
    SDIR=$TDIR/spotlight
    if [ ! -d "$SDIR" ]; then
	msg "Installing DBPedia Spotlight"
	mkdir -p $SDIR
	cd $SDIR
	wget http://spotlight.sztaki.hu/downloads/archive/2014/dbpedia-spotlight-0.7.jar
	curl http://spotlight.sztaki.hu/downloads/archive/2014/nl.tar.gz | tar xz 
	mvn install:install-file -Dfile=dbpedia-spotlight-0.7.jar -DgroupId=ixa -DartifactId=dbpedia-spotlight -Dversion=0.7 -Dpackaging=jar -DgeneratePom=true
    fi
    install_mvn ixa-ehu/ixa-pipe-ned
}

function install_wsd {
    install_git cltl/svm_wsd/
    if [ $WAS_INSTALLED = 1 ]; then
	msg "Installing libsvm"
	curl https://codeload.github.com/cjlin1/libsvm/tar.gz/master | tar -xz
	mkdir -p lib
	mv libsvm-master lib/libsvm
	(cd lib/libsvm/python; make -s)
	msg "Downloading WSD models"
	curl -u cltl:.cltl. kyoto.let.vu.nl/~izquierdo/models_wsd_svm_dsc.tgz | tar -xz
    fi
}

#####################
#        MAIN       #
#####################

DIR=`dirname "$(readlink -f "$0")"`
MDIR=$DIR/modules
TDIR=$DIR/tools
mkdir -p $TDIR

msg "Checking prerequisites"
for REQ in java mvn git; do
    if ! type -p $REQ; then
	msg "${red}$REQ not installed!${reset}" $red
	exit 1
    fi
done

### Install modules
install_mvn ixa-ehu/ixa-pipe-tok
install_git cltl/morphosyntactic_parser_nl
install_nerc
install_ned
install_git rubenIzquierdo/dbpedia_ner
install_wsd



msg "Newsreader Dutch pipeline install complete" $green

echo "You can set your newsreader home to"
echo 
echo "${bold}export NEWSREADER_HOME=$DIR${reset}"
echo 
echo "Make sure that spotlight is running, i.e. call:"
echo "(cd \$NEWSREADER_HOME/tools/spotlight;  java -jar dbpedia-spotlight-0.7.jar nl http://localhost:9886/rest)"
echo 
echo "And call \$NEWSREADER_HOME/run_parser.sh < input > output"

