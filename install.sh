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

function install_sh {
    install_git "$1"
    if [ $WAS_INSTALLED = 1 ]; then
	bash install.sh
    fi
}

function install_svm_light {
  DIR=$TDIR/svm_light
  if [ ! -d $DIR ]; then
      mkdir -p $DIR
      curl -L http://download.joachims.org/svm_light/current/svm_light_linux64.tar.gz | tar xz -C $DIR
  fi
}

function install_crfsuite {
    if [ ! -d "$TDIR/crfsuite-0.12" ]; then
	curl -L https://github.com/downloads/chokkan/crfsuite/crfsuite-0.12-x86_64.tar.gz | tar xz -C $TDIR
    fi
}

function install_opinion_miner {
  install_svm_light 
  install_crfsuite 
  install_git cltl/opinion_miner_deluxe
  #TODO: create config file and test
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
install_ixa_pipe_ned
install_git rubenIzquierdo/dbpedia_ner
install_svm_wsd
install_ixa_pipe_time
install_sh cltl/OntoTagger
install_git vanatteveldt/vua-srl-nl -b patch-1
install_git newsreader/vua-srl-dutch-nominal-events
# install_sh cltl/EventCoreference # see https://github.com/cltl/EventCoreference/issues/1
install_opinion_miner

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

