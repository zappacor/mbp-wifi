# mount /dev/sda1 /mnt

logFile=/mnt/prueba.log

for ((i=$((0x160000));i<=$((0x2F0000));i=$(($i+$((0x1000)))))); do
 echo 'XXXXXXXXXXXXXXXXX Trying '$(printf "%#x\n" $i)| tee -a $logFile
 dmesg -C
 modprobe -r brcmfmac 2>&1| tee -a $logFile
 sleep 1
 modprobe brcmfmac rambase_addr=$i debug=0xFFFFFF 2>&1| tee -a $logFile
 sleep 10
 dmesg >>$logFile
 dmesg|egrep 'base=0x|failed'
 dmesg|grep -q failed || echo 'LOOK AT THIS'| tee -a $LogFile
done
