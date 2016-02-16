#!/bin/bash

if [ -z ${NEWSREADER_HOME+x} ]; then 
  export NEWSREADER_HOME=`dirname "$(readlink -f "$0")"`
fi


export PYTHONPATH=$NEWSREADER_HOME
export ALPINO_HOME=$NEWSREADER_HOME/tools/Alpino

MDIR=$NEWSREADER_HOME/modules

. $NEWSREADER_HOME/newsreader-env/bin/activate

java -jar $MDIR/ixa-pipe-tok/target/ixa-pipe-tok-1.8.4.jar tok -l nl |\
  $MDIR/morphosyntactic_parser_nl/run_parser.sh  
