![GitHub last commit](https://img.shields.io/github/last-commit/centminmod/nvme-info) ![GitHub contributors](https://img.shields.io/github/contributors/centminmod/nvme-info) ![GitHub Repo stars](https://img.shields.io/github/stars/centminmod/nvme-info) ![GitHub watchers](https://img.shields.io/github/watchers/centminmod/nvme-info) ![GitHub Sponsors](https://img.shields.io/github/sponsors/centminmod) ![GitHub top language](https://img.shields.io/github/languages/top/centminmod/nvme-info) ![GitHub language count](https://img.shields.io/github/languages/count/centminmod/nvme-info)

Shell script to grab NVMe drive information

# Requirements

Requires `nvme-cli`, `jq` and `bc` packages

```
yum -y install nvme-cli jq bc
```

or

```
apt -y install nvme-cli jq bc
```

# Examples

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

```
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