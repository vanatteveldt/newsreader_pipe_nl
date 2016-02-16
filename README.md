Installation

Install prerequisites (code given for ubuntu):

```{sh}
apt-get install libboost-filesystem-dev libtk8.5 maven git
```

Clone this repository

```{sh}
git clone http://github.com/vanatteveldt/newsreader_pipe_nl
```

Run the install script

```{sh}
bash newsreader_pipe_nl/install.sh
```

Test the parser

```{sh}
echo "Dit is een test" | newsreader_pipe_nl/run_parser.sh
```

Note: on recent ubuntu versions Alpino needs an older version of the libboost system and filesystem packages.

```{sh}
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost1.54-dev_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-system1.54.0_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-system1.54-dev_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-filesystem1.54.0_1.54.0-4ubuntu3_amd64.deb
wget http://nl.archive.ubuntu.com/ubuntu/pool/main/b/boost1.54/libboost-filesystem1.54-dev_1.54.0-4ubuntu3_amd64.deb

sudo dpkg -i libboost1.54-dev_1.54.0-4ubuntu3_amd64.deb libboost-filesystem1.54.0_1.54.0-4ubuntu3_amd64.deb libboost-filesystem1.54-dev_1.54.0-4ubuntu3_amd64.deb libboost-system1.54.0_1.54.0-4ubuntu3_amd64.deb libboost-system1.54-dev_1.54.0-4ubuntu3_amd64.deb
```