# ATS Dockerfile
FROM ubuntu:18.04
MAINTAINER Mauro Sardara "msardara@cisco.com"

# Install Dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y build-essential apt-utils
RUN apt-get install -y libcurl4-openssl-dev cmake curl
RUN apt-get install -y trafficserver

RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get install -y libparc-dev vpp-lib vpp-dev libasio-dev --no-install-recommends python-ply

ENV HICN_PATSHOME="/hicn-stack"
COPY ./etc /tmp/etc

# Build ATS
#RUN rm -r /etc/trafficserver
COPY etc/trafficserver/*.config /etc/trafficserver/
#COPY etc/trafficserver/cache.conf /etc/trafficserver/cache.conf
#run cp /tmp/etc/trafficserver /etc/trafficserver

# Build hicn stack
RUN mkdir -p ${HICN_PATSHOME}
RUN git clone https://github.com/FDio/hicn.git ${HICN_PATSHOME}/hicn
RUN cd /tmp
RUN mkdir build && cd build

WORKDIR /tmp/build

RUN bash -c "cmake ${HICN_PATSHOME}/hicn -DBUILD_APPS=ON -DBUILD_HICNPLUGIN=ON -DCMAKE_INSTALL_PREFIX=/usr"
RUN make -j install

#COPY run_ats.sh /

#CMD /etc/init.d/trafficserver start
#CMD ["traffic_server", "-M", "--httpport", "8080:fd=7"]
#CMD nohup hicn-http-proxy -a 127.0.0.1 -p 8081 -c 50000 http://webserver &

RUN DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")') \
 && curl -Lo /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI" \
 && chmod +x /usr/local/bin/dumb-init \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/*

RUN mkdir /var/run/trafficserver
RUN chown -R trafficserver:trafficserver /var/run/trafficserver

COPY run_ats.sh /run_ats.sh
RUN chmod +x /run_ats.sh

ENTRYPOINT ["dumb-init"]
CMD ["/run_ats.sh"]