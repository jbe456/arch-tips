# Dual Boot Arch Linux - Windows 10 on ASUS PC UX301LAA

## Prepare Windows 10

1.  Double check the PC motherboard firmware "BIOS mode" is [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface). This should be the case with Windows 10. See [How to Check if Windows is Booted in UEFI or Legacy BIOS Mode​](https://www.eightforums.com/threads/bios-mode-see-if-windows-boot-in-uefi-or-legacy-mode.29504/) for more details.

    Each motherboard is shipped with a firmware to handle the hardware initialization process. Designed in 1975, BIOS, a.k.a. "Basic Input-Output System" has been the norm for boot firmware until 2005. UEFI, a.k.a. "Unified Extensible Firmware Interface", is BIOS' improved successor. It is shipped with modern PC and is the one used in this tutorial to install Arch Linux.

    * Open command prompt and launch "Sytem Information": `Windows + R > cmd > msinfo32`

      <img src="./dual-boot-windows-10-asus-UX301LAA/msinfo32.png" alt="msinfo32" height="300px"/>

    * Make sure "BIOS mode" is `UEFI`

1.  Disable "fast startup":

    This is to avoid potential data loss. Indeed, Windows "fast startup" boots the sytem faster by reading the necessary information from the hibernation file. Therefore, once Windows is shutdown, if you attempt to copy some files from Linux to Windows, those files would be lost because not present in the hibernation file. See [Why disable Fast Boot on Windows 8 when having dual booting?](https://askubuntu.com/questions/452071/why-disable-fast-boot-on-windows-8-when-having-dual-booting) for more details.

    * Go to `Control Panel > Hardware and Sound > Power Options > System Settings`

      <img src="./dual-boot-windows-10-asus-UX301LAA/fast-startup.png" alt="fast startup" height="300px"/>

    * Uncheck "Turn on fast start-up"

1.  Disable "Secure Boot Control"

    With UEFI comes the "Secure Boot Control" options that ensures your PC only uses signed firmware that is trusted by the manufacturer. While it prevents malicious firmware to be installed, this could also potentially prevents you from installing Linux drivers. Note that it is still possible to [install Arch Linux with "Secure Boot Control" enabled](https://wiki.archlinux.org/index.php/Secure_Boot).

    * Enter [UEFI/BIOS configuration](#enter-uefibios-configuration)

    * Under the "Security" tab, set "Secure Boot Control" to disabled: https://www.asus.com/support/FAQ/1013017/

      <img src="./dual-boot-windows-10-asus-UX301LAA/uefi-secure-boot.png" alt="UEFI Secure Boot" height="300px"/>

For more information check out [How to prepare Windows for dual boot with Ubuntu or Linux Mint](https://sites.google.com/site/easylinuxtipsproject/windows).

## Create an Arch Linux installer USB drive from Windows

1.  Download Rufus from http://rufus.akeo.ie
1.  Download Arch Linux `iso` from https://www.archlinux.org/download/
1.  Insert a usb key with a capacity greater than the ISO size
1.  Launch Rufus and select the following parameters:

    <img src="./dual-boot-windows-10-asus-UX301LAA/rufus.png" alt="rufus" height="300px"/>

    * Partition scheme: "GPT partition scheme for UEFI"

      MBR (Master Boot Record) and GPT (GUID Partition Table) are two different ways of storing the partitioning information on a drive. This information includes where partitions start and begin, so your operating system knows which sectors belong to each partition and which partition is bootable. GPT is MBR's improved successor and is the one used in this tutorial. For more details, see [What’s the Difference Between GPT and MBR When Partitioning a Drive?](https://www.linkedin.com/pulse/whats-difference-between-gpt-mbr-when-partitioning-drive-tiwari)


    * File system: "FAT32"

      For a bootable device to be seen by a UEFI system, the device must be formatted using FAT32.

    * Cluster Size: 4096 bytes

      A cluster is the smallest logical amount of disk space that can be allocated to hold a file. It mostly affects performance and wasted disk space. For a live USB, the default cluster size is good enough. The default cluster size for a disk with a few gigabytes of space and formatted with FAT32 is 4096 bytes. See [Default cluster size for NTFS, FAT, and exFAT](https://support.microsoft.com/en-us/help/140365/default-cluster-size-for-ntfs-fat-and-exfat) for more details.

    * Check "Create a bootable disk using ...", select the Arch ISO image file and choose "DD Image" (Disk Image mode).

      [ISO images](http://en.wikipedia.org/wiki/ISO_image) are binary file that contains uncompressed exact copy of a file system. They were originally designed for optical media file systems such as [ISO-9660](https://en.wikipedia.org/wiki/ISO_9660) or [Universal Disk Format](https://en.wikipedia.org/wiki/Universal_Disk_Format) (UDF).

      Not every ISO images are bootable. To make such an image bootable, it needs to follow the [El-Torito](https://wiki.osdev.org/El-Torito) specification.

      At this point, the ISO image would be bootable only by an optical disc media. To make it bootable on both optical disk media and USB media, one need to run the [ISOHybrid command](https://www.syslinux.org/wiki/index.php?title=Isohybrid) from syslinux. This command postprocesses the ISO image file by enriching its file system with a Master Boot Record (MBR) partition, in order for BIOS/UEFI systems to consider it as a bootable hard disk. The Arch ISO image file is a ISOHybrid image.

      **ISO image mode** partition and format the USB in a way that Windows can always understand and using the whole capacity of the drive. Each individual file and directory from the ISO image is then copied onto the newly created file system.

      **Disk Image mode** (a.k.a. "DD Image") will create an exact bit-for-bit clone of the ISO image to the media. As a consequence, the media will not be recognize as a regular USB stick anymore: Windows might not be able to access its content and the size will appear shrinked to the ISO size.

      Since ISOHybrid images comes with their own file system and partitions, one need to select the "Disk Image" mode.

    For more details see:

      * [ISO Image Mode vs DD Image Mode](https://github.com/pbatard/rufus/issues/843)
      * [Why Is Creating a Bootable USB Drive More Complex Than Creating Bootable CDs?](https://www.howtogeek.com/291484/why-is-creating-a-bootable-usb-drive-more-complex-than-creating-bootable-cds/)
      * [How to build from Linux an ISO hybrid image bootable from BIOS or UEFI](https://github.com/patatetom/isohybrid-bios-uefi)
      * [Creating a bootable USB drive from an ISO image](https://www.turnkeylinux.org/blog/iso2usb)

For more information check out [How to Create Bootable Arch Linux on USB Drive](https://linoxide.com/linux-how-to/create-bootable-arch-linux-usb-drive/) and the Arch Linux wiki on [USB flash installation media](https://wiki.archlinux.org/index.php/USB_flash_installation_media#Using_Rufus).

## Create a partition for Linux

This operation could be done entirely with Linux. However it can be more convenient to create the partition directly with Windows in order to not mess up existing disk partitions, in particular when the laptop is configured with RAID.

> RAID (Redundant Array of Independent Disks) is a data storage virtualization technology that combines multiple physical disk drive components into one or more logical units for the purposes of data redundancy, performance improvement, or both
>
> \- Wikipedia

RAID is used to enhance performance and/or data recovery. It defines [6 levels](https://en.wikipedia.org/wiki/Standard_RAID_levels) that leverage different techniques such as striping, mirroring and parity.

There are three [types of RAID](https://en.wikipedia.org/wiki/RAID#Implementations):

* Hardware RAID: RAID managed by an actual external RAID controller.
* Software RAID: RAID managed by the Operating System.
* Firmware/Driver RAID, also called "fake RAID": RAID managed by the motherboard.

1.  Check ASUS PC UX301LAA disk type

    * Open the "Disk Management" panel: go to `Control Panel > System and Security > Administrative Tools > Create and format hard disk partitions` and check how many disks there are and their type:

      <img src="./dual-boot-windows-10-asus-UX301LAA/disk-management-basic-disk.png" alt="Disk Management Basic Disk Type" height="300px"/>

      There is only one disk and it is of type "Basic". This excludes the possibility of having a Software RAID since in that case the OS would show multiple disk of type "Dynamic" with the same drive letter.

    * Right click on the disk where the partition will be and select "Properties":

      <img src="./dual-boot-windows-10-asus-UX301LAA/disk-properties.png" alt="Disk Properties" height="300px"/>

      The device display name is "Intel RAID 0 Volume" which strongly hints that the PC is using a Firmware/Fake RAID.

    * Enter [UEFI/BIOS configuration](#enter-uefibios-configuration) and check the SATA mode:

      <img src="./dual-boot-windows-10-asus-UX301LAA/uefi-sata.jpg" alt="UEFI" height="300px"/>

      [SATA](https://en.wikipedia.org/wiki/Serial_ATA) (Serial ATA, abbreviated from "Serial AT Attachment") is a computer bus interface that connects host bus adapters to mass storage devices such as hard disk drives, optical drives, and solid-state drives. It replaces the older PATA (Parallel ATA) standard. See [Why is serial data transmission faster than parallel?](https://superuser.com/questions/602819/why-is-serial-data-transmission-faster-than-parallel)

      [AHCI](https://en.wikipedia.org/wiki/Advanced_Host_Controller_Interface) (Advanced Host Controller Interface) is an enhanced version of the SATA standard. It would consider each physical disk as a separate disk.

      [RAID](https://en.wikipedia.org/wiki/RAID) (Redundant Array of Independent Disks) is a SATA mode where physical disks are combined together by the firmware into a one or multiple "virtual disk" according to one of the standard RAID levels.

      The SATA mode, set to "RAID", confirms this PC is using Firmware/Fake RAID.

    * To double check, download and install [Intel® Rapid Storage Technology (Intel® RST) User Interface and Driver](https://downloadcenter.intel.com/download/27681/Intel-Rapid-Storage-Technology-Intel-RST-User-Interface-and-Driver). Then open "Intel® Rapid Storage Technology" and check the disk type:

      <img src="./dual-boot-windows-10-asus-UX301LAA/intel-rst.png" alt="Intel RST" height="300px"/>

      This PC has one 512GB disk made of two 256GB SSD (i.e. 238GiB) organize in a [RAID 0](https://en.wikipedia.org/wiki/Standard_RAID_levels#RAID_0): this means that the data is split between the two disks in stripes of 128KiB.

    See [How to check if hardware RAID is configured?](https://serverfault.com/questions/53368/how-to-check-if-hardware-raid-is-configured) for more details.

1.  Using Disk Management, create a new partition:

    * Select an existing partition
    * Right click and select "Shrink Volume...".
    * Specify the space you want to free: in our case, we create a slot of 100GB unallocated.
    * To make sure our new partition will be seen without any issues by Linux, format it (for example as NTFS).

1.  We will later on format the newly defined partition with a file system that Linux supports.

## Install Arch Linux

These steps are mainly inspired from [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)

### Boot from USB

1. Insert USB key
1. Enter [UEFI/BIOS configuration](#enter-uefibios-configuration)
1. Select the USB media to boot from: "Arch Linux archiso_x86_64 UEFI CD"

### Prepare installation

* Configure the keyboard to the correct layout: `loadkeys fr`

  See [Keyboard configuration in console](https://wiki.archlinux.org/index.php/Keyboard_configuration_in_console)

* Connect to the Wifi

  See [Wireless network configuration](https://wiki.archlinux.org/index.php/Wireless_network_configuration)

  ```bash
  > iw dev # Get the interface name
  phy#0
    Interface <wifi_interface_name>
      ifindex 2
      wdev 0x1
      addr <xx:xx:xx:xx:xx:xx>
      type managed

  > wifi-menu <wifi_interface_name> # Open Wifi panel, select network and enter password if necessary
  > ping google.com # check internet
  ```

* Identify the partition to format 

  See [lsblk](https://linux.die.net/man/8/lsblk) and [blkid](https://linux.die.net/man/8/blkid)

  Be careful to identify the correct partition as all its data will be erased once formatted. 

  ```bash
  > lsblk                                                               
  NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
  sda           8:0    0 238.5G  0 disk  
  └─md126       9:126  0   477G  0 raid0 
    ├─md126p1 259:0    0   100M  0 md    
    ├─md126p2 259:1    0   900M  0 md    
    ├─md126p3 259:2    0   128M  0 md    
    ├─md126p4 259:3    0 155.8G  0 md    
    ├─md126p5 259:4    0 200.1G  0 md    
    ├─md126p6 259:5    0   100G  0 md    
    └─md126p7 259:6    0    20G  0 md    
  sdb           8:16   0 238.5G  0 disk  
  └─md126       9:126  0   477G  0 raid0 
    ├─md126p1 259:0    0   100M  0 md    
    ├─md126p2 259:1    0   900M  0 md    
    ├─md126p3 259:2    0   128M  0 md    
    ├─md126p4 259:3    0 155.8G  0 md    
    ├─md126p5 259:4    0 200.1G  0 md    
    ├─md126p6 259:5    0   100G  0 md    
    └─md126p7 259:6    0    20G  0 md    

  > sudo blkid
  /dev/sdb: TYPE="isw_raid_member"
  /dev/md126: PTUUID="<PTUUID>" PTTYPE="gpt"
  /dev/sda: TYPE="isw_raid_member"
  /dev/md126p1: LABEL="SYSTEM" UUID="<UUID>" TYPE="vfat" PARTLABEL="EFI system partition" PARTUUID="<PARTUUID>"
  /dev/md126p2: LABEL="Recovery" UUID="<UUID>" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="<PARTUUID>"
  /dev/md126p3: PARTLABEL="Microsoft reserved partition" PARTUUID="<PARTUUID>"
  /dev/md126p4: LABEL="OS" UUID="<UUID>" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="<PARTUUID>"
  /dev/md126p5: LABEL="Data" UUID="<UUID>" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="<PARTUUID>"
  /dev/md126p6: UUID="<UUID>" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="<PARTUUID>"
  /dev/md126p7: LABEL="Restore" UUID="<UUID>" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="<PARTUUID>"
  ```

  `sd` stands for [SCSI disk drive driver](https://linux.die.net/man/4/sd). [SCSI](https://en.wikipedia.org/wiki/SCSI) (Small Computer System Interface) is a set of standards for physically connecting and transferring data between computers and peripheral devices.

  `md` stands for [multi device driver](https://linux.die.net/man/4/md), and represent the virtual RAID disk.

  `p` stands for partition.

  `isw_raid_member` refers to Intel firmware RAID as opposed to `linux_raid_member` which refers to Linux Software RAID.

  Linux detects two 238.5G physical drives "sda" and "sdb" that are virtually grouped under a RAID 0 "md126". The partition to format is "md126p6".

* Format the partition

  See [mkfs](https://linux.die.net/man/8/mkfs)

  The created Linux file system type will be [ext4](https://en.wikipedia.org/wiki/Ext4) (Fourth Extended Filesystem): it is the most commonly used file system on Linux distributions. There exists [many more](https://wiki.archlinux.org/index.php/File_systems).

  ```bash
  > mkfs --type=ext4 /dev/md126p6
  ```

  Optionally, you can create a [swap](https://wiki.archlinux.org/index.php/swap) partition, used by the operating system as a "hard disk extension" of the RAM (Random Access Memory) to optimize memory management. Indeed, thanks to [paging](https://en.wikipedia.org/wiki/Paging), memory addresses are mapped to memory pages, instead of being translated directly to physical memory. This allows the operating system to swap pages in and out of physical RAM in order to handle more memory than what is physically available and to only keep actively used pages mapped to physical memory while the others would be moved to the swap partition.

* Mount all relevant partitions: 
  
  We use the output from `blkid` above to identify each partition:
    
    * the Linux partition: "md126p6"
    * the [ESP](https://en.wikipedia.org/wiki/EFI_system_partition) (EFI System partition): "md126p1"

      What is an ESP?

      > When a computer is booted, UEFI firmware loads files stored on the ESP to start installed operating systems and various utilities. An ESP contains the boot loaders or kernel images for all installed operating systems (which are contained in other partitions), device driver files for hardware devices present in a computer and used by the firmware at boot time, system utility programs that are intended to be run before an operating system is booted, and data files such as error logs.
      > 
      > \- Wikipedia

    * the Windows partition: "md126p4"

  ```bash
  > mount /dev/md126p6 /mnt # Mount the Linux partition
  > mount /dev/md126p1 /mnt/boot # Mount the ESP
  > mount /dev/md126p4 /mnt/windows # Mount the Windows partition
  ```
  
### Installation

* Select the mirror closest to your location (United State in this case)

  ```bash
  > vim /etc/pacman.d/mirrorlist # edit mirror list
  > /United + Enter # search for "United" 
  > Shit + v # select whole line
  > <Down arrow> # select line below
  > :m 6 # move both lines to 6th line (i.e. at the top of mirror list)
  ```

* Install Arch Linux [base](https://www.archlinux.org/groups/x86_64/base/) package using the [pacstrap script](https://git.archlinux.org/arch-install-scripts.git/tree/pacstrap.in) 

  ```bash
  > pacstrap /mnt base
  ```

### Configuration

* Persist mounted partitions using the [genfstab script](https://git.archlinux.org/arch-install-scripts.git/tree/genfstab.in)

  The partitions will be persisted in a file called [fstab](https://en.wikipedia.org/wiki/Fstab) (File System Table).

  ```bash
  > genfstab -U /mnt >> /mnt/etc/fstab # persist mounted partitions
  > cat /mnt/etc/fstab # check it has been correctly generated
  # Static information about the filesystems.
  # See fstab(5) for details.

  # <file system> <dir> <type> <options> <dump> <pass>

  # /dev/md126p6
  UUID=<UUID>     /         	ext4      	rw,relatime,stripe=64,data=ordered	0 1

  # /dev/md126p1 LABEL=SYSTEM
  UUID=<UUID>     /boot     	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro	0 2

  # /dev/md126p4 LABEL=OS
  UUID=<UUID>	    /windows  	ntfs      	ro,relatime,uid=0,gid=0,fmask=0177,dmask=077,nls=utf8,errors=continue,mft_zone_multiplier=1	0 0
  ```

* Change root using the [arch-chroot script](https://git.archlinux.org/arch-install-scripts.git/tree/arch-chroot.in)

  [Chroot](https://wiki.archlinux.org/index.php/change_root) (Change Root) is an operation that changes the apparent root directory for the current running process and their children. 

  ```
  arch-chroot /mnt
  ```

* Configure time and timezone

  There are two clocks: the system clock managed in-memory by the operating system and the hardware clock (aka RTC for Real-Time Clock) a physical clock powered by a battery. At boot time, the system clock initial value is set from the hardware clock.

  We also want to make sure that we synchronize the clocks with [NTP servers](https://en.wikipedia.org/wiki/Network_Time_Protocol) (Network Time Protocol). By default, Linux connect to servers from the [NTP Pool Project](http://www.pool.ntp.org/) and calls are made at a regular intervals over UDP via port 123 (Check file `/etc/systemd/timesyncd.conf` for configuration).

  ```bash
  > timedatectl set-ntp true # Synchronize clock with NTP server
  > timedatectl set-timezone America/New_York # Set correct time zone. Equivalent to 'ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime'
  > hwclock --systohc # Set the Hardware Clock to the current System Time.
  > timedatectl status # Check date & time are correct
                          Local time: Mon 2018-05-07 23:46:59 EDT
                    Universal time: Tue 2018-05-08 03:46:59 UTC
                          RTC time: Tue 2018-05-08 03:46:59
                        Time zone: America/New_York (EDT, -0400)
        System clock synchronized: yes
  systemd-timesyncd.service active: yes
                  RTC in local TZ: no
  ```

  It is recommended to keep the hardware clock in Coordinated Universal Time (UTC) rather than local time: i.e. Universal and RTC time should be equal. Most operating system considers the hardware clock to be UTC except Windows for [ridiculous compatibility reasons and supposedly to avoid confusing users when setting time via bios (!)](https://blogs.msdn.microsoft.com/oldnewthing/20040902-00/?p=37983).

  The [Arch Linux wiki](https://wiki.archlinux.org/index.php/time#Time_standard) explains well the drawbacks of using local time for hardware clock:

  >If multiple operating systems are installed on a machine, they will all derive the current time from the same hardware clock: it is recommended to adopt a unique standard for the hardware clock to avoid conflicts across systems and set it to UTC. Otherwise, if the hardware clock is set to localtime, more than one operating system may adjust it after a DST change for example, thus resulting in an over-correction; problems may also arise when traveling between different time zones and using one of the operating systems to reset the system/hardware clock.

  To have Windows consider the hardware clock as UTC, do the following:

  * In the registry, under `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`, add a key `RealTimeIsUniversal` with a value `00000001` of type `dword`
  * Disable Windows Time Service by running this command: `sc config w32time start= disabled`

  See the explanation from the [Ubuntu wiki](https://help.ubuntu.com/community/UbuntuTime#Multiple_Boot_Systems_Time_Conflicts)

* Upgrade the whole system:

  [pacman](https://www.archlinux.org/pacman/pacman.8.html) is Arch Linux package manager, configured via `/etc/pacman.conf`. There is only one command needed to update the whole system:

  ```bash
  > pacman -Syu
  ```
  where:

  * `S` or `sync`: operation to install packages.
  * `y` or `refresh`: option to download a fresh copy of the master package database from the servers defined in pacman.conf.
  * `u` or `sysupgrade`: option to upgrade all currently-installed packages that are out-of-date.

* Install Vim

  We will use Vim later on to edit configuration files. It is a best practice to update the system before installing new packages to avoid incompatibilities.

  ```bash
  > pacman -Syu vim
  ```

# General Tips

## Enter UEFI/BIOS configuration:

* select `Windows menu key > Power > Hold Shift + Restart`.

* then select `Troubleshoot > Advanced Options > UEFI Firmware Settings`.

  <img src="./dual-boot-windows-10-asus-UX301LAA/restart-choose-an-option.png" alt="restart choose an option" height="300px"/>
  <img src="./dual-boot-windows-10-asus-UX301LAA/restart-troubleshoot.png" alt="restart troubleshoot" height="300px"/>
  <br/>
  <img src="./dual-boot-windows-10-asus-UX301LAA/restart-advanced-options.png" alt="restart advanced options" height="300px"/>

See [How to enter BIOS configuration?](https://www.asus.com/support/faq/1013015/) or [How to Access UEFI BIOS in Windows 10](https://www.cocosenor.com/articles/windows-10/access-uefi-bios-in-windows-10.html) for alternative methods.
