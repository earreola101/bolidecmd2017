
#!/bin/sh

set -x
set -e

mkdir -p ./Build/tmp
bootgen -image ./boot_splitter.bif -arch zynq -o ./Build/tmp/jtag_splitter.bin -packagename 7x007s -w
../../Utility/FWgenerate/FWgenerate 213 213 0 0 ./Build/tmp/jtag_splitter.bin
cp ./Build/tmp/jtag_splitter.bin.213_213_0_0.md5 ./Build/tmp/boot_mic_pod_hub.bin
cd ./Build/tmp
zip ./boot_mic_pod_hub.bin.213_213_0_0.md5.zip boot_mic_pod_hub.bin
mv boot_mic_pod_hub.bin.213_213_0_0.md5.zip ../


