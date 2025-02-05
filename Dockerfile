FROM veupathdb/gus-apidb-base:1.2.7

ARG APICOMMONDATA_COMMIT_HASH=699a94aab7c853205274aed2039ce0d2e4b76e30 \
    CLINEPIDATA_GIT_COMMIT_SHA=8d31ba1b5cf7f6b022058b7c89e8e3ab0665f543 \
    EDA_NEXTFLOW_GIT_COMMIT_SHA=f113cca94b9d16695dc4ac721de211d72e7c396f \
    SHARED_LIB_GIT_COMMIT_SHA=ee4853748fcdd5d7d8675eb0eb3828ea11da8f42

ARG PLUGIN_SERVER_VERSION=v8.1.0-rc3

ENV JVM_MEM_ARGS="-Xms16m -Xmx64m" \
    JVM_ARGS="" \
    TZ="America/New_York"

# ADDITIONAL PERL DEPENDENCIES
RUN perl -MCPAN -e 'install qq(Switch)' \
    && perl -MCPAN -e 'install qq(Config::Std)' \
    && perl -MCPAN -e 'install qq(Text::Unidecode)' \
    && perl -MCPAN -e 'install qq(Date::Calc)' \
    && perl -MCPAN -e 'install qq(XML::Simple)' \
    && perl -MCPAN -e 'install qq(Digest::SHA1)'

# Ensure we log in the correct timezone.
RUN apt-get update \
    && apt-get install -y tzdata \
    && apt-get clean \
    && cp /usr/share/zoneinfo/America/New_York /etc/localtime \
    && echo ${TZ} > /etc/timezone

# Install find-bin-width tool.
RUN wget -q -O fbw.zip https://github.com/VEuPathDB/script-find-bin-width/releases/download/v1.0.3/fbw-linux-1.0.3.zip \
    && unzip fbw.zip \
    && rm fbw.zip \
    && mv find-bin-width /usr/bin/find-bin-width

RUN git clone https://github.com/VEuPathDB/lib-vdi-plugin-study.git \
    && cd lib-vdi-plugin-study \
    && git checkout ${SHARED_LIB_GIT_COMMIT_SHA} \
    && mkdir -p /opt/veupathdb/lib/perl /opt/veupathdb/bin \
    && cp lib/perl/VdiStudyHandlerCommon.pm /opt/veupathdb/lib/perl \
    && cp bin/* /opt/veupathdb/bin

# CLONE ADDITIONAL GIT REPOS
COPY bin/buildGus.bash /usr/bin/buildGus.bash
RUN /usr/bin/buildGus.bash

# Install vdi plugin HTTP server
RUN curl "https://github.com/VEuPathDB/vdi-plugin-handler-server/releases/download/${PLUGIN_SERVER_VERSION}/service.jar" -LsO

ENV PATH="$PATH:/opt/veupathdb/bin"

COPY bin /opt/veupathdb/bin/
COPY lib/xml/* /usr/local/lib/xml/

RUN chmod +x /opt/veupathdb/bin/*

CMD ["run-plugin.sh"]
