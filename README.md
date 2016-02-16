# Dutch newsreader pipeline installation script

This is a convenience wrapper around the [Dutch newsreader pipeline](http://newsreader-project.eu). 
It installs the needed packages from github and compiles them as needed, 
and provides convenient shell scripts for running (part of) the pipeline.

Currently, this will install the following modules and tools:

Newsreader modules:
- https://github.com/ixa-ehu/ixa-pipe-tok 
- https://github.com/cltl/morphosyntactic_parser_nl

Tools:
- [Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/) (Dutch syntax parser)
- [KafNafParserPy](https://github.com/cltl/KafNafParserPy), a python script for parsing KAF/NAF formatted output

# Installation

## Prerequisites

First, you need to install some system-wide libraries. On ubuntu, the following `apt` command should do the trick:

```{sh}
sudo apt-get install libboost-filesystem-dev libtk8.5 maven git
```

(Note that you need java as well, I would generally recommend installing sun java:

```{sh}
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer 
```

## Installing the Dutch newsreader pipeline

Clone this repository and run the install script:

```{sh}
git clone http://github.com/vanatteveldt/newsreader_pipe_nl
bash newsreader_pipe_nl/install.sh
```

Now, test the parser. It should produce XML output if it works

```{sh}
echo "Dit is een test" | newsreader_pipe_nl/run_parser.sh
```

## Alpino and libboost

Note: on recent ubuntu versions Alpino needs an older version of the libboost system and filesystem packages.
The following commands get the needed libraries and install them using dpkg, but this will conflict with existing libboost libraries. Hopefully, this will be resolved in a (near-)future new release of Alpino.

```{sh}
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost1.54-dev_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-system1.54.0_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-system1.54-dev_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-filesystem1.54.0_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-filesystem1.54-dev_1.54.0-4ubuntu3_amd64.deb

sudo dpkg -i libboost1.54-dev_1.54.0-4ubuntu3_amd64.deb libboost-filesystem1.54.0_1.54.0-4ubuntu3_amd64.deb libboost-filesystem1.54-dev_1.54.0-4ubuntu3_amd64.deb libboost-system1.54.0_1.54.0-4ubuntu3_amd64.deb libboost-system1.54-dev_1.54.0-4ubuntu3_amd64.deb
```
