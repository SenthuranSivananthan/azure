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
sudo apt-get install bwm-ng fio
```

### VM Configuration

* VM Size:  Standard_DS5_v2 (Maximum disk throughput = 768 MB/s)
* Disks:  512 GB SSDs (Maximum throughput & IOPS per disk = 150 MB/s & 2300 IOPS)
* Operating System: Ubuntu Server 17.10
* Disk Manager:  LVM

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

### Performance Test with *fio*

**Scenario 1**

* 64k block size
* 75% read, 25% write
* 100 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | Avg. Read/Write Bandwidth | Avg. Read/Write IOPS | Throttled By |
|----------:|-----------:|------------------:|----------------------------------:|---:|---:|
| 512 GB | 2 | 1 TB | 216 MB/s / 72 MB/s | 3452 / 1151 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 4 | 2 TB | 419 MB/s / 140 MB/s | 6712 / 2239 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 8 | 4 TB | 559 MB/s / 186 MB/s | 8949 / 2985 | By VM at 768 MB/s |

**Scenario 2**

* 64k block size
* 25% read, 75% write
* 100 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | Avg. Read/Write Bandwidth | Avg. Read/Write IOPS | Throttled By |
|----------:|-----------:|------------------:|----------------------------------:|---:|---:|
| 512 GB | 2 | 1 TB | 72 MB/s / 216 MB/s | 1150 / 3454 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 4 | 2 TB | 140 MB/s / 420 MB/s | 2236 / 6713 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 8 | 4 TB | 186 MB/s / 560 MB/s | 2985 / 8961 | By VM at 768 MB/s |

**Scenario 3**

* 64k block size
* 0% read, 100% write
* 100 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | Avg. Write Bandwidth | Avg. Write IOPS | Throttled By |
|----------:|-----------:|------------------:|----------------------------------:|---:|---:|
| 512 GB | 2 | 1 TB | 287 MB/s | 4605 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 4 | 2 TB | 559 MB/s | 8946 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 8 | 4 TB | 746 MB/s | 11937 | By VM at 768 MB/s |

**Scenario 4**

* 64k block size
* 100% read, 0% write
* 100 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | Avg. Read Bandwidth | Avg. Read IOPS | Throttled By |
|----------:|-----------:|------------------:|----------------------------------:|---:|---:|
| 512 GB | 2 | 1 TB | 289 MB/s | 4606 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 4 | 2 TB | 559 MB/s | 8952 | By disk at 150 MB/s & 2300 IOPS per disk |
| 512 GB | 8 | 4 TB | 746 MB/s | 11947 | By VM at 768 MB/s |


Execute test with 75% read & 25% read ratio using 64k block size

```bash
sudo fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=AzureDiskIO --filename=/mnt/data/output --bs=64k --iodepth=64 --size=100G --readwrite=randrw --rwmixread=75

AzureDiskIO: (g=0): rw=randrw, bs=64K-64K/64K-64K/64K-64K, ioengine=libaio, iodepth=64
fio-2.16
Starting 1 process
Jobs: 1 (f=1): [m(1)] [100.0% done] [371.5MB/119.2MB/0KB /s] [5942/1919/0 iops] [eta 00m:00s]
AzureDiskIO: (groupid=0, jobs=1): err= 0: pid=14897: Mon Nov 13 20:12:32 2017
  read : io=76782MB, bw=412418KB/s, iops=6444, runt=190643msec
  write: io=25618MB, bw=137603KB/s, iops=2150, runt=190643msec
  cpu          : usr=3.09%, sys=17.43%, ctx=719292, majf=0, minf=9
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued    : total=r=1228510/w=409890/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: io=76782MB, aggrb=412418KB/s, minb=412418KB/s, maxb=412418KB/s, mint=190643msec, maxt=190643msec
  WRITE: io=25618MB, aggrb=137602KB/s, minb=137602KB/s, maxb=137602KB/s, mint=190643msec, maxt=190643msec

Disk stats (read/write):
    dm-0: ios=1228510/410004, merge=0/0, ticks=9179888/2910200, in_queue=12091056, util=100.00%, aggrios=307126/102491, aggrmerge=1/9, aggrticks=2294632/727360, aggrin_queue=3021878, aggrutil=98.46%
  sdf: ios=307033/102586, merge=0/11, ticks=2846652/911264, in_queue=3757768, util=98.46%
  sdd: ios=306924/102689, merge=5/8, ticks=1976448/620572, in_queue=2596992, util=97.63%
  sde: ios=307485/102130, merge=1/8, ticks=1936972/610496, in_queue=2547312, util=98.02%
  sdc: ios=307062/102562, merge=0/10, ticks=2418456/767108, in_queue=3185440, util=97.04%
```

### Performance Test with *dd*

**This is a single-threaded & sequential-write test. Typical applications will not have sustained writes or reads for long periods of time.  Therefore, the results can be meaningless for your scenario.  This will just give you data on burst limits.**

**Scenario 1**

* 64k block size x 2,000,000 blocks
* 134 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | Avg. Read/Write Bandwidth |
|----------:|-----------:|------------------:|--------------------------:|
| 512 GB | 2 | 1 TB | 110 MB/s / 314 MB/s |
| 512 GB | 4 | 2 TB | 161 MB/s / 492 MB/s |
| 512 GB | 8 | 4 TB | 293 MB/s / 530 MB/s |

**Scenario 2**

* 128k block size x 1,000,000 blocks
* 134 GB of read and write data
* No operating system caching

| Disk Size | # of Disks | Addressable Space | Avg. Read/Write Bandwidth |
|----------:|-----------:|------------------:|--------------------------:|
| 512 GB | 2 | 1 TB | - |
| 512 GB | 4 | 2 TB | 265 MB/s / 489 MB/s |
| 512 GB | 8 | 4 TB | 300 MB/s / 511 MB/s |


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
