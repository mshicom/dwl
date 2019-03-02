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


function install_urdfdom_headers
{
	# Remove old folder (sanity procedure)
	cd $DWL_DIR/thirdparty
	sudo rm -rf urdf_headers

	if [ "$CURRENT_OS" == "OSX" ]; then
		# Getting urdfdom_headers 0.2.3
		curl -L "https://github.com/ros/urdfdom_headers/archive/0.2.3.tar.gz" | tar xz
		mv urdfdom_headers-*/ urdfdom_headers
		cd urdfdom_headers
		mkdir -p build
		cd build
		cmake -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
		make -j
		sudo make -j install
	elif [ "$CURRENT_OS" == "UBUNTU" ]; then
		# Getting urdfdom_headers 0.2.3
		if [ ! -f urdfdom_headers_0.2.3.tar.gz ]; then
			wget -O urdfdom_headers_0.2.3.tar.gz https://github.com/ros/urdfdom_headers/archive/0.2.3.tar.gz 
		fi

		mkdir urdfdom_headers && tar zxf urdfdom_headers_0.2.3.tar.gz -C urdfdom_headers --strip-components 1
		#rm -rf 0.2.3.tar.gz
		cd urdfdom_headers
		mkdir -p build
		cd build
		cmake -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
		make -j
		sudo make -j install
	fi
}


function install_console_bridge
{
	# Remove old folder (sanity procedure)
	cd $DWL_DIR/thirdparty
	sudo rm -rf console_bridge

	if [ "$CURRENT_OS" == "OSX" ]; then
		# Getting console_bridge 0.2.7
		curl -L "https://github.com/ros/console_bridge/archive/0.2.7.tar.gz" | tar xz
		mv console_bridge-*/ console_bridge
		cd console_bridge
		mkdir -p build
		cd build
		brew install boost
		cmake -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
		make -j
		sudo make -j install
	elif [ "$CURRENT_OS" == "UBUNTU" ]; then
		# Getting console_bridge 0.2.7
		if [ ! -f console_bridge_0.2.7.tar.gz  ]; then
			wget -O console_bridge_0.2.7.tar.gz https://github.com/ros/console_bridge/archive/0.2.7.tar.gz 
		fi		
		mkdir console_bridge && tar zxf console_bridge_0.2.7.tar.gz -C console_bridge --strip-components 1
		#rm -rf 0.2.7.tar.gz
		cd console_bridge
		mkdir -p build
		cd build
		cmake -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
		make -j
		sudo make -j install
	fi
}


function install_urdfdom
{
	# Remove old folder (sanity procedure)
	cd $DWL_DIR/thirdparty
	sudo rm -rf urdfdom

	if [ "$CURRENT_OS" == "OSX" ]; then
		# Getting console_bridge 0.2.10
		curl -L "https://github.com/ros/urdfdom/archive/0.2.10.tar.gz" | tar xz
		mv urdfdom-*/ urdfdom
		cd urdfdom
		mkdir -p build
		cd build
		brew install tinyxml
		cmake -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
		make -j
		sudo make -j install
	elif [ "$CURRENT_OS" == "UBUNTU" ]; then
		# Getting console_bridge 0.2.10
		if [ ! -f urdfdom_0.2.10.tar.gz ]; then
			wget -O urdfdom_0.2.10.tar.gz https://github.com/ros/urdfdom/archive/0.2.10.tar.gz
		fi

		mkdir urdfdom && tar zxf urdfdom_0.2.10.tar.gz -C urdfdom --strip-components 1
		#rm -rf 0.2.10.tar.gz
		cd urdfdom
		mkdir -p build
		cd build
		cmake -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
		make -j
		sudo make -j install
	fi
}



install_urdfdom_headers
install_urdfdom
install_console_bridge

# Remove old folder (sanity procedure)
cd $DWL_DIR/thirdparty
if [[ $OWNER == 'root' ]]; then
	sudo rm -rf rbdl
else
	rm -rf rbdl
fi

export PKG_CONFIG_PATH=${INSTALL_DEPS_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH

if [ "$CURRENT_OS" == "OSX" ]; then
	curl -L "https://bitbucket.org/rbdl/rbdl/get/v2.4.0.zip" > v2.4.0.zip
	unzip v2.4.0.zip
	#rm v2.4.0.zip
	mv rbdl-*/ rbdl
	cd rbdl
	mkdir -p build
	cd build
	cmake -D RBDL_BUILD_ADDON_URDFREADER:bool=ON -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
	make -j
	if [[ $OWNER == 'root' ]]; then
		sudo make -j install
	else
		make -j install
	fi
elif [ "$CURRENT_OS" == "UBUNTU" ]; then
	# sudo apt-get install -qqy liburdfdom-headers-dev liburdfdom-dev
	
	# Getting RBDL 2.4.0
	if [ ! -f rbdl_v2.4.0.zip ]; then
		wget -O rbdl_v2.4.0.zip https://bitbucket.org/rbdl/rbdl/get/v2.4.0.zip
	fi

	unzip rbdl_v2.4.0.zip 
	#rm rbdl_v2.4.0.zip 
	mv rbdl-rbdl-* rbdl
	cd rbdl
	mkdir -p build
	cd build
	cmake -D RBDL_BUILD_ADDON_URDFREADER:bool=ON -D CMAKE_INSTALL_LIBDIR:string=lib -DCMAKE_INSTALL_PREFIX=$INSTALL_DEPS_PREFIX $VERBOSITY ../
	make -j
	if [[ $OWNER == 'root' ]]; then
		sudo make -j install
	else
		make -j install
	fi
fi
