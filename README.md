**LINKS**

*Issues discussions:*

  "mikeeq/mbp-fedora-kernel - WiFi issues #3" => https://github.com/mikeeq/mbp-fedora-kernel/issues/3
  
  "Dunedan/mbp-2016-linux - MacBook Pro 15+: Wifi Support #112" => https://github.com/Dunedan/mbp-2016-linux/issues/112
  
*Related info:*
 
  "brcmfmac: reset two D11 cores if chip has two D11 cores" => https://patchwork.kernel.org/patch/11286575
  
  "Broadcom brcmsmac (PCIe) and brcmfmac (SDIO/USB) drivers" => https://wireless.wiki.kernel.org/en/users/drivers/brcm80211
  
  "Reverse Engineering Broadcom Chips To Enable Packet Traffic Arbitration for 2.4GHz Co-Existence" => https://hackernoon.com/reverse-engineering-broadcom-chips-to-enable-packet-traffic-arbitration-for-24ghz-co-existence-zz1i3yr2

**TESTS AND NOTES**

Two pieces of info and two questions I have to dig into further:

Info 1) this chip (BCM4364/4) has two cores

Info 2) when I loaded the module with a specific RAM address parameter (_modprobe brcmfmac rambase_addr=0x180000 debug=0xffffff)_, I could see **two** raminfo messages, each one for a **different** base address (when I didn't specify any _rambase_addr_, they were the same: 0x160000):
```
[  103.863252] brcmfmac: brcmf_chip_ai_resetcore found two d11 cores, reset both
[  103.969228] brcmfmac: brcmf_chip_ai_resetcore found two d11 cores, reset both
[  103.969561] brcmfmac: brcmf_chip_get_raminfo RAM: base=0x160000 size=1310720 (0x140000) sr=0 (0x0)
[  103.983450] brcmfmac: brcmf_chip_get_raminfo RAM: base=0x180000 size=1310720 (0x140000) sr=0 (0x0)
```
Question 1) are there two _brcmf_chip_get_raminfo_ messages because it's one message per core?

Question 2) if yes, shouldn't both _base=0xXXXXXX_ dumped values be the same?

Only (somehow) related info I could find is on https://patchwork.kernel.org/patch/11286575:
```
There are two D11 cores in RSDB chips like 4359. We have to reset two D11 cores simutaneously before
firmware download, or the firmware may not be initialized correctly and cause "fw initialized failed" error.
```
**EDIT 1**

Realized some of the files are actually just text, not binaries, which could be "interpreted" as some kind of pointer to the actual binaries:
```
"Firmware"="C-4364__s-B3/trinidad.trx"
	XSym
	0010
	fee982dfdb0e40d971e83ef3c9fdbdc5
	borneo.trx
		=> uses "borneo.trx" instead?
"TxCap"="C-4364__s-B3/trinidad-X0.txcb"
	XSym
	0013
	f42aa4bca0998b787ee1605728ad9726
	trinidad.txcb
		=> uses "trinidad.txcb" instead?
			=> Transmission Power Cap not used?
"Regulatory"="C-4364__s-B3/trinidad-X0.clmb"
	XSym
	0013
	e84b29139d7e7e3d814a6f87260bbefc
	trinidad.clmb
		=> uses "trinidad.clmb" instead?
"NVRAM"="C-4364__s-B3/P-trinidad-X0_M-HRPN_V-u__m-7.7.txt"
	XSym
	0032
	ecf31bb4bbfea112085d3c85c032c336
	P-trinidad_M-HRPN_V-u__m-7.7.txt
		=> uses "P-trinidad_M-HRPN_V-u__m-7.7.txt" instead?
```
However, ran "brcmRAMaddrTest-2.sh" to test RAM base addresses in the range 0x160000-0x2c1000 in steps of 0x1000 for these symlinks but didn't work either:
```
rm /lib/firmware/brcm/brcmfmac4364-pcie.*
#
ln -s drv/borneo.trx                                  /lib/firmware/brcm/brcmfmac4364-pcie.bin
   ln -s /lib/firmware/brcm/brcmfmac4364-pcie.bin        /lib/firmware/brcm/brcmfmac4364-pcie.trx
# Seems like the "*.txcb" files are not used:
#   ln -s /drv/trinidad.txcb                              ??????
ln -s drv/trinidad.clmb                               /lib/firmware/brcm/brcmfmac4364-pcie.clm_blob
ln -s drv/P-trinidad_M-HRPN_V-u__m-7.7.txt            /lib/firmware/brcm/brcmfmac4364-pcie.txt
   ln -s /lib/firmware/brcm/brcmfmac4364-pcie.txt        /lib/firmware/brcm/brcmfmac4364-pcie.Apple\ Inc.-MacBookPro16,2.txt
```

