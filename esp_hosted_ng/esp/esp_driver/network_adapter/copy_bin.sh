#!/bin/bash

# Get target chipset
target=$(grep -Eo 'CONFIG_IDF_TARGET=".*?"' sdkconfig | sed 's/.*="\(.*\)".*/\1/g')
echo TARGET=$target

# Get firmware type config
fw_is_sdio=$(grep -Eo 'CONFIG_ESP_SDIO_HOST_INTERFACE=y' sdkconfig)
fw_is_spi=$(grep -Eo 'CONFIG_ESP_SPI_HOST_INTERFACE=y' sdkconfig)

if [ -n "$fw_is_sdio" ]; then
    fw_type="sdio"
fi
if [ -n "$fw_is_spi" ]; then
    fw_type="spi"
fi
echo FW_TYPE=$fw_type

# Get firmware version from parameter
# fw_version="$1"
# # 判断参数是否为空
# if [ ! -n "$fw_version" ]; then
#     echo "[-] Please input parameter for FW_VERSION!, for example 10402 as 1.0.4.0.2"
#     # help
#     exit 1
# fi
version_file=./main/include/esp_fw_version.h
project_name=$(grep -Eo 'PROJECT_NAME.*?' "$version_file" | sed 's/.*"\(.*\)".*/\1/g')
# echo PROJECT_NAME = $project_name
version=
MACROS=("PROJECT_VERSION_MAJOR_1" "PROJECT_VERSION_MAJOR_2" "PROJECT_VERSION_MINOR" "PROJECT_REVISION_PATCH_1" "PROJECT_REVISION_PATCH_2")
for macro in "${MACROS[@]}"; do
    # 使用 grep + sed 提取宏的值部分
    value=$(grep -E "^[\t ]*#define[\t ]+${macro}(\(|\s|$)" "$version_file" | \
            sed -E 's/^[^A-Za-z0-9_]*#define[ \t]+[A-Za-z0-9_]+[ \t]+["]?([A-Za-z0-9]+)["]?$/\1/')

    if [ -n "$value" ]; then
        # echo "$macro: $value"
        version=$version$value
    fi
done
# echo VERSION = $version
fw_version=$project_name"_"$version
echo FW_VERSION=$fw_version 

# Make dir for copy bin
copy_dir="release_bin_"$target"_"$fw_type"_"$fw_version
echo copy_dir=$copy_dir 
if [ ! -d "$copy_dir" ]; then
    mkdir $copy_dir
fi

cd build
cp network_adapter.bin ota_data_initial.bin partition_table/partition-table.bin bootloader/bootloader.bin ../$copy_dir/

# echo "python -m esptool --chip $target -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x0 bootloader.bin 0x8000 partition-table.bin 0xd000 ota_data_initial.bin 0x10000 network_adapter.bin" > ../$copy_dir/flash.sh
flash_args=$(cat flash_project_args | sed -E 's|([^/ ]+/)+([^/ ]+)|\2|g' | awk '{printf "%s ", $0}')
# flash_args=$(cat build/flash_project_args |  sed -E 's|([^/ ]+/)+([^/ ]+)|\2|g' | awk '{printf "%s ", $0}')

echo "python -m esptool --chip $target -b 460800 --before default_reset --after hard_reset write_flash $flash_args" > ../$copy_dir/flash.sh
chmod +x ../$copy_dir/flash.sh
