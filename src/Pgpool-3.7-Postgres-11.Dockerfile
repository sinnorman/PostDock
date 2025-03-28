##########################################################################
##                         AUTO-GENERATED FILE                          ##
##########################################################################

FROM postgres:13-bullseye
ARG DOCKERIZE_VERSION=v0.2.0

#RUN groupadd -r postgres --gid=999 && useradd -r -g postgres -d /home/postgres  --uid=999 postgres

# grab gosu for easy step-down from root
ARG GOSU_VERSION=1.11
RUN set -eux \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget gnupg2 lsb-release libffi-dev openssh-server gosu && rm -rf /var/lib/apt/lists/*  && \
	gosu nobody true

#COPY ./dockerfile/bin /usr/local/bin/dockerfile
#RUN chmod -R +x /usr/local/bin/dockerfile && ln -s /usr/local/bin/dockerfile/functions/* /usr/local/bin/

RUN  echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
     wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
     apt-get update

RUN apt-get -y install pgpool2 libpgpool2 postgresql-14-pgpool2
#RUN install_deb_pkg "https://apt.postgresql.org/pub/repos/apt/pool/main/p/pgpool2/pgpool2_4.3.3-3.pgdg100+1_amd64.deb" 
#RUN install_deb_pkg "http://ftp.de.debian.org/debian/pool/main/libm/libmemcached/libmemcached11_1.0.18-4.2_amd64.deb" "libmemcached11"
#RUN install_deb_pkg "http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb10u3_amd64.deb" "libssl1.1.1"
#RUN install_deb_pkg "https://apt.postgresql.org/pub/repos/apt/pool/main/p/pgpool2/libpgpool2_4.3.3-3.pgdg100+1_amd64.deb"
#RUN install_deb_pkg "https://apt.postgresql.org/pub/repos/apt/pool/main/p/pgpool2/postgresql-13-pgpool2_4.3.3-3.pgdg100+1_amd64.deb"


RUN  wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
     tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY ./ssh /tmp/.ssh
RUN mv /tmp/.ssh/sshd_start /usr/local/bin/sshd_start && chmod +x /usr/local/bin/sshd_start
COPY ./pgpool/bin /usr/local/bin/pgpool
COPY ./pgpool/configs /var/pgpool_configs

RUN chmod +x -R /usr/local/bin/pgpool

ENV CHECK_USER replication_user
ENV CHECK_PASSWORD replication_pass
ENV CHECK_PGCONNECT_TIMEOUT 10
ENV WAIT_BACKEND_TIMEOUT 120
ENV REQUIRE_MIN_BACKENDS 0
ENV SSH_ENABLE 0
ENV NOTVISIBLE "in users profile"

ENV CONFIGS_DELIMITER_SYMBOL ,
ENV CONFIGS_ASSIGNMENT_SYMBOL :
                                #CONFIGS_DELIMITER_SYMBOL and CONFIGS_ASSIGNMENT_SYMBOL are used to parse CONFIGS variable
                                # if CONFIGS_DELIMITER_SYMBOL=| and CONFIGS_ASSIGNMENT_SYMBOL=>, valid configuration string is var1>val1|var2>val2


EXPOSE 22
EXPOSE 5432
EXPOSE 9898

HEALTHCHECK --interval=1m --timeout=10s --retries=5 \
  CMD /usr/local/bin/pgpool/has_write_node.sh

CMD ["/usr/local/bin/pgpool/entrypoint.sh"]
