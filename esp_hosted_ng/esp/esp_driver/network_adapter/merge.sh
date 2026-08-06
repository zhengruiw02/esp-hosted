
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

# Get firmware version from header
version_file=./main/include/esp_fw_version.h

version=
MACROS=("PROJECT_VERSION_MAJOR_1" "PROJECT_VERSION_MAJOR_2" "PROJECT_VERSION_MINOR" "PROJECT_REVISION_PATCH_1" "PROJECT_REVISION_PATCH_2")
for macro in "${MACROS[@]}"; do
    # Use grep + sed extract macros
    value=$(grep -E "^[\t ]*#define[\t ]+${macro}(\(|\s|$)" "$version_file" | \
            sed -E 's/^[^A-Za-z0-9_]*#define[ \t]+[A-Za-z0-9_]+[ \t]+["]?([A-Za-z0-9]+)["]?$/\1/')

    if [ -n "$value" ]; then
        # echo "$macro: $value"
        version=$version$value
    fi
done

fw_version=$version
echo FW_VERSION=$fw_version 

python -m esptool --chip ${target} merge_bin --output esp_hosted_ng_${target}_${fw_type}_merged_v${fw_version}.bin  0x0 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0xd000 build/ota_data_initial.bin 0x10000 build/network_adapter.bin