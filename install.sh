set -e 
bold=`tput bold`
em=`tput bold;tput setaf 4`
green=`tput bold;tput setaf 2`
red=`tput bold;tput setaf 1`
reset=`tput sgr0`


DIR=`dirname "$(readlink -f "$0")"`

GIT_MODULES="
https://github.com/ixa-ehu/ixa-pipe-tok 
https://github.com/cltl/morphosyntactic_parser_nl
"



echo -e "${em}***** Installing Dutch newsreader pipeline into $DIR *****${reset}"


echo -e "${em}***** Checking prerequisites *****${reset}"

for REQ in "java mvn git"; do
    if ! type -p $REQ; then
	echo "${red}$REQ not installed!${reset}"
	exit 1
    fi
done

echo -e "\n${em}*** Cloning git repositories of newsreader modules ***${reset}\n"
for REPO in $GIT_MODULES
do
    SUBDIR="$DIR/modules/`basename $REPO`"
    if [ ! -d "$SUBDIR" ]; then
	echo -e "${em}** cloning $REPO into $SUBDIR${reset}"
	git clone $REPO $SUBDIR
    else
	echo "${em}** updating $SUBDIR${reset}"
	git -C $SUBDIR pull
    fi
done

echo -e "\n${em}*** Compiling ixa-pipe-tok***${reset}"
cd $DIR/modules/ixa-pipe-tok
mvn clean package

mkdir -p $DIR/tools
if [ ! -d "$DIR/tools/Alpino" ]; then
  echo -e "\n${em}*** Installing Alpino ***${reset}"
  curl http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/Alpino-x86_64-Linux-glibc-2.19-20908-sicstus.tar.gz | tar xz -C $DIR/tools
fi

if [ ! -d "$DIR/newsreader-env" ]; then
  echo -e "\n${em}*** Setting up virtual environment ***${reset}\n" 
  virtualenv $DIR/newsreader-env
  $DIR/newsreader-env/bin/pip install KafNafParserPy
fi

echo -e "\n${green}Newsreader Dutch pipeline install complete.${reset}\n"
echo "You can set your newsreader home to"
echo 
echo "${bold}export NEWSREADER_HOME=$DIR${reset}"
echo
echo "And call \$NEWSREADER_HOME/run_parser < input > output"

