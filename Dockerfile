#https://wiki.dlib.indiana.edu/display/VarVideo/Getting+Started+%28Linux%29
#FROM rhel6.7
FROM centos:6.7

MAINTAINER eric.james@yale.edu

RUN yum -y install gcc-c++ zlib-devel readline-devel openssl-devel java-1.7.0-openjdk which tar

RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -L https://get.rvm.io | bash -s stable --ruby

#ERJ 5/4/16 beyond here not tested
RUN gem update --system
RUN gem install bundler
RUN yum -y install git

RUN yum -y install ffmpeg
RUN yum -y install mediainfo

RUN yum install ruby-devel libxml2-devel libxslt libxslt-devel libcurl-devel sqlite-devel

RUN git clone git@github.com:yalelibrary/avalon.git
WORKDIR avalon
RUN bundle install --gemfile=Gemfile.first
RUN QMAKE=/usr/bin/qmake-qt4 bundle install

COPY secrets.yml config/secrets.yml
COPY authentication.yml config/authentication.yml
COPY controlled_vocabulary.yml config/controlled_vocabulary.yml
COPY avalon.yml config/avalon.yml
COPY fedora.fcfg fedora_conf/conf/development/fedora.fcfg
COPY fodora.fcfg fedora_conf/conf/test/fedora.fcfg

RUN git submodule init
RUN git submodule update
WORKDIR jetty
RUN git fetch --tags
RUN git checkout tags/v7.3.0 -b 7.3.0

WORKDIR avalon
RUN rake db:migrate
RUN rake db:test:prepare
RUN rake jetty:config
RUN rake felix:config

CMD "rake" "avalon:services:start"
CMD "rails" "server" 

#just a test
#RUN touch fingerprint1.txt


