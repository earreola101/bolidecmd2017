
#!/bin/sh

set -x
set -e

mkdir -p ./Build/tmp
cp ./Build/app/table_hub_app ./Build/tmp/
../../Utility/FWgenerate/FWgenerate 214 213 0 0 ./Build/tmp/table_hub_app
cp ./Build/tmp/table_hub_app.214_213_0_0.md5 ./Build/tmp/table_hub_app_
cd ./Build/tmp
zip ./table_hub_app.214_213_0_0.md5.zip table_hub_app_
mv table_hub_app.214_213_0_0.md5.zip ../


