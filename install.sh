##################################################
# FUNCTIONS FOR NON-TRIVIAL MODULE INSTALLATION  #
##################################################

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

function install_ixa_pipe_time {
    install_git ixa-ehu/ixa-pipe-time
    if [ $WAS_INSTALLED = 1 ]; then
	wget -P lib https://raw.githubusercontent.com/HeidelTime/heideltime/master/conf/config.props
	wget -P lib http://ixa2.si.ehu.es/~jibalari/jvntextpro-2.0.jar
	wget https://raw.githubusercontent.com/carchrae/install-to-project-repo/master/install-to-project-repo.py -O /tmp/install.py
	python /tmp/install.py
	mvn clean install
    fi
}



#####################
#        MAIN       #
#####################

set -e 
. functions.sh

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

# Newsreader pipeline modules:
install_mvn ixa-ehu/ixa-pipe-tok
install_git cltl/morphosyntactic_parser_nl
install_mvn ixa-ehu/ixa-pipe-nerc
install_ned
install_git rubenIzquierdo/dbpedia_ner
install_wsd
install_ixa_pipe_time
install_git cltl/vua-resources
install_mvn cltl/OntoTagger

# External downloads:
# NERC models
# (this is nl only; can download original from http://ixa2.si.ehu.es/ixa-pipes/models/nerc-models-1.5.4.tgz)
install_tgz $TDIR/nerc-models-1.5.4 http://i.amcat.nl/nerc-models-1.5.4-nl.tgz
# Alpino
install_tgz $TDIR/Alpino http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/Alpino-x86_64-Linux-glibc-2.19-20908-sicstus.tar.gz 


msg "Newsreader Dutch pipeline install complete" $green

echo "You can set your newsreader home to"
echo 
echo "${bold}export NEWSREADER_HOME=$DIR${reset}"
echo 
echo "Make sure that spotlight is running, i.e. call:"
echo "(cd \$NEWSREADER_HOME/tools/spotlight;  java -jar dbpedia-spotlight-0.7.jar nl http://localhost:2060/rest)"
echo 
echo "And call \$NEWSREADER_HOME/run_parser.sh < input > output"

