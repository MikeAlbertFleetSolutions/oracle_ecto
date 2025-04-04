# set Locale to en_US.UTF-8
ARG ELIXIR_VERSION=1.18.3
ARG OTP_VERSION=25.3.2.18
ARG DEBIAN_VERSION=bookworm-20250317-slim

ARG IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${IMAGE}

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y locales unzip vim git unixodbc-dev libaio1

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# install oracle instant client
ENV NLS_LANG=AMERICAN_AMERICA.US7ASCII
COPY --from=mafs/instantclient:linux-instantclient_version-19.9-basiclite-sdk-odbc /instantclient /opt/oracle/
COPY ./instantclient/instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip /opt/oracle/
RUN unzip /opt/oracle/instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip
RUN rm /opt/oracle/instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip
RUN ln -s /opt/oracle/instantclient_19_9/sqlplus /usr/bin/sqlplus
COPY ./tnsnames.ora /opt/oracle/instantclient_19_9
RUN echo /opt/oracle/instantclient_19_9 > /etc/ld.so.conf.d/oracle.conf
RUN /sbin/ldconfig
ENV TNS_ADMIN=/opt/oracle/instantclient_19_9
WORKDIR /opt/oracle/instantclient_19_9
COPY odbcinst.19c.ini /etc/odbcinst.ini
RUN /opt/oracle/instantclient_19_9/odbc_update_ini.sh /
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_9

# app install
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
CMD [ "bash" ]
