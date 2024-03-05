#!/usr/bin/env bash

set -e

cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/ApiCommonData.git
cd ApiCommonData
git reset --hard $APICOMMONDATA_COMMIT_HASH


git clone https://github.com/VEuPathDB/ClinEpiData.git
cd ClinEpiData
git checkout $CLINEPIDATA_GIT_COMMIT_SHA
