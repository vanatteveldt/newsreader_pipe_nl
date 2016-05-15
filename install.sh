##################################################
# FUNCTIONS FOR NON-TRIVIAL MODULE INSTALLATION  #
##################################################

function install_ixa_pipe_ned {
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

function install_svm_wsd {
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


function install_opinion_miner {
    # don't use install_me.sh to avoid password prompt 
    install_git rubenIzquierdo/opinion_miner_deluxePP
    CRFDIR=$TDIR/CRF++-0.58
    if [ ! -d $CRFDIR ]; then
	msg "Installing CRF++ into $CRFDIR"
	tar -xzf $MDIR/opinion_miner_deluxePP/crf_lib/CRF++-0.58.tar.gz -C $TDIR
	cd $CRFDIR
	./configure
	make
	echo "PATH_TO_CRF_TEST='$CRFDIR/crf_test'" > $MDIR/opinion_miner_deluxePP/path_crf.py
    fi
    MODELDIR=$TDIR/opinion_miner_models
    if [ ! -d $MODELDIR ]; then
	if [ -z ${CLTL_PASSWORD+x} ]; then
	    msg "${red}\$CLTL_PASSWORD not set!${reset}" $red
	    exit 1
	fi
	mkdir -p $MODELDIR
	curl --user "cltl:$CLTL_PASSWORD" kyoto.let.vu.nl/~izquierdo/models_opinion_miner_deluxePP.tgz | tar -xz -C $MODELDIR
    fi
}

#####################
#        MAIN       #
#####################

set -e 
export NEWSREADER_HOME=`dirname "$(readlink -f "$0")"`
MDIR=$NEWSREADER_HOME/modules
TDIR=$NEWSREADER_HOME/tools
. $NEWSREADER_HOME/functions.sh

msg "Installing newsreader into $NEWSREADER_HOME"
mkdir -p $TDIR
for REQ in java mvn git timbl; do
    if ! type -p $REQ > /dev/null ; then
	msg "${red}Error: $REQ not installed!${reset}" $red
	echo "You can try 'sudo apt-get install $REQ'"
	exit 1
    fi
done

# Newsreader pipeline modules:
install_mvn ixa-ehu/ixa-pipe-tok
install_git vanatteveldt/morphosyntactic_parser_nl
install_mvn ixa-ehu/ixa-pipe-nerc
install_ixa_pipe_ned
install_git rubenIzquierdo/dbpedia_ner
install_svm_wsd
install_ixa_pipe_time
install_sh cltl/OntoTagger
install_git vanatteveldt/vua-srl-nl -b patch-1
install_git newsreader/vua-srl-dutch-nominal-events
install_sh cltl/EventCoreference 
install_opinion_miner 
install_git vanatteveldt/multilingual_factuality

# External downloads:
# NERC models
# (this is nl only; can download original from http://ixa2.si.ehu.es/ixa-pipes/models/nerc-models-1.5.4.tgz)
install_tgz $TDIR/nerc-models-1.5.4 http://i.amcat.nl/nerc-models-1.5.4-nl.tgz
# Alpino
install_tgz $TDIR/Alpino http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/Alpino-x86_64-Linux-glibc-2.19-20908-sicstus.tar.gz 

VENV="$NEWSREADER_HOME/newsreader-env"
if [ ! -d "$VENV" ]; then
  msg "Setting up python virtual environment in $VENV"
  virtualenv "$VENV"
  "$VENV/bin/pip" install KafNafParserPy
fi

msg "Newsreader Dutch pipeline install complete" $green

echo "You can set your newsreader home to"
echo 
echo "${bold}export NEWSREADER_HOME=$NEWSREADER_HOME${reset}"
echo 
echo "Make sure that spotlight is running, i.e. call:"
echo "(cd \$NEWSREADER_HOME/tools/spotlight;  java -jar dbpedia-spotlight-0.7.jar nl http://localhost:2060/rest)"
echo 
echo "And call \$NEWSREADER_HOME/run_parser.sh < input > output"

