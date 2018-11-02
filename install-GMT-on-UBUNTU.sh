#!/bin/bash
#
#Install Generic Mapping Tool (GMT) on Ubuntu
#
#updated version of https://zanonxyz.wordpress.com/2015/03/23/install-gmt-generic-mapping-tool-on-ubuntu/
#
#Based on http://gmt.soest.hawaii.edu/projects/gmt/wiki/BuildingGMT
#
#
#Tested on Nov 2018 with:
#Ubuntu 18.04 Bionic
#GMT 5.4.4 


#-------------------------------

#Replace the 'install_dir' path with the location where you want to install GMT

install_dir='/home/marco/Documents/GMT'

gshhg="gshhg-gmt-2.3.7"

dcw="dcw-gmt-1.1.4"

#Coastlines, rivers, political boundaries (GSHHG) 
#and country polygons (DCW) are downloaded separately from GMT.
#
#Update 'gshhg' and 'dcw' above with the versions you want to download and install.
#check ftp://ftp.soest.hawaii.edu/dcw/ and ftp://ftp.soest.hawaii.edu/gshhg/
#to ge the correct file names

#It shouldn`t be needed to change anything below this point.
#-------------------------------

#create install directory if it doesn´t exist
mkdir -p "$install_dir"

cd "$install_dir"

#install some necessary packages
sudo apt-get install subversion build-essential cmake libgdal-dev libcurl4-gnutls-dev libnetcdf-dev libfftw3-dev libpcre3-dev liblapack-dev libblas-dev

#http://gmt.soest.hawaii.edu/projects/gmt/wiki/BuildingGMT suggests to use libgdal1-dev.
#At the moment it appears that this package is not available for Ubuntu 10.04
#I replaced it with libgdal-dev and everything appears to work fine.

#download the most recent GMT vesion from github
#all install files are downloaded into [your install directory]/GMT_install_files

sudo apt install git

git clone https://github.com/GenericMappingTools/gmt.git GMT_install_files

cd  GMT_install_files

#download and unzip coastlines, rivers, political boundaries and country polygons
 
wget ftp://ftp.soest.hawaii.edu/gshhg/"$gshhg".tar.gz
 
wget ftp://ftp.soest.hawaii.edu/dcw/"$dcw".tar.gz

for i in *.tar.gz; do tar -xvzf $i; done


#produce the necessary ConfigUser.cmake from ConfigUserTemplate.cmake

cp ./cmake/ConfigUserTemplate.cmake ./cmake/ConfigUser.cmake

#Inside ConfigUser.cmake, activate (remove #) lines
#set (CMAKE_INSTALL_PREFIX “prefix_path”)
#set (GSHHG_ROOT “gshhg_path”)
#set (DCW_ROOT “dcw-gmt_path”)
#set (COPY_GSHHG TRUE)
#set (COPY_DCW TRUE)
#
#Then replace “prefix_path” with the path to the installation folder.
#Replace “gshhg_path” with the path to the GSHHG unzipped package.
#Replace “dcw-gmt_path” with the path to the DCW unzipped package.
 
sed -i 's|#set (CMAKE_INSTALL_PREFIX "prefix_path")|set (CMAKE_INSTALL_PREFIX '"$install_dir"')|g' "$install_dir"/GMT_install_files/cmake/ConfigUser.cmake

sed -i 's|#set (GSHHG_ROOT "gshhg_path")|set (GSHHG_ROOT '"$install_dir\/GMT_install_files\/$gshhg"')|g' "$install_dir"/GMT_install_files/cmake/ConfigUser.cmake

sed -i 's|#set (DCW_ROOT "dcw-gmt_path")|set (DCW_ROOT '"$install_dir\/GMT_install_files\/$dcw"')|g' "$install_dir"/GMT_install_files/cmake/ConfigUser.cmake
  
sed -i 's|#set (COPY_GSHHG TRUE)|set (COPY_GSHHG TRUE)|g' "$install_dir"/GMT_install_files/cmake/ConfigUser.cmake
 
sed -i 's|#set (COPY_DCW TRUE)|set (COPY_DCW TRUE)|g' "$install_dir"/GMT_install_files/cmake/ConfigUser.cmake

#Create a build directory, move into it and install GMT

mkdir build
cd build
cmake ..
make
sudo make install

#Add the path to GMT to ~/.profile and reload it for the changes to take effect

echo "export PATH=$PATH:$install_dir/bin" >> ~/.profile

. ~/.profile


#test to make sure everything is working

cd $install_dir
gmt pscoast -R-30/-10/62/68 -Jm1c -B5 -Ggrey -Df>iceland.ps
ps2pdf $install_dir/iceland.ps