# FIXME: Update this with appropriate tag after https://github.com/VEuPathDB/docker-gus-apidb-base/pull/1 is incorporated
FROM veupathdb/vdi-plugin-base:2.0.4


COPY bin /usr/bin/
COPY lib/xml/* /usr/local/lib/xml/

workdir ${PROJECT_HOME}

ARG APICOMMONDATA_COMMIT_HASH=cf55ae622bd2e21016c7c4cbdbf9e26da629d602 \
    CLINEPIDATA_GIT_COMMIT_SHA=0c2758f64b67cb8504b30616b37d79a649e18d48 \
    EDA_NEXTFLOW_GIT_COMMIT_SHA=32fee3254b229b00ee3ee5a0007e81e977f8042d

ENV PATH=${PROJECT_HOME}/install/bin:${GUS_HOME}/bin:$PATH

RUN perl -MCPAN -e 'install qq(Switch)' \
    && perl -MCPAN -e 'install qq(Config::Std)' \
   && perl -MCPAN -e 'install qq(Text::Unidecode)' \
   && perl -MCPAN -e 'install qq(XML::Simple)'

RUN /usr/bin/buildGus.bash

RUN wget -O fbw.zip https://github.com/VEuPathDB/script-find-bin-width/releases/download/v0.5.1/fbw-linux-0.5.1.zip \
    && unzip fbw.zip \
    && mv find-bin-width /usr/bin/find-bin-width

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

ENTRYPOINT startPostGreSQLServer.bash
