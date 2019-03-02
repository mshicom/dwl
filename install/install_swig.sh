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

function install_swig {
	# Getting the SWIG 3.0.12
	if [ ! -f swig-3.0.12.tar.gz ]; then
		wget http://downloads.sourceforge.net/swig/swig-3.0.12.tar.gz
	fi
	mkdir swig && tar zxf swig-3.0.12.tar.gz -C swig --strip-components 1
	#rm -rf swig-3.0.12.tar.gz
	cd swig
	./configure --prefix=$INSTALL_DEPS_PREFIX --without-clisp --without-maximum-compile-warnings
	make -j
	if [[ $OWNER == 'root' ]]; then
		sudo make -j install
	else
		make -j install
	fi
}

# Remove old folder (sanity procedure)
cd $DWL_DIR/thirdparty
if [[ $OWNER == 'root' ]]; then
	sudo rm -rf swig
else
	rm -rf swig
fi

if [ "$CURRENT_OS" == "OSX" ]; then
	install_swig
elif [ "$CURRENT_OS" == "UBUNTU" ]; then
	sudo apt-get install swig3.0
fi


