![GitHub last commit](https://img.shields.io/github/last-commit/centminmod/nvme-info) ![GitHub contributors](https://img.shields.io/github/contributors/centminmod/nvme-info) ![GitHub Repo stars](https://img.shields.io/github/stars/centminmod/nvme-info) ![GitHub watchers](https://img.shields.io/github/watchers/centminmod/nvme-info) ![GitHub Sponsors](https://img.shields.io/github/sponsors/centminmod) ![GitHub top language](https://img.shields.io/github/languages/top/centminmod/nvme-info) ![GitHub language count](https://img.shields.io/github/languages/count/centminmod/nvme-info)

Shell script to grab NVMe drive information

# Requirements

Requires `nvme-cli`, `jq` and `bc` packages

```
yum -y install nvme-cli jq bc smartmontools
```

or

```
apt -y install nvme-cli jq bc smartmontools
```

# Examples

Example for 4x 1TB Kingston KC3000 NVMe drives + 6x 960GB Kingston DC600M SSD SATA drives with updated `nvme-info.sh` with added NVMe and SSD drive writes statistics:

non-JSON format

```bash
./nvme-info.sh
Drive: /dev/nvme3n1 (NVMe)
Model: KINGSTON SKC3000S1024G
Firmware: EIFK51.2
Size: 953.86 GB
Temperature: 48.85 C
Available Spare: 100%
Percentage Used: 0%
Power On Hours: 369
Data Read: 1.80 TB
Data Written: 39.04 GB
Total Written: 39.04 GiB
Power Cycles: 35
-----
Drive: /dev/nvme2n1 (NVMe)
Model: KINGSTON SKC3000S1024G
Firmware: EIFK31.6
Size: 953.86 GB
Temperature: 29.85 C
Available Spare: 100%
Percentage Used: 0%
Power On Hours: 5493
Data Read: 1.80 TB
Data Written: 47.31 GB
Total Written: 47.31 GiB
Power Cycles: 179
-----
Drive: /dev/nvme1n1 (NVMe)
Model: KINGSTON SKC3000S1024G
Firmware: EIFK51.2
Size: 953.86 GB
Temperature: 43.85 C
Available Spare: 100%
Percentage Used: 0%
Power On Hours: 4240
Data Read: 3.34 TB
Data Written: 64.27 GB
Total Written: 64.27 GiB
Power Cycles: 30
-----
Drive: /dev/nvme0n1 (NVMe)
Model: KINGSTON SKC3000S1024G
Firmware: EIFK51.2
Size: 953.86 GB
Temperature: 55.85 C
Available Spare: 100%
Percentage Used: 0%
Power On Hours: 678
Data Read: 1.80 TB
Data Written: 32.33 GB
Total Written: 32.33 GiB
Power Cycles: 23
-----
Drive: /dev/sda
Model: KINGSTON SEDC600M960G
Serial: 50026B7686ED9234
Firmware: SCEKH5.3
Size: 894.25 GB
Temperature: 33 C
Power On Hours: 172
Power Cycles: 15
Total Written: 14 GiB
-----
Drive: /dev/sdb
Model: KINGSTON SEDC600M960G
Serial: 50026B7686ED9251
Firmware: SCEKH5.3
Size: 894.25 GB
Temperature: 29 C
Power On Hours: 172
Power Cycles: 17
Total Written: 14 GiB
-----
Drive: /dev/sdc
Model: KINGSTON SEDC600M960G
Serial: 50026B7686ED9169
Firmware: SCEKH5.3
Size: 894.25 GB
Temperature: 30 C
Power On Hours: 172
Power Cycles: 15
Total Written: 912 GiB
-----
Drive: /dev/sdd
Model: KINGSTON SEDC600M960G
Serial: 50026B7686ED9289
Firmware: SCEKH5.3
Size: 894.25 GB
Temperature: 30 C
Power On Hours: 172
Power Cycles: 15
Total Written: 31 GiB
-----
Drive: /dev/sde
Model: KINGSTON SEDC600M960G
Serial: 50026B7686ED9281
Firmware: SCEKH5.3
Size: 894.25 GB
Temperature: 26 C
Power On Hours: 172
Power Cycles: 15
Total Written: 927 GiB
-----
Drive: /dev/sdf
Model: KINGSTON SEDC600M960G
Serial: 50026B7686ED916B
Firmware: SCEKH5.3
Size: 894.25 GB
Temperature: 32 C
Power On Hours: 172
Power Cycles: 14
Total Written: 15 GiB
-----
```

JSON format:

```bash
./nvme-info.sh -o json
```
```json
[{
  "drive": "/dev/nvme3n1",
  "model": "KINGSTON SKC3000S1024G",
  "firmware": "EIFK51.2",
  "size": "953.86 GB",
  "temperature": 48.85,
  "available_spare": 100,
  "percentage_used": 0,
  "power_on_hours": 369,
  "data_read": "1.80 TB",
  "data_written": "39.04 GB",
  "power_cycles": 35,
  "type": "nvme"
},{
  "drive": "/dev/nvme2n1",
  "model": "KINGSTON SKC3000S1024G",
  "firmware": "EIFK31.6",
  "size": "953.86 GB",
  "temperature": 30.85,
  "available_spare": 100,
  "percentage_used": 0,
  "power_on_hours": 5493,
  "data_read": "1.80 TB",
  "data_written": "47.31 GB",
  "power_cycles": 179,
  "type": "nvme"
},{
  "drive": "/dev/nvme1n1",
  "model": "KINGSTON SKC3000S1024G",
  "firmware": "EIFK51.2",
  "size": "953.86 GB",
  "temperature": 43.85,
  "available_spare": 100,
  "percentage_used": 0,
  "power_on_hours": 4240,
  "data_read": "3.34 TB",
  "data_written": "64.27 GB",
  "power_cycles": 30,
  "type": "nvme"
},{
  "drive": "/dev/nvme0n1",
  "model": "KINGSTON SKC3000S1024G",
  "firmware": "EIFK51.2",
  "size": "953.86 GB",
  "temperature": 55.85,
  "available_spare": 100,
  "percentage_used": 0,
  "power_on_hours": 678,
  "data_read": "1.80 TB",
  "data_written": "32.33 GB",
  "power_cycles": 23,
  "type": "nvme"
},{
  "drive": "/dev/sda",
  "model": "KINGSTON SEDC600M960G",
  "serial": "50026B7686ED9234",
  "firmware": "SCEKH5.3",
  "size": "894.25 GB",
  "temperature": 33,
  "power_on_hours": 172,
  "power_cycles": 15,
  "type": "sata_ssd"
},{
  "drive": "/dev/sdb",
  "model": "KINGSTON SEDC600M960G",
  "serial": "50026B7686ED9251",
  "firmware": "SCEKH5.3",
  "size": "894.25 GB",
  "temperature": 29,
  "power_on_hours": 172,
  "power_cycles": 17,
  "type": "sata_ssd"
},{
  "drive": "/dev/sdc",
  "model": "KINGSTON SEDC600M960G",
  "serial": "50026B7686ED9169",
  "firmware": "SCEKH5.3",
  "size": "894.25 GB",
  "temperature": 30,
  "power_on_hours": 172,
  "power_cycles": 15,
  "type": "sata_ssd"
},{
  "drive": "/dev/sdd",
  "model": "KINGSTON SEDC600M960G",
  "serial": "50026B7686ED9289",
  "firmware": "SCEKH5.3",
  "size": "894.25 GB",
  "temperature": 30,
  "power_on_hours": 172,
  "power_cycles": 15,
  "type": "sata_ssd"
},{
  "drive": "/dev/sde",
  "model": "KINGSTON SEDC600M960G",
  "serial": "50026B7686ED9281",
  "firmware": "SCEKH5.3",
  "size": "894.25 GB",
  "temperature": 26,
  "power_on_hours": 172,
  "power_cycles": 15,
  "type": "sata_ssd"
},{
  "drive": "/dev/sdf",
  "model": "KINGSTON SEDC600M960G",
  "serial": "50026B7686ED916B",
  "firmware": "SCEKH5.3",
  "size": "894.25 GB",
  "temperature": 32,
  "power_on_hours": 172,
  "power_cycles": 14,
  "type": "sata_ssd"
}]
```

Example below for:

- Samsung SSD PM983 960GB 2.5 U.2 Gen 3.0 x4 PCIe NVMe
  * Up to 3,000MB/s Read, 1,050MB/s Write
  * 4K random read/write 400,000/40,000 IOPS
  * 1366 TBW / 1.3 DWPD
  * Power: 4 Watt (idle) 8.6 Watt (read) 8.1 Watt (write)
- Kingston DC1500M U.2 Enterprise SSD Gen 3.0 x4 PCIe NVME
  * Up to 3,100MB/s Read, 1,700MB/s Write
  * Steady-state 4k read/write 440,000/150,000 IOPS
  * 1681 TBW (1 DWPD/5yrs) (1.6 DWPD/3yrs)
  * Power: Idle: 6.30W Average read: 6.21W Average write: 11.40W Max read: 6.60W Max write: 12.24W

non-JSON format

```bash
./nvme-info.sh 
Drive: /dev/nvme0n1
Model: SAMSUNG MZQLB960HAJR-00007
Firmware: EDA5302Q
Size: 894.25 GB
Temperature: 32.85 C
Available Spare: 100%
Percentage Used: 0%
Powered On Time: 554 days 1 hours
Data Units Read: 148214333 (69.01 TB)
Data Units Written: 1505365 (717.81 GB)
Host Read Commands: 604876578
Host Write Commands: 121773994
Controller Busy Time: 586
Power Cycles: 28
-----
Drive: /dev/nvme1n1
Model: KINGSTON SEDC1500M960G
Firmware: S67F0103
Size: 894.25 GB
Temperature: 32.85 C
Available Spare: 100%
Percentage Used: 0%
Powered On Time: 525 days 14 hours
Data Units Read: 142596054 (66.40 TB)
Data Units Written: 7129815 (3.32 TB)
Host Read Commands: 589328916
Host Write Commands: 137392346
Controller Busy Time: 47543
Power Cycles: 22
-----
```

JSON format

```
./nvme-info.sh -o json
```
```json
[{
  "drive": "/dev/nvme0n1",
  "model": "SAMSUNG MZQLB960HAJR-00007",
  "firmware": "EDA5302Q",
  "size": "894.25 GB",
  "temperature": 32.85,
  "available_spare": 100,
  "percentage_used": 0,
  "powered_on_time": {
    "days": 554,
    "hours": 1
  },
  "data_units_read": {
    "units": 148214333,
    "size": "69.01 TB"
  },
  "data_units_written": {
    "units": 1505365,
    "size": "717.81 GB"
  },
  "host_read_commands": 604876578,
  "host_write_commands": 121774001,
  "controller_busy_time": 586,
  "power_cycles": 28
},{
  "drive": "/dev/nvme1n1",
  "model": "KINGSTON SEDC1500M960G",
  "firmware": "S67F0103",
  "size": "894.25 GB",
  "temperature": 32.85,
  "available_spare": 100,
  "percentage_used": 0,
  "powered_on_time": {
    "days": 525,
    "hours": 14
  },
  "data_units_read": {
    "units": 142596054,
    "size": "66.40 TB"
  },
  "data_units_written": {
    "units": 7129815,
    "size": "3.32 TB"
  },
  "host_read_commands": 589328916,
  "host_write_commands": 137392353,
  "controller_busy_time": 47543,
  "power_cycles": 22
}]
```