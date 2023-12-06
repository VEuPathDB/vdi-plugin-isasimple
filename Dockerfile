
FROM veupathdb/vdi-plugin-base:2.0.4

COPY bin /usr/bin/
COPY lib/xml/* /usr/local/lib/xml/

workdir ${PROJECT_HOME}

ARG APICOMMONDATA_COMMIT_HASH=3b4c40f1fe06880c34df4c4616ad8da3239e85fd \
    CLINEPIDATA_GIT_COMMIT_SHA=0c2758f64b67cb8504b30616b37d79a649e18d48 \
    EDA_NEXTFLOW_GIT_COMMIT_SHA=9614218ad998ece62c67ce7bb14837c07bb8ab6a

ENV PATH=${PROJECT_HOME}/install/bin:${GUS_HOME}/bin:$PATH

RUN perl -MCPAN -e 'install qq(Switch)' \
    && perl -MCPAN -e 'install qq(Config::Std)' \
   && perl -MCPAN -e 'install qq(Text::Unidecode)' \
   && perl -MCPAN -e 'install qq(XML::Simple)'

RUN /usr/bin/install.bash


# RUN export LIB_GIT_COMMIT_SHA=4fcd4f3183f8decafe7a0d0a8a8400470c7f9222\
#     && git clone https://github.com/VEuPathDB/lib-vdi-plugin-study.git \
#     && cd lib-vdi-plugin-study \
#     && git checkout $LIB_GIT_COMMIT_SHA \
#     && mkdir -p /opt/veupathdb/lib/perl \
#     && cp lib/perl/VdiStudyHandlerCommon.pm /opt/veupathdb/lib/perl \
#     && cp bin/* /opt/veupathdb/bin


# From postgres container:  We set the default STOPSIGNAL to SIGINT, which corresponds to what PostgreSQL
# calls "Fast Shutdown mode" wherein new connections are disallowed and any
# in-progress transactions are aborted, allowing PostgreSQL to stop cleanly and
# flush tables to disk, which is the best compromise available to avoid data
# corruption.
# NOTE:  I'm pretty sure this is not working... docker stop should produce some output about pg_ctl stop command but i don't see it
STOPSIGNAL SIGINT

workdir /isasimple-data

ENTRYPOINT startPostGreSQLServer.bash
