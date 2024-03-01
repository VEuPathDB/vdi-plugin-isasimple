FROM veupathdb/vdi-plugin-base:5.2.3

ARG APICOMMONDATA_COMMIT_HASH=52188ab1d9d395150a37addb9f911f2672b65cf9 \
    CLINEPIDATA_GIT_COMMIT_SHA=0c2758f64b67cb8504b30616b37d79a649e18d48 \
    EDA_NEXTFLOW_GIT_COMMIT_SHA=91127af88eaa2ef37af54a6b0ef56a7c9a208b98 \
    SHARED_LIB_GIT_COMMIT_SHA=ee4853748fcdd5d7d8675eb0eb3828ea11da8f42

RUN perl -MCPAN -e 'install qq(Switch)' \
    && perl -MCPAN -e 'install qq(Config::Std)' \
    && perl -MCPAN -e 'install qq(Text::Unidecode)' \
    && perl -MCPAN -e 'install qq(Date::Calc)' \
    && perl -MCPAN -e 'install qq(XML::Simple)'

COPY bin/buildGus.bash /usr/bin/buildGus.bash
RUN /usr/bin/buildGus.bash

RUN wget -O fbw.zip https://github.com/VEuPathDB/script-find-bin-width/releases/download/v1.0.0/fbw-linux-1.0.0.zip \
    && unzip fbw.zip \
    && rm fbw.zip \
    && mv find-bin-width /usr/bin/find-bin-width

RUN git clone https://github.com/VEuPathDB/lib-vdi-plugin-study.git \
    && cd lib-vdi-plugin-study \
    && git checkout ${SHARED_LIB_GIT_COMMIT_SHA} \
    && mkdir -p /opt/veupathdb/lib/perl /opt/veupathdb/bin \
    && cp lib/perl/VdiStudyHandlerCommon.pm /opt/veupathdb/lib/perl \
    && cp bin/* /opt/veupathdb/bin

COPY [ "bin/validateUserFiles", "bin/writeNextflowConfig", "bin/run-plugin.sh", "/usr/bin/" ]
COPY [ "bin/check-compatibility", "bin/import", "bin/install-data", "bin/uninstall", "/opt/veupathdb/bin/" ]
COPY lib/xml/* /usr/local/lib/xml/

CMD run-plugin.sh
