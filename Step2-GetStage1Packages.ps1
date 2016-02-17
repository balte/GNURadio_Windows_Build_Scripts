# GNURadio Windows Build System
# Geof Nieboer

# script setup
$ErrorActionPreference = "Stop"

# setup helper functions
$mypath =  Split-Path $script:MyInvocation.MyCommand.Path
Import-Module -Name $mypath\Functions -Force
$Config = Import-LocalizedData -BaseDirectory $mypath -FileName ConfigInfo.psd1 

# path setup
$root = $env:grwinbuildroot 
if (!$root) {$root = "C:\gr-build"}
cd $root
set-alias sz "$root\bin\7za.exe"  
Add-Type -assembly "system.io.compression.filesystem"

# Check for binary dependencies
if (-not (test-path "$root\bin\7za.exe")) {throw "7-zip (7za.exe) needed in bin folder"} 

# check for git/tar
if (-not (test-path "$env:ProgramFiles\Git\usr\bin\tar.exe")) {throw "Git For Windows must be installed"} 
set-alias tar "$env:ProgramFiles\Git\usr\bin\tar.exe"  

break

# Retrieve packages needed for Stage 1
cd $root/src-stage1-dependencies

#libzmq
getPackage https://github.com/zeromq/libzmq.git

# libpng
getPackage ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.21.tar.xz
getPatch libpng-1.6.21-vs2015.7z libpng-1.6.21\projects\vstudio-vs2015

# SDL 1.2.15
getPackage  https://libsdl.org/release/SDL-1.2.15.zip
getPatch sdl-1.2.15-vs2015.7z SDL-1.2.15\VisualC

# portaudio v19
GetPackage http://portaudio.com/archives/pa_stable_v19_20140130.tgz
GetPatch portaudio_vs2015.7z portaudio/build/msvc
# asio SDK for portaudio
GetPatch asiosdk2.3.7z portaudio/src/hostapi/asio


# folder will already exist
if (!(Test-Path $root/packages/portaudio/asiosdk2.3.zip)) {
	cd $root/packages/portaudio
	wget http://www.steinberg.net/sdk_downloads/asiosdk2.3.zip -OutFile asiosdk2.3.zip
} else {
	"ASIO SDK already present"
}
if (!(Test-Path $root/src-stage1-dependencies/portaudio/src/hostapi/asio/asiosdk)) {
	$archive = "$root/packages/portaudio/asiosdk2.3.zip"
	$destination = "$root/src-stage1-dependencies/portaudio/src/hostapi/asio"
	[io.compression.zipfile]::ExtractToDirectory($archive, $destination)
	cd $destination
	ren asiosdk2.3 asiosdk
}

# cppunit 1.12.1
GetPackage http://www.gcndevelopment.com/gnuradio/downloads/sources/cppunit-1.12.1.7z

# fftw3.3.5
GetPackage http://www.gcndevelopment.com/gnuradio/downloads/sources/fftw-3.3.5.7z

#python
GetPackage http://www.gcndevelopment.com/gnuradio/downloads/libraries/python27/python2710-x64-Source.7z
GetPatch python-pcbuild.vc14.zip python27/Python-2.7.10

# zlib
# note: libpng is expecting zlib to be in a folder with the -1.2.8 version of the name
GetPackage https://github.com/gnieboer/zlib.git zlib-1.2.8

#libsodium
GetPackage https://github.com/gnieboer/libsodium.git 

#GSL
GetPackage http://www.gcndevelopment.com/gnuradio/downloads/sources/gsl-1.16.7z
GetPatch gsl-1.16.build.vc14.zip gsl-1.16

#openssl
$openssl_version = $Config.VersionInfo.openssl
GetPackage ftp://ftp.openssl.org/source/openssl-$openssl_version.tar.gz openssl
GetPatch openssl-vs14.zip openssl
mkdir $root\src-stage1-dependencies\openssl\build\intermediate\x64\Debug
mkdir $root\src-stage1-dependencies\openssl\build\intermediate\x64\Release
mkdir $root\src-stage1-dependencies\openssl\build\intermediate\x64\DebugDLL
mkdir $root\src-stage1-dependencies\openssl\build\intermediate\x64\ReleaseDLL
mkdir $root\src-stage1-dependencies\openssl\build\intermediate\x64\Release-AVX2
mkdir $root\src-stage1-dependencies\openssl\build\intermediate\x64\ReleaseDLL-AVX2

# Qt
GetPackage http://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz Qt4

# Boost
GetPackage http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.zip boost

# Qwt
$url = "http://downloads.sourceforge.net/project/qwt/qwt/" + $Config.VersionInfo.qwt + "/qwt-" + $Config.VersionInfo.qwt + ".zip"
GetPackage $url 
$dest = "qwt-" + $Config.VersionInfo.qwt
GetPatch qwtconfig.7z $dest

# cleanup

# return to original directory
cd $root/scripts