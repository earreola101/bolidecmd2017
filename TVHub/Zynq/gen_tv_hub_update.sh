#!/bin/sh

set -x
set -e

mkdir -p ./Build/tmp
cp ./Build/app/tv_hub_app ./Build/tmp/
../../Utility/FWgenerate/FWgenerate 213 213 0 0 ./Build/tmp/tv_hub_app
cp ./Build/tmp/tv_hub_app.213_213_0_0.md5 ./Build/tmp/tv_hub_app_
cd ./Build/tmp
zip ./tv_hub_app.213_213_0_0.md5.zip tv_hub_app_
mv tv_hub_app.213_213_0_0.md5.zip ../


