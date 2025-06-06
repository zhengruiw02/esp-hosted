# rm spidev_disabler.dtbo
# dtc spidev_disabler.dts -O dtb > spidev_disabler.dtbo
# sudo dtoverlay spidev_disabler;
sudo dtoverlay -d . spidev_disabler;
sudo modprobe bluetooth;
sudo modprobe cfg80211;
# sudo rmmod esp32_spi &> /dev/null
# sudo insmod ./esp32_spi.ko resetpin=6;
sudo insmod esp32_spi.ko resetpin=19;
sleep 4;
sudo ifconfig wlan0 up
