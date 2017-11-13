## Disk performance test guide for Linux

### Setup

1. Deploy Ubuntu Server 17.10 VM with SSD Storage
2. Add up to 8 disks based on the configuration described in the chart below.  Ensure that *Host Caching* is set to None.

### Lessons

1.  Balance the maximum IOPS allowed on the VM with bandwidth.  You can be throttled by IOPS which will limit the bandwidth you can push through to the disks.

2.  Ensure VM type can support the required IOPS and bandwidth.  Review [Max local disk perf: IOPS / MBps](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general) column based on the VM type that you've selected.  The link is for general purpose, so if you can't find your VM, try the other categories of VMs such as Storage Optimized, Memory Optimized, etc.

3.  Achieve higher IOPS and bandwidth by striping multiple disks together.  You can use RAID-0 since Azure Storage will automatically make 3 synchronous copies of your data.  Review [scalability & performance targets](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/premium-storage#scalability-and-performance-targets).

4.  Disable *barriers* if setting the host caching to *None* or *Read-Only*.  See documentation on [premium storage for Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/premium-storage#premium-storage-for-linux-vms)


### Tools Installation

```bash
sudo apt-get install bwm-ng sysstat
```

### VM Configuration

* VM Size:  Standard_DS5_v2
* Operating System: Ubuntu Server 17.10
* Disk Manager:  LVM

### Test Configuration

**Scenario 1**

* 64k block size x 2,000,000 blocks
* 134 GB of read and write data
* No operating system caching

**Scenario 2**

* 128k block size x 1,000,000 blocks
* 134 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | 64k blocks - Avg. Read/Write Bandwidth | 128k blocks - Avg. Read/Write Bandwidth | Notes |
|----------:|-----------:|------------------:|----------------------------------:|------:|---:|
| 512 GB | 2 | 1 TB | 110 MB/s / 314 MB/s | - | - |
| 512 GB | 4 | 2 TB | 161 MB/s / 492 MB/s | 265 MB/s / 489 MB/s  | Throttling at 150 MB/s (Disk limit) |
| 512 GB | 8 | 4 TB | 293 MB/s / 530 MB/s | 300 MB/s / 511 MB/s  | Bandwidth Throttled at 768 MB/s (VM limit), expect pauses where data is not written to disks |

### Configure Disks

Update the stripes and size based on your application scenarios.  For example, for OLTP use 64K and for OLAP use 256K.

* --stripes 4
* --stripesize 64

```bash
sudo pvcreate /dev/sd[cdef]

  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
  Physical volume "/dev/sde" successfully created.
  Physical volume "/dev/sdf" successfully created.
 
```

```bash
sudo vgcreate vg0 /dev/sd[cdef]

  Volume group "vg0" successfully created
```

```bash
sudo lvcreate --stripes 4 --stripesize 64 -l 100%FREE -n lv0 vg0

  Logical volume "lv0" created.
```

```bash
sudo mkfs -t ext3 /dev/vg0/lv0

mke2fs 1.43.5 (04-Aug-2017)
Discarding device blocks: done
Creating filesystem with 536866816 4k blocks and 134217728 inodes
Filesystem UUID: 840fce68-c2c3-44dd-8a65-378eff884c12
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000, 214990848, 512000000

Allocating group tables: done
Writing inode tables: done
Creating journal (262144 blocks):
done
Writing superblocks and filesystem accounting information:
done
```

```
sudo mkdir /mnt/data
sudo mount -o nobarrier /dev/vg0/lv0 /mnt/data
```

Validate that the striping is configured properly.

```bash
sudo lvs --segments

  LV   VG  Attr       #Str Type    SSize
  lv0  vg0 -wi-a-----    4 striped 2.00t
```

### Performance Test

Launch three SSH sessions.  One will be used to monitor the disk operations using *bwm-ng*.  The other will be used to run performance test cases.

Launch bwm-ng

```bash
sudo bwm-ng -i disk -I sdc,sdd,sde,sdf
```

Launch iostat

```bash
sudo watch -n 1 iostat -m
````

Execute Write Tests

```bash
sudo dd if=/dev/zero of=/mnt/data/output bs=64k count=2000k

2048000+0 records in
2048000+0 records out
134217728000 bytes (134 GB, 125 GiB) copied, 277.297 s, 484 MB/s

bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
  input: disk IO type: rate
  |         iface                   Rx                   Tx                Total
  ==============================================================================
              sde:           0.00 KB/s       148183.64 KB/s       148183.64 KB/s
              sdf:           0.00 KB/s       153293.42 KB/s       153293.42 KB/s
              sdd:           0.00 KB/s       149205.59 KB/s       149205.59 KB/s
              sdc:           7.98 KB/s       152271.47 KB/s       152279.44 KB/s
  ------------------------------------------------------------------------------
            total:           7.98 KB/s       602954.12 KB/s       602962.06 KB/s  
```

Execute Read Tests

```bash
# Clear Caches
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"

# Execute Read Test
sudo dd if=/mnt/data/output of=/dev/null bs=64k

2048000+0 records in
2048000+0 records out
134217728000 bytes (134 GB, 125 GiB) copied, 835.638 s, 161 MB/s

bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
  input: disk IO type: rate
  |         iface                   Rx                   Tx                Total
  ==============================================================================
              sde:       37389.22 KB/s            0.00 KB/s        37389.22 KB/s
              sdf:       37357.29 KB/s            0.00 KB/s        37357.29 KB/s
              sdd:       37045.91 KB/s            0.00 KB/s        37045.91 KB/s
              sdc:       37301.40 KB/s            0.00 KB/s        37301.40 KB/s
  ------------------------------------------------------------------------------
            total:      149093.81 KB/s            0.00 KB/s       149093.81 KB/s
```

### Clean up

```bash
sudo umount /mnt/data
```

```bash
sudo lvremove /dev/vg0/lv0

Do you really want to remove and DISCARD active logical volume vg0/lv0? [y/n]: y
Logical volume "lv0" successfully removed                                                
```

```bash
sudo vgremove vg0

  Volume group "vg0" successfully removed
```

```bash
sudo pvremove /dev/sd[cdef]

  Labels on physical volume "/dev/sdc" successfully wiped.
  Labels on physical volume "/dev/sdd" successfully wiped.
  Labels on physical volume "/dev/sde" successfully wiped.
  Labels on physical volume "/dev/sdf" successfully wiped.
```
