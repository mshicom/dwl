#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Please pass the following arguments:"
	echo "    1. The current Operating System (OSX, UBUNTU)"
	echo "    2. The installation directory"
	echo "    3. The verbosity level, True or False"
	exit 1
fi

# Setting the arguments
CURRENT_OS=$1
INSTALL_DEPS_PREFIX=$2
VERBOSITY=""
if [[ $3 == False ]]; then
	VERBOSITY="-DCMAKE_RULE_MESSAGES:BOOL=OFF"
fi
DWL_DIR="$( cd "$(dirname "$(readlink -f $0)")" && cd ../ && pwd )" 
INFO=( $(stat -L -c "%a %G %U" $INSTALL_DEPS_PREFIX) )
OWNER=${INFO[2]}

# Remove old folder (sanity procedure)
cd $DWL_DIR/thirdparty
if [[ $OWNER == 'root' ]]; then
	sudo rm -rf colpack
else
	rm -rf colpack
fi

# Installing ColPAck
# Download ColPack
if [ ! -f ColPack-1.0.10.tar.gz ]; then
	wget -O ColPack-1.0.10.tar.gz https://github.com/CSCsw/ColPack/archive/v1.0.10.tar.gz
fi

# build ColPack
tar xfvz ColPack-1.0.10.tar.gz
#rm ColPack-1.0.10.tar.gz
mv ColPack-1.0.10 colpack
cd colpack
autoreconf -vif
./configure --prefix=$INSTALL_DEPS_PREFIX --libdir='${prefix}/lib'
make -j
if [[ $OWNER == 'root' ]]; then
	sudo make -j install
else
	make -j install
fi


# Remove old folder (sanity procedure)
cd $DWL_DIR/thirdparty
if [[ $OWNER == 'root' ]]; then
	sudo rm -rf adolc
else
	rm -rf adolc
fi

# Download ADOL-C
if [ ! -f ADOL-C-2.6.0.tgz ]; then
	wget http://www.coin-or.org/download/source/ADOL-C/ADOL-C-2.6.0.tgz
fi
tar xfvz ADOL-C-2.6.0.tgz
#rm ADOL-C-2.6.0.tgz
mv ADOL-C-2.6.0 adolc
cd adolc
./update_versions.sh
./configure --enable-sparse --with-colpack=$INSTALL_DEPS_PREFIX --prefix=$INSTALL_DEPS_PREFIX
make -j
if [[ $OWNER == 'root' ]]; then
	sudo make -j install
else
	make -j install
fi


# Remove old folder (sanity procedure)
cd $DWL_DIR/thirdparty
sudo rm -rf pyadolc

# Downloading pyadolc
if [ ! -f pyadolc.zip ]; then
	wget -O pyadolc.zip https://github.com/robot-locomotion/pyadolc/archive/master.zip
fi
unzip pyadolc.zip -d pyadolc # && rm master.zip
cd pyadolc
mv pyadolc-master/* . && rm -rf pyadolc-master
sed -i 's/raw_input/#raw_input/' setup.py # Do not asking for checking

export BOOST_DIR=$INSTALL_DEPS_PREFIX
export ADOLC_DIR=$INSTALL_DEPS_PREFIX
export COLPACK_DIR=$INSTALL_DEPS_PREFIX
python setup.py build
sudo python setup.py install
