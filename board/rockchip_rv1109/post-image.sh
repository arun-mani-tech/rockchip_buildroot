#!/bin/bash

set -e 
cd ${CONFIG_DIR} && git clone https://github.com/arun-mani-tech/rockchip_tools.git
cd ${CONFIG_DIR}/rockchip_tools/ && chmod +x afptool boot_merger mkimage resource_tool rkImageMaker
${CONFIG_DIR}/rockchip_tools/boot_merger ${CONFIG_DIR}/rockchip_tools/RV1126MINIALL.ini
mv ${CONFIG_DIR}/rockchip_tools/rv1126_spl_loader_v1.05.106.bin ${CONFIG_DIR}/output/images/
echo "second stage bootloader:${CONFIG_DIR}/rv1126_spl_loader_v1.05.106.bin"
${CONFIG_DIR}/rockchip_tools/resource_tool ${CONFIG_DIR}/output/images/rv1126-evb-ddr3-v13.dtb
#mv resource.img ${CONFIG_DIR}/rockchip_tools/
echo "resource image build"
cp ${CONFIG_DIR}/output/images/rv1126-evb-ddr3-v13.dtb ${CONFIG_DIR}/output/images/zImage ${CONFIG_DIR}/rockchip_tools/
${CONFIG_DIR}/rockchip_tools/mkimage -f ${CONFIG_DIR}/rockchip_tools/kernel.its -E -p 0x800 ${CONFIG_DIR}/output/images/zboot.img

echo "kernel image:${CONFIG_DIR}/output/images/zboot.img"

mkdir ${CONFIG_DIR}/update && cd ${CONFIG_DIR}/update/
mkdir Image && cd Image/
cp ${CONFIG_DIR}/output/images/zboot.img ${CONFIG_DIR}/output/images/u-boot.itb ${CONFIG_DIR}/output/images/rootfs.ext2 ${CONFIG_DIR}/output/images/rv1126_spl_loader_v1.05.106.bin ./
touch parameter.txt
echo "FIRMWARE_VER: 8.1" > parameter.txt
echo "MACHINE_MODEL: RV1126" >> parameter.txt
echo "MACHINE_ID: 007" >> parameter.txt
echo "MANUFACTURER: RV1126" >> parameter.txt
echo "MAGIC: 0x5041524B" >> parameter.txt
echo "ATAG: 0x00200800" >> parameter.txt
echo "MACHINE: 0xffffffff" >> parameter.txt
echo "CHECK_MASK: 0x80" >> parameter.txt
echo "PWR_HLD: 0,0,A,0,1" >> parameter.txt
echo "TYPE: GPT" >> parameter.txt
echo "CMDLINE: mtdparts=rk29xxnand:0x00002000@0x00004000(uboot),0x0008000@0x00006000(boot),-@0x00014000(rootfs:grow)" >> parameter.txt
echo "uuid:rootfs=614e0000-0000-4b53-8000-1d28000054a9" >> parameter.txt
touch ${CONFIG_DIR}/update/package-file
echo "package-file    package-file" > ${CONFIG_DIR}/update/package-file
echo "bootloader      Image/rv1126_spl_loader_v1.05.106.bin" >> ${CONFIG_DIR}/update/package-file
echo "parameter       Image/parameter.txt" >> ${CONFIG_DIR}/update/package-file
echo "uboot           Image/u-boot.itb" >> ${CONFIG_DIR}/update/package-file
echo "boot            Image/zboot.img" >> ${CONFIG_DIR}/update/package-file
echo "rootfs          Image/rootfs.ext2" >> ${CONFIG_DIR}/update/package-file
cd ${CONFIG_DIR}/update/
cp Image/parameter.txt parameter
${CONFIG_DIR}/rockchip_tools/afptool -pack . Image/update.img
${CONFIG_DIR}/rockchip_tools/rkImageMaker -RK1126 Image/rv1126_spl_loader_v1.05.106.bin Image/update.img system.img -os_type:androidos
mv ${CONFIG_DIR}/update/system.img ${CONFIG_DIR}/output/images/
rm -rf ${CONFIG_DIR}/update/
rm -rf ${CONFIG_DIR}/rockchip_tools/

