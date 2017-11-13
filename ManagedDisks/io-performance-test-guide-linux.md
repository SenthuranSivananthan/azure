## Disk performance test guide for Linux

### Setup

1. Deploy Ubuntu Server 17.10 VM with SSD Storage
2. Add up to 8 disks based on the configuration described in the chart below.  Ensure that *Host Caching* is set to None.

### Tools Installation

```bash
sudo apt-get install bwm-ng
```

### Disk Configuration

| Disk Size | # of Disks | Stripe Size | Read Bandwidth | Write Bandwidth |
|----------:|-----------:|------------:|---------------:|----------------:|
| 512 GB | 1 | 64K | | |
| 512 GB | 2 | 64K | | |
| 512 GB | 4 | 64K | 194 MB/s | 224 MB/s |
| 512 GB | 8 | 64K | | |
| 1 TB | 1 | 64K | | |
| 1 TB | 2 | 64K | | |
| 1 TB | 4 | 64K | | |
| 1 TB | 8 | 64K | | |

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
sudo mount /dev/vg0/lv0 /mnt/data
```

Validate that the striping is configured properly.

```bash
sudo lvs --segments

  LV   VG  Attr       #Str Type    SSize
  lv0  vg0 -wi-a-----    4 striped 2.00t
```

### Performance Test

Launch two SSH sessions.  One will be used to monitor the disk operations using *bwm-ng*.  The other will be used to run performance test cases.

Launch bwm-ng
```bash
sudo bwm-ng -i disk -I sdc,sdd,sde,sdf
```

Execute Write Tests

```bash
sudo dd if=/dev/zero of=/mnt/data/output bs=64k count=100k;

102400+0 records in
102400+0 records out
6710886400 bytes (6.7 GB, 6.2 GiB) copied, 29.9376 s, 224 MB/s

bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
  input: disk IO type: rate
  -         iface                   Rx                   Tx                Total
  ==============================================================================
              sdc:           0.00 KB/s        61325.35 KB/s        61325.35 KB/s
              sdd:           7.98 KB/s        14307.39 KB/s        14315.37 KB/s
              sde:           7.98 KB/s        59273.45 KB/s        59281.44 KB/s
              sdf:           0.00 KB/s        56207.59 KB/s        56207.59 KB/s
  ------------------------------------------------------------------------------
            total:          15.97 KB/s       191113.78 KB/s       191129.75 KB/s
```

Execute Read Tests

```bash
# Clear Caches
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"

# Execute Read Test
sudo dd if=/mnt/data/output of=/dev/null bs=64k

102400+0 records in
102400+0 records out
6710886400 bytes (6.7 GB, 6.2 GiB) copied, 34.5511 s, 194 MB/s

bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
  input: disk IO type: rate
  /         iface                   Rx                   Tx                Total
  ==============================================================================
              sdc:       47033.93 KB/s            0.00 KB/s        47033.93 KB/s
              sdd:       47009.98 KB/s            0.00 KB/s        47009.98 KB/s
              sde:       47033.93 KB/s            0.00 KB/s        47033.93 KB/s
              sdf:       47137.73 KB/s            0.00 KB/s        47137.73 KB/s
  ------------------------------------------------------------------------------
            total:      188215.58 KB/s            0.00 KB/s       188215.58 KB/s

```

### Clean up

```bash
sudo umount /mnt/data
sudo lvremove /dev/vg0/lv0

Do you really want to remove and DISCARD active logical volume vg0/lv0? [y/n]: y
Logical volume "lv0" successfully removed                                                
```
