## Install Arch Linux

These steps are mainly inspired from [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)

### Boot from USB

1.  Insert USB key
1.  Enter [UEFI/BIOS configuration](./general-tips.md#enter-uefibios-configuration)
1.  Boot on the USB: select the USB media to boot from or change the boot sequence to place the USB media first
1.  Exit and save.
1.  Upon restart, select the "Arch Linux" entry.

### Setup USB

- (Optional) Configure the keyboard layout. Example for french AZERTY: `loadkeys fr`. See [Keyboard configuration in console](https://wiki.archlinux.org/index.php/Keyboard_configuration_in_console)

- (Optional) Connect to the internet with Ethernet or Wifi. See [Wireless network configuration](https://wiki.archlinux.org/title/Network_configuration/Wireless)

  ```console
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

### Prepare partition


- Identify disk and partitions using [fdisk](https://linux.die.net/man/8/fdisk), [lsblk](https://linux.die.net/man/8/lsblk) and [blkid](https://linux.die.net/man/8/blkid). See [understand lsblk and blkid output](./general-tips.md#lsblk-and-blkid-output).

  - If you have a RAID, see [how to get more info about it](./general-tips.md#get-info-about-raid).
  - If your partition is not listed by `blkid` or `lsblk`, see [how to troubleshoot missing partition](./general-tips.md#partitiondisk-not-visible).

- Create partitions with `fdisk`. Example:

  - EFI system partition, 512M: `/dev/efi_system_partition`
  - Linux swap, 1G `/dev/swap_partition`
  - Linux x86-64 root, remaining `/dev/root_partition`

    What is an [ESP](https://en.wikipedia.org/wiki/EFI_system_partition)?

    > When a computer is booted, UEFI firmware loads files stored on the ESP to start installed operating systems and various utilities. An ESP contains the boot loaders or kernel images for all installed operating systems (which are contained in other partitions), device driver files for hardware devices present in a computer and used by the firmware at boot time, system utility programs that are intended to be run before an operating system is booted, and data files such as error logs.
    >
    > \- Wikipedia

- Format the partition with `mkfs.vfat` for the EFI partition, `mkswap` for the swap partition and `mkfs.ext4` for the root partition. See [mkfs](https://linux.die.net/man/8/mkfs)

The created Linux root partition file system type will be [ext4](https://en.wikipedia.org/wiki/Ext4) (Fourth Extended Filesystem): it is the most commonly used file system on Linux distributions. There exists [many more](https://wiki.archlinux.org/index.php/File_systems).

The [swap](https://wiki.archlinux.org/index.php/swap) partition, is used by the operating system as a "hard disk extension" of the RAM (Random Access Memory) to optimize memory management. Indeed, thanks to [paging](https://en.wikipedia.org/wiki/Paging), memory addresses are mapped to memory pages, instead of being translated directly to physical memory. This allows the operating system to swap pages in and out of physical RAM in order to handle more memory than what is physically available and to only keep actively used pages mapped to physical memory while the others would be moved to the swap partition.

### Install Arch Linux

- Select the mirror closest to your location (United State in this case)

  ```console
  > vim /etc/pacman.d/mirrorlist # edit mirror list
  > /United + Enter # search for "United"
  > Shit + v # select whole line
  > <Down arrow> # select line below
  > :m 6 # move both lines to 6th line (i.e. at the top of mirror list)
  ```

- Install Arch Linux [base](https://www.archlinux.org/groups/x86_64/base/) and [base-devel](https://www.archlinux.org/groups/x86_64/base-devel/) packages using the [pacstrap script](https://git.archlinux.org/arch-install-scripts.git/tree/pacstrap.in)

  ```console
  > pacstrap /mnt base base-devel linux linux-firmware
  ```

- Mount all relevant partitions with `mount`

  ```console
  > mount /dev/<linux-partition> /mnt # Mount the Linux partition
  > mkdir /mnt/efi
  > mount /dev/<esp> /mnt/efi # Mount the ESP
  > mkdir /mnt/windows
  > mount /dev/<windows-partition> /mnt/windows # Mount the Windows partition
  ```
  
- Enable swap with `swapon`

- Persist mounted partitions using the [genfstab script](https://git.archlinux.org/arch-install-scripts.git/tree/genfstab.in)

  The partitions will be persisted in a file called [fstab](https://en.wikipedia.org/wiki/Fstab) (File System Table).

  ```console
  > genfstab -U /mnt >> /mnt/etc/fstab # persist mounted partitions
  > cat /mnt/etc/fstab # check it has been correctly generated
  # Static information about the filesystems.
  # See fstab(5) for details.

  # <file system> <dir> <type> <options> <dump> <pass>

  # /dev/<linux-partition>
  UUID=<UUID>     /         	ext4      	rw,relatime,stripe=64,data=ordered	0 1

  # /dev/<esp> LABEL=SYSTEM
  UUID=<UUID>     /boot     	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro	0 2

  # /dev/<windows-partition> LABEL=OS
  UUID=<UUID>	    /windows  	ntfs      	ro,relatime,uid=0,gid=0,fmask=0177,dmask=077,nls=utf8,errors=continue,mft_zone_multiplier=1	0 0
  ```

### Minimalist installation

- Change root using the [arch-chroot script](https://git.archlinux.org/arch-install-scripts.git/tree/arch-chroot.in)

  [Chroot](https://wiki.archlinux.org/index.php/change_root) (Change Root) is an operation that changes the apparent root directory for the current running process and their children.

  ```
  arch-chroot /mnt
  ```

- Set the root password

  ```console
  > passwd
  ```

- Configure the bootloader

  - Backup the ESP (EFI System partition). See [tar](https://linux.die.net/man/1/tar) with the options to create `c` a gzipped archive `z`:

    ```console
    > mkdir /esp-backup
    > tar cfz /esp-backup/esp-backup.tar.gz /efi/
    ```
    
  - (Optional) Regenerate the initial ramdisk archive `mkinitcpio -p linux`

    The command to create the initial ramdisk environment for booting the linux kernel is called `mkinitcpio` (for "Make Initial CPIO"): each "initial ramdisk" is generated as an image file available on the ESP when loading Linux. `cpio` is similar to `tar`: it creates an uncompress archive. By default, the initial ramdisk archived are compressed using GZIP (see `/etc/mkinitcpio.conf`) and have the `.img` extension.

    By default, `mkinitcpio` generates a default and a fallback image. The first one select the modules to load while the latter loads all modules at startup to make sure the system will start. 

  - Install GRUB

    [GRUB](https://www.gnu.org/software/grub/) (GRand Unified Bootloader) is a multiboot boot loader.

    > A boot loader is the first program that runs when a computer starts. It is responsible for selecting, loading and transferring control to an operating system kernel. The kernel, in turn, initializes the rest of the operating system.
    >
    > - Arch Linux Wiki

    1.  Install:

        - `grub`: the multiboot boot loader.
        - `efibootmgr`: manipulates the boot manager and creates bootable .efi stub entries used by the GRUB installation script.
        - `intel-ucode`: this is a [microcode](https://wiki.archlinux.org/index.php/microcode) that provides updates and bugfixes on Intel processor. It will be loaded at startup by the GRUB config.

        ```console
        > pacman -Syu grub efibootmgr intel-ucode
        ```

    1.  Execute the following command to install the GRUB UEFI application `grubx64.efi` to `/efi/grub` and install its modules to `/boot/grub/x86_64-efi/`.

        ```console
        > grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub
        ```

    1.  Edit `/etc/default/grub`:

    - Remove the "Advanced Options" submenu: add `GRUB_DISABLE_SUBMENU=y`
    - Setup the `arch-dark` theme: copy ./config/gub/dark-theme content into /boot/grub/themes and edit the grub config file as follow:
      ```ini
      GRUB_THEME="/boot/grub/themes/arch-dark/theme.txt"
      # if one need to set a different resolution, use 'videoinfo' command in GRUB shell to get the list of supported GFX mode
      #GRUB_GFXMODE=1920x1440x32,auto
      #GRUB_GFXPAYLOAD_LINUX=keep
      ```

    1.  Rename GRUB menu entries:

    By default, Arch Linux will appear as "Arch Linux, with Linux linux". To make it appears as "Arch Linux", update /etc/grub.d/10_linux:

    ```diff
    @@ -82,11 +82,11 @@ linux_entry ()
      if [ x$type != xsimple ] ; then
          case $type in
              recovery)
    -             title="$(gettext_printf "%s, with Linux %s (recovery mode)" "${os}" "${version}")" ;;
    +             title="$(gettext_printf "%s (recovery mode)" "${os}")" ;;
              fallback)
    -             title="$(gettext_printf "%s, with Linux %s (fallback initramfs)" "${os}" "${version}")" ;;
    +             title="$(gettext_printf "%s (fallback initramfs)" "${os}")" ;;
              *)
    -             title="$(gettext_printf "%s, with Linux %s" "${os}" "${version}")" ;;
    +             title="$(gettext_printf "%s" "${os}")" ;;
          esac
          if [ x"$title" = x"$GRUB_ACTUAL_DEFAULT" ] || [ x"Previous Linux versions>$title" = x"$GRUB_ACTUAL_DEFAULT" ]; then
              replacement_title="$(echo "Advanced options for ${OS}" | sed 's,>,>>,g')>$(echo "$title" | sed 's,>,>>,g')"
    ```

    1.  Add additional entries to the GRUB menu:

        ```console
        > vim /boot/grub/custom.cfg
        ```

        And insert the content below to have the following entries:

        - a windows startup
        - a UEFI
        - a shutdown
        - a restart

        ```bash
        menuentry "Microsoft Windows 10" --class windows --class os {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root <ESP UUID>
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }

        menuentry "USB" --class usb {
          set root=(hd1,1)
          chainloader +1
          boot
        }

        menuentry "Firmware setup" --class settings {
          fwsetup
        }

        menuentry "Shutdown" --class shutdown {
          echo "System shutting down..."
          halt
        }

        menuentry "Restart" --class restart {
          echo "System rebooting..."
          reboot
        }
        ```

        Where `<ESP UUID>` is to replace with the UUID of the ESP obtained via `sudo blkid /dev/<esp>`

    1.  Generate GRUB config:

        ```console
        > grub-mkconfig -o /boot/grub/grub.cfg
        ```

        It will automatically detect the microcode `intel-ucode` and add the relevant instructions in the `grub.cfg` file.

NB: If the PC uses a firmware RAID, we need to make sure the initial ramdisk archive loads the `mdadm_udev` module, which is a utility to manage firmware/software RAID configurations.

1.  Edit `/etc/mkinitcpio.conf` and add `mdadm_udev` to the list of HOOKS:

    ```bash
    HOOKS=(base udev autodetect modconf block mdadm_udev filesystems keyboard fsck)
    ```

1.  Regenerate the initial ramdisk archive using `mkinitcpio -p linux`

See [Intel RAID and Arch Linux](https://blog.ironbay.co/intel-raid-and-arch-linux-8dcd508354d3) for more details

- Install wifi/ethernet tools

  In order for the new partition to be autonomous, we must make sure that we can connect to wifi before rebooting.

  ```console
  > pacman -Syu iw dialog wpa_supplicant wifi-menu dhcpcd
  ```

- Reboot the machine and make sure GRUB correctly displays with all the desired options

  ```console
  > exit # exit arch-chroot
  > shutdown -r now
  ```

### Configure Arch Linux

- Configure time and timezone

  There are two clocks: the system clock managed in-memory by the operating system and the hardware clock (aka RTC for Real-Time Clock) a physical clock powered by a battery. At boot time, the system clock initial value is set from the hardware clock.

  We also want to make sure that we synchronize the clocks with [NTP servers](https://en.wikipedia.org/wiki/Network_Time_Protocol) (Network Time Protocol). By default, Linux connect to servers from the [NTP Pool Project](http://www.pool.ntp.org/) and calls are made at a regular intervals over UDP via port 123 (Check file `/etc/systemd/timesyncd.conf` for configuration).

  ```console
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

  > If multiple operating systems are installed on a machine, they will all derive the current time from the same hardware clock: it is recommended to adopt a unique standard for the hardware clock to avoid conflicts across systems and set it to UTC. Otherwise, if the hardware clock is set to localtime, more than one operating system may adjust it after a DST change for example, thus resulting in an over-correction; problems may also arise when traveling between different time zones and using one of the operating systems to reset the system/hardware clock.

  To have Windows consider the hardware clock as UTC, do the following:

  - In the registry, under `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`, add a key `RealTimeIsUniversal` with a value `00000001` of type `dword`
  - Disable Windows Time Service by running this command: `sc config w32time start= disabled`

  See the explanation from the [Ubuntu wiki](https://help.ubuntu.com/community/UbuntuTime#Multiple_Boot_Systems_Time_Conflicts)

* Upgrade the whole system:

  [pacman](https://www.archlinux.org/pacman/pacman.8.html) is Arch Linux package manager, configured via `/etc/pacman.conf`. There is only one command needed to update the whole system:

  ```console
  > pacman -Syu
  ```

  where:

  - `S` or `sync`: operation to install packages.
  - `y` or `refresh`: option to download a fresh copy of the master package database from the servers defined in pacman.conf.
  - `u` or `sysupgrade`: option to upgrade all currently-installed packages that are out-of-date.

* Install Vim

  We will use Vim later on to edit configuration files. It is a best practice to update the system before installing new packages to avoid incompatibilities.

  We install `gvim` instead of `vim` in order to have "copy to clipboard" working on X server (i.e. `vim --version` contains `+xterm_clipboard`). We will still use the `vim` command however.

  ```console
  > pacman -Syu gvim
  ```

* Configure the locale

  Locale names are typically of the form `language[_territory][.codeset][@modifier]`, where "language" is an [ISO 639](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) language code, "territory" is an [ISO 3166](https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes) country code, and "codeset" is a character set or encoding identifier.

  Here are the main characters sets:

  - [ASCII](https://en.wikipedia.org/wiki/ASCII): 7-bits char set (128 chars)
  - [ISO-8859-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1): a 8-bits/1 byte extended ASCII char set (256 chars) adding Latin characters to ASCII
  - [UTF-8](https://en.wikipedia.org/wiki/UTF-8): a variable width char set (1 to 4 bytes) encoding all Unicode characters

  Uncomment the desired locale, in this case `en_US.UTF8 UTF8`.

  ```console
  > vim /etc/locale.gen # edit locale file
  > /en_US + Enter # search for "en_US"
  > n # go to next occurence until you find your entry
  > i # enter in edit mode
  > <Suppr> # uncomment line
  ```

  - Generate the locale

  ```console
  > locale-gen
  ```

  - Set the system locale

  ```console
  > vim /etc/locale.conf LANG=en_US.UTF-8
  ```

  - Configure the keyboard layout

  To list all keyboard layouts related to French:

  ```console
  > localectl list-keymaps|grep fr #layout files can be listed using `ls /usr/share/kbd/keymaps/**/*.map.gz`
  dvorak-ca-fr
  dvorak-fr
  fr
  fr-bepo
  fr-bepo-latin9
  fr-latin1
  fr-latin9
  fr-pc
  fr_CH
  fr_CH-latin1
  mac-fr
  mac-fr_CH-latin1
  sunt5-fr-latin1
  ```

  To try a keyboard layout:

  ```console
  > loadkeys fr-latin9
  ```

  To compare the layouts:

  ```console
  > mkdir /tmp/layouts # create temporary directory
  > ls /usr/share/kbd/keymaps/**/*.map.gz|grep fr # locate layouts
  /usr/share/kbd/keymaps/i386/azerty/fr-latin1.map.gz
  /usr/share/kbd/keymaps/i386/azerty/fr-latin9.map.gz
  /usr/share/kbd/keymaps/i386/azerty/fr.map.gz
  /usr/share/kbd/keymaps/i386/azerty/fr-pc.map.gz
  /usr/share/kbd/keymaps/i386/bepo/fr-bepo-latin9.map.gz
  /usr/share/kbd/keymaps/i386/bepo/fr-bepo.map.gz
  /usr/share/kbd/keymaps/i386/dvorak/dvorak-ca-fr.map.gz
  /usr/share/kbd/keymaps/i386/dvorak/dvorak-fr.map.gz
  /usr/share/kbd/keymaps/i386/qwertz/fr_CH-latin1.map.gz
  /usr/share/kbd/keymaps/i386/qwertz/fr_CH.map.gz
  /usr/share/kbd/keymaps/mac/all/mac-fr_CH-latin1.map.gz
  /usr/share/kbd/keymaps/mac/all/mac-fr.map.gz
  /usr/share/kbd/keymaps/sun/sunt5-fr-latin1.map.gz
  > cp -t /tmp/layouts /usr/share/kbd/keymaps/i386/azerty/fr.map.gz /usr/share/kbd/keymaps/i386/azerty/fr-latin9.map.gz /usr/share/kbd/keymaps/i386/azerty/fr-latin1.map.gz # copy over the layouts
  > cd /tmp/layouts
  > gunzip *.gz # unzip
  > vim -d fr.map fr-latin1.map # compare fr with fr-latin1
  > vim -d fr-latin1.map fr-latin9.map # compare fr-latin1 with fr-latin9
  ```

  `fr` differs for several keys from a regular french keyboard. `fr-latin1` is following the [ISO-8859-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1) charset while `fr-latin9` is following the [ISO-8859-15](https://en.wikipedia.org/wiki/ISO/IEC_8859-15) charset. The latter introduces some characters such as [€](https://en.wikipedia.org/wiki/Euro_sign) and [Œ](https://en.wikipedia.org/wiki/%C5%92).

  To persist the keyboard layout:

  ```console
  > vim /etc/vconsole.conf KEYMAP=fr-latin9
  ```

* Configure Network

  - Define the hostname:

  ```console
  > vim /etc/hostname <hostname>
  ```

  - Create the `hosts` file via `vim /etc/hosts`

    ```
    127.0.0.1 localhost
    ::1 localhost
    127.0.1.1 <hostname>.localdomain <hostname>
    ```
