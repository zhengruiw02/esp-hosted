sudo modprobe bluetooth;
sudo modprobe cfg80211;
sudo insmod ./esp32_sdio.ko resetpin=6;
sleep 4;
sudo ifconfig wlan0 up
