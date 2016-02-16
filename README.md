Installation

Install prerequisites

apt-get install libboost-filesystem-dev libtk8.5 maven git

Clone the repository

git clone http://github.com/vanatteveldt/newsreader_pipe_nl

Run the install script

bash newsreader_pipe_nl/install.sh

Test the parser

echo "Dit is een test" | newsreader_pipe_nl/run_parser.sh
