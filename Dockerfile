FROM ubuntu:latest
MAINTAINER Sven Koschnicke <sven@koschnicke.de>

# workaround problem with upstart not running
# see https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# update system
RUN echo "deb http://de.archive.ubuntu.com/ubuntu precise main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://de.archive.ubuntu.com/ubuntu precise-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://de.archive.ubuntu.com/ubuntu precise-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://de.archive.ubuntu.com/ubuntu precise-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN apt-get update
#RUN apt-get -y upgrade

# install required packages (we need GHC to build GHC from source)
RUN apt-get -y install ghc wget bzip2 build-essential zlib1g-dev libncurses5-dev libgl1-mesa-dev libglc-dev freeglut3-dev libedit-dev libglw1-mesa libglw1-mesa-dev

# Get GHC (version needed to build Haskell Platform)
RUN wget http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-src.tar.bz2
RUN tar xjf /ghc-7.6.3-src.tar.bz2

# extract and build GHC
WORKDIR /ghc-7.6.3
RUN ./configure
RUN make
RUN make install

WORKDIR /

# Get Haskell Platform
RUN wget http://lambda.haskell.org/platform/download/2013.2.0.0/haskell-platform-2013.2.0.0.tar.gz
 
# extract and build ghc
RUN tar xzf /haskell-platform-2013.2.0.0.tar.gz
WORKDIR /haskell-platform-2013.2.0.0
RUN ./configure
RUN make
RUN make install

WORKDIR /
 
# setup paths for cabal binaries
RUN echo "export PATH=`pwd`/bin:$HOME/.cabal/bin:$PATH" >> ~/.bashrc

# update cabal 
RUN cabal update

# delete installation files
RUN rm -rf /haskell-platform-2013.2.0.0
RUN rm -rf /ghc-7.6.3
RUN rm /ghc-7.6.3-src.tar.bz2
RUN rm /haskell-platform-2013.2.0.0.tar.gz
 
# Test everything up until now
RUN ghc --version
RUN cabal --version
