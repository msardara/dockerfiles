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

# Configure ATS
ENV ATS_CACHE="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/cache.config"
ENV ATS_CONGESTION="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/congestion.config"
ENV ATS_HOSTING="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/hosting.config"
ENV ATS_IPALLOW="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/ip_allow.config"
ENV ATS_LOGHOSTS="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/log_hosts.config"
ENV ATS_LOGGING="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/logging.config"
ENV ATS_METRICS="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/metrics.config"
ENV ATS_PARENT="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/parent.config"
ENV ATS_PLUGIN="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/plugin.config"
ENV ATS_RECORDS="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/records.config"
ENV ATS_REMAP="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/remap.config"
ENV ATS_SOCKS="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/socks.config"
ENV ATS_SPLITDNS="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/splitdns.config"
ENV ATS_SSLMULTI="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/ssl_multicert.config"
ENV ATS_SERVNAME="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/ssl_server_name.config"
ENV ATS_STORAGE="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/storage.config"
ENV ATS_VOLUME="https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/etc/trafficserver/records.config"

RUN curl ${ATS_CACHE} -o /etc/trafficserver/cache.config
RUN curl ${ATS_CONGESTION} -o /etc/trafficserver/congestion.config
RUN curl ${ATS_HOSTING} -o /etc/trafficserver/hosting.config
RUN curl ${ATS_IPALLOW} -o /etc/trafficserver/ip_allow.config
RUN curl ${ATS_LOGHOSTS} -o /etc/trafficserver/log_hosts.config
RUN curl ${ATS_LOGGING} -o /etc/trafficserver/logging.config
RUN curl ${ATS_METRICS} -o /etc/trafficserver/metrics.config
RUN curl ${ATS_PARENT} -o /etc/trafficserver/parent.config
RUN curl ${ATS_PLUGIN} -o /etc/trafficserver/plugin.config
RUN curl ${ATS_RECORDS} -o /etc/trafficserver/records.config
RUN curl ${ATS_REMAP} -o /etc/trafficserver/remap.config
RUN curl ${ATS_SOCKS} -o /etc/trafficserver/socks.config
RUN curl ${ATS_SPLITDNS} -o /etc/trafficserver/splitdns.config
RUN curl ${ATS_SSLMULTI} -o /etc/trafficserver/ssl_multicert.config
RUN curl ${ATS_SERVNAME} -o /etc/trafficserver/ssl_server_name.config
RUN curl ${ATS_STORAGE} -o /etc/trafficserver/storage.config
RUN curl ${ATS_VOLUME} -o /etc/trafficserver/records.config

# Build hicn stack
RUN mkdir -p ${HICN_PATSHOME}
RUN git clone https://github.com/FDio/hicn.git ${HICN_PATSHOME}/hicn
RUN cd /tmp
RUN mkdir build && cd build

WORKDIR /tmp/build

RUN bash -c "cmake ${HICN_PATSHOME}/hicn -DBUILD_APPS=ON -DBUILD_HICNPLUGIN=ON -DCMAKE_INSTALL_PREFIX=/usr"
RUN make -j 4 install

RUN DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")') \
 && curl -Lo /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI" \
 && chmod +x /usr/local/bin/dumb-init \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/*

RUN mkdir /var/run/trafficserver
RUN chown -R trafficserver:trafficserver /var/run/trafficserver

RUN curl https://raw.githubusercontent.com/msardara/dockerfiles/master/ats/run_ats.sh -o /run_ats.sh
RUN chmod +x /run_ats.sh

ENTRYPOINT ["dumb-init"]
CMD ["/run_ats.sh"]