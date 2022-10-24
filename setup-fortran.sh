#!/usr/bin/env bash

set -ex

install_gcc_brew()
{
  brew install gcc@${version}
  ln -fs /usr/local/bin/gfortran-${version} /usr/local/bin/gfortran
  ln -fs /usr/local/bin/gcc-${version} /usr/local/bin/gcc
  ln -fs /usr/local/bin/g++-${version} /usr/local/bin/g++

  for (( i=12; i>4; i-- ))
  do
    gcc_lib_path="/usr/local/opt/gcc/lib/gcc/$i"
    if [ -d $gcc_lib_path ]; then
      echo "found $gcc_lib_path"
      for (( j=$i; j>4; j-- ))
      do
        ln -fs /usr/local/opt/gcc/lib/gcc/$i /usr/local/opt/gcc/lib/gcc/$j
      done
      break
    fi
  done

  export FC="gfortran"
  export CC="gcc"
  export CXX="g++"
}

install_gcc_apt()
{
  sudo add-apt-repository ppa:ubuntu-toolchain-r/test
  sudo apt-get update
  sudo apt-get install -y gcc-${version} gfortran-${version}
  sudo update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-${version} 100 \
    --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-${version} \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-${version}

  export FC="gfortran"
  export CC="gcc"
  export CXX="g++"
}

install_gcc_choco()
{
  case $version in
    12)
      choco install mingw --version 12.2.0 --force
      ;;
    11)
      choco install mingw --version 11.2.0 --force
      ;;
    10)
      choco install mingw --version 10.3.0 --force
      ;;
    9)
      choco install mingw --version 9.4.0 --force
      ;;
    8)
      choco install mingw --version 8.5.0 --force
      ;;
    *)
      echo "Unsupported version: $version (choose 8-12)"
      exit 1
      ;;
  esac

  export FC="gfortran"
  export CC="gcc"
  export CXX="g++"
}

install_gcc_winlibs()
{
  repo="https://github.com/brechtsanders/winlibs_mingw/releases/download"
  case $version in
    12)
      tag="12.2.0-14.0.6-10.0.0-ucrt-r2"
      zip="winlibs-x86_64-posix-seh-gcc-12.2.0-mingw-w64ucrt-10.0.0-r2.zip"
      ;;
    11)
      tag="11.2.0-12.0.1-9.0.0-r1"
      zip="winlibs-x86_64-posix-seh-gcc-11.2.0-mingw-w64-9.0.0-r1.zip"
      ;;
    10)
      tag="10.3.0-12.0.0-9.0.0-r2"
      zip="winlibs-x86_64-posix-seh-gcc-10.3.0-mingw-w64-9.0.0-r2.zip"
      ;;
    9)
      tag="9.4.0-9.0.0-r1"
      zip="winlibs-x86_64-posix-seh-gcc-9.4.0-mingw-w64-9.0.0-r1.zip"
      ;;
    8)
      tag="8.5.0-9.0.0-r1"
      zip="winlibs-x86_64-posix-seh-gcc-8.5.0-mingw-w64-9.0.0-r1.zip"
      ;;
    *)
      echo "Unsupported version: $version (choose 8-12)"
      exit 1
      ;;
  esac

  if command -v curl > /dev/null 2>&1; then
    fetch="curl -L"
  elif command -v wget > /dev/null 2>&1; then
    FETCH="wget -O -"
  else
    echo "No download mechanism found. Install curl or wget first."
    exit 1
  fi

  $fetch "$repo/$tag/$zip" > winlibs_mingw.zip

  unzip -qo winlibs_mingw.zip "mingw64/bin/*" -d /

  export FC="gfortran"
  export CC="gcc"
  export CXX="g++"

  default_gfc="/c/ProgramData/Chocolatey/bin/gfortran"
  default_gcc="/c/ProgramData/Chocolatey/bin/gcc"
  default_gcx="/c/ProgramData/Chocolatey/bin/g++"

  [ -f $default_gfc ] && mv $default_gfc "$RUNNER_TEMP/gfortran"
  [ -f $default_gcc ] && mv $default_gcc "$RUNNER_TEMP/gcc"
  [ -f $default_gcx ] && mv $default_gcx "$RUNNER_TEMP/g++"

  default_gfc="/c/Strawberry/c/bin/gfortran"
  default_gcc="/c/Strawberry/c/bin/gcc"
  default_gcx="/c/Strawberry/c/bin/g++"

  [ -f $default_gfc ] && mv $default_gfc "$RUNNER_TEMP/gfortran"
  [ -f $default_gcc ] && mv $default_gcc "$RUNNER_TEMP/gcc"
  [ -f $default_gcx ] && mv $default_gcx "$RUNNER_TEMP/g++"
}
