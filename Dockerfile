FROM elixir:1.10.3

# set Locale to en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV ERLANG_VER=1:21.3.8.14-1

RUN echo "deb https://packages.erlang-solutions.com/ubuntu bionic contrib" > /etc/apt/sources.list.d/erlang-solutions.list
RUN wget https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
RUN apt-key add erlang_solutions.asc

RUN apt-get update && apt-get install -y locales unzip vim unixodbc-dev libaio1 \
    erlang-base=$ERLANG_VER \
    erlang-odbc=$ERLANG_VER

RUN apt-get update && apt-get install -y locales unzip vim unixodbc-dev libaio1

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# install oracle instant client
RUN mkdir /opt/oracle
WORKDIR /opt/oracle

COPY ./instantclient/instantclient-basic-linux.x64-12.2.0.1.0.zip /opt/oracle/
RUN unzip /opt/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip

COPY ./instantclient/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle/
RUN unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip

COPY ./instantclient/instantclient-jdbc-linux.x64-12.2.0.1.0.zip /opt/oracle/
RUN unzip /opt/oracle/instantclient-jdbc-linux.x64-12.2.0.1.0.zip

COPY ./instantclient/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /opt/oracle/
RUN unzip /opt/oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip

COPY ./instantclient/instantclient-odbc-linux.x64-12.2.0.1.0.zip /opt/oracle/
RUN unzip /opt/oracle/instantclient-odbc-linux.x64-12.2.0.1.0.zip

RUN ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.1 /opt/oracle/instantclient_12_2/libclntsh.so
COPY ./tnsnames.ora /opt/oracle/instantclient_12_2

ENV NLS_LANG=AMERICAN_AMERICA.US7ASCII
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2
ENV TNS_ADMIN=/opt/oracle/instantclient_12_2

WORKDIR /opt/oracle/instantclient_12_2
COPY odbcinst.ini /etc/odbcinst.ini
RUN /opt/oracle/instantclient_12_2/odbc_update_ini.sh /


# app install
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
CMD [ "bash" ]
