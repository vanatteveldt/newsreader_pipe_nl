#!/bin/bash

if [ -z ${NEWSREADER_HOME+x} ]; then 
  export NEWSREADER_HOME=`dirname "$(readlink -f "$0")"`
fi


export PYTHONPATH=$NEWSREADER_HOME
export ALPINO_HOME=$NEWSREADER_HOME/tools/Alpino

MDIR=$NEWSREADER_HOME/modules
TDIR=$NEWSREADER_HOME/tools

. $NEWSREADER_HOME/newsreader-env/bin/activate

function parse {
    java -jar $MDIR/ixa-pipe-tok/target/ixa-pipe-tok-1.8.4.jar tok -l nl |\
      $MDIR/morphosyntactic_parser_nl/run_parser.sh
}

function annotate {
  java -jar $MDIR/ixa-pipe-nerc/target/ixa-pipe-nerc-1.6.0-exec.jar tag -m $TDIR/nerc-models-1.5.4/nl/nl-6-class-clusters-sonar.bin |\
  java -jar $MDIR/ixa-pipe-ned/target/ixa-pipe-ned-1.1.4.jar -p 2060 |\
  python $MDIR/dbpedia_ner/dbpedia_ner.py |\
  python $MDIR/svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY |\
  java -jar $MDIR/ixa-pipe-time/target/ixa.pipe.time.jar -m $MDIR/ixa-pipe-time/lib/alpino-to-treetagger.csv -c  $MDIR/ixa-pipe-time/lib/config.props |\
  bash $MDIR/OntoTagger/scripts/predicate-matrix-tagger.sh |\
  bash $MDIR/vua-srl-nl/run.sh |\
  bash $MDIR/OntoTagger/scripts/srl-framenet-tagger.sh |\
  bash $MDIR/OntoTagger/scripts/nominal-events.sh |\
  python $MDIR/vua-srl-dutch-nominal-events/vua-srl-dutch-additional-roles.py |\
  bash $MDIR/EventCoreference/scripts/event-coreference-nl.sh |\
  python $MDIR/opinion_miner_deluxePP/tag_file.py -f $TDIR/opinion_miner_models/models/models_news_nl/ -polarity |\
  python $MDIR/multilingual_factuality/feature_extractor/rule_based_factuality.py |\
  cat
}

WHAT=${1:-all}

if [ $WHAT = "all" ]; then
    parse | annotate
elif [ $WHAT = "parse" ]; then
    parse
elif [ $WHAT = "annotate" ]; then
    annotate
else 
    echo "Unknown argument: $WHAT"
    exit 1
fi
