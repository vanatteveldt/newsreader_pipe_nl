#!/bin/bash

if [ -z ${NEWSREADER_HOME+x} ]; then 
  export NEWSREADER_HOME=`dirname "$(readlink -f "$0")"`
fi


export PYTHONPATH=$NEWSREADER_HOME
export ALPINO_HOME=$NEWSREADER_HOME/tools/Alpino

MDIR=$NEWSREADER_HOME/modules
TDIR=$NEWSREADER_HOME/tools

. $NEWSREADER_HOME/newsreader-env/bin/activate

java -jar $MDIR/ixa-pipe-tok/target/ixa-pipe-tok-1.8.4.jar tok -l nl |\
  $MDIR/morphosyntactic_parser_nl/run_parser.sh |\
  java -jar $MDIR/ixa-pipe-nerc/target/ixa-pipe-nerc-1.6.0-exec.jar tag -m $TDIR/nerc-models-1.5.4/nl/nl-6-class-clusters-sonar.bin |\
  java -jar $MDIR/ixa-pipe-ned/target/ixa-pipe-ned-1.1.4.jar -p 2060 |\
  python $MDIR/dbpedia_ner/dbpedia_ner.py |\
  python $MDIR/svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY


