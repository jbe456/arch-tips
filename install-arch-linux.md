## Install Arch Linux

These steps are inspired from [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) and [Efficient Encrypted UEFI-Booting Arch Installation](https://gist.github.com/HardenedArray/31915e3d73a4ae45adc0efa9ba458b07)

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
  > iwctl # For wifi
  > [iwd] device list # Get the interface name
  > [iwd] station wlanX scan
  > [iwd] station wlanX get-networks
  > [iwd] station wlanX connect SSID
  > [iwd] exit
  > ping google.com # check internet
  ```

### Prepare partition

- Identify disk and partitions using [fdisk](https://linux.die.net/man/8/fdisk), [lsblk](https://linux.die.net/man/8/lsblk) and [blkid](https://linux.die.net/man/8/blkid). See [understand lsblk and blkid output](./general-tips.md#lsblk-and-blkid-output).

  - If you have a RAID, see [how to get more info about it](./general-tips.md#get-info-about-raid).
  - If your partition is not listed by `blkid` or `lsblk`, see [how to troubleshoot missing partition](./general-tips.md#partitiondisk-not-visible).

- Create partitions with `fdisk /dev/sdX`.

  Example for creating a new partition table (suitable for single boot):
  ```console
  p # Review partition table
  g # Create new empty GPT partition table
  
  n <Enter> <Enter> +100M # Add a new partition
  t 1 # Set type to EFI System
  
  n <Enter> <Enter> +250M # Add a new partition
  t <Enter> 4 # Set type to BIOS Boot
  
  n <Enter> <Enter> <Enter> # Add a new partition
  t <Enter> 23 # Set type to Linux root (x86-64)
  
  p # Review partition table
  w # Persist changes
  ```

  - EFI system partition, 100M: `/dev/sdXX`
  - BIOS boot partition, 250M: `/dev/sdXY`
  - Linux x86-64 root, remaining `/dev/sdXZ`

    What is an [ESP](https://en.wikipedia.org/wiki/EFI_system_partition)?

    > When a computer is booted, UEFI firmware loads files stored on the ESP to start installed operating systems and various utilities. An ESP contains the boot loaders or kernel images for all installed operating systems (which are contained in other partitions), device driver files for hardware devices present in a computer and used by the firmware at boot time, system utility programs that are intended to be run before an operating system is booted, and data files such as error logs.
    >
    > \- Wikipedia

- Format the partitions with `mkfs.vfat` for the EFI partition, `mkswap` for the swap partition and `mkfs.ext4` for the root partition. See [mkfs](https://linux.die.net/man/8/mkfs)

  ```console
  > mkfs.vfat /dev/sdXX
  > mkfs.ext4 /dev/sdXY
  ```

The created Linux root partition file system type will be [ext4](https://en.wikipedia.org/wiki/Ext4) (Fourth Extended Filesystem): it is the most commonly used file system on Linux distributions. There exists [many more](https://wiki.archlinux.org/index.php/File_systems).

- Encrypt the root partition and create swap & root sub partitions

```console
> cryptsetup -c aes-xts-plain64 -h sha512 -s 512 --use-random luksFormat /dev/sdXZ
> cryptsetup luksOpen /dev/sdX3 luks
> pvcreate /dev/mapper/luks
> vgcreate arch /dev/mapper/luks
> lvcreate -L +8G arch -n swap
> lvcreate -l +100%FREE arch -n root
```

- Format the root & swap partitions:

  ```console
  > mkfs.ext4 /dev/mapper/arch-root
  > mkswap /dev/mapper/arch-swap
  ```

The [swap](https://wiki.archlinux.org/index.php/swap) partition, is used by the operating system as a "hard disk extension" of the RAM (Random Access Memory) to optimize memory management. Indeed, thanks to [paging](https://en.wikipedia.org/wiki/Paging), memory addresses are mapped to memory pages, instead of being translated directly to physical memory. This allows the operating system to swap pages in and out of physical RAM in order to handle more memory than what is physically available and to only keep actively used pages mapped to physical memory while the others would be moved to the swap partition.

- Mount all relevant partitions with `mount`

  ```console
  > mount /dev/mapper/arch-root /mnt
  > swapon /dev/mapper/arch-swap
  > mkdir /mnt/boot
  > mount /dev/sdXY /mnt/boot
  > mkdir /mnt/boot/efi
  > mount /dev/sdXX /mnt/boot/efi
  # if dual boot
  > mkdir /mnt/windows
  > mount /dev/<windows-partition> /mnt/windows # Mount the Windows partition
  ```

### Install Arch Linux

- Select the mirror closest to your location (United State in this case)

  ```console
  > vim /etc/pacman.d/mirrorlist # edit mirror list
  > /United + Enter # search for "United"
  > Shit + v # select whole line
  > <Down arrow> # select line below
  > :m 6 # move both lines to 6th line (i.e. at the top of mirror list)
  ```

- Install required packages. For network configuration, we pick `networkmanager` over `netctl`, `dhcpcd` or `iwd`

  ```console
  > pacstrap /mnt base base-devel grub efibootmgr linux linux-firmware linux-headers intel-ucode networkmanager lvm2 gvim
  ```

  - `grub`: the multiboot boot loader.
  - `efibootmgr`: manipulates the boot manager and creates bootable .efi stub entries used by the GRUB installation script.
  - `intel-ucode`: this is a [microcode](https://wiki.archlinux.org/index.php/microcode) that provides updates and bugfixes on Intel processor. It will be loaded at startup by the GRUB config.
  - `networkmanager`: for network configuration over `netctl`, `dhcpcd` or `iwd`
  - `gvim`: instead of `vim` in order to have "copy to clipboard" working on X server (i.e. `vim --version` contains `+xterm_clipboard`).

- Persist mounted partitions using the [genfstab script](https://git.archlinux.org/arch-install-scripts.git/tree/genfstab.in)

  The partitions will be persisted in a file called [fstab](https://en.wikipedia.org/wiki/Fstab) (File System Table).

  ```console
  > genfstab -U /mnt >> /mnt/etc/fstab # persist mounted partitions
  > cat /mnt/etc/fstab # check it has been correctly generated
  ```

- Change root using the [arch-chroot script](https://git.archlinux.org/arch-install-scripts.git/tree/arch-chroot.in)

  [Chroot](https://wiki.archlinux.org/index.php/change_root) (Change Root) is an operation that changes the apparent root directory for the current running process and their children.

  ```
  arch-chroot /mnt
  ```

### Setup users

- Set the root password

  ```console
  > passwd
  ```
  
- Add a new user

  ```console
  > useradd -m -G wheel -s /bin/bash MyUserName
  > passwd MyUserName
  > EDITOR=vim visudo # Uncomment %wheel      ALL=(ALL) ALL
  ```

### Configure the bootloader

- Backup the ESP (EFI System partition) if needed. See [tar](https://linux.die.net/man/1/tar) with the options to create `c` a gzipped archive `z`:

  ```console
  > mkdir /esp-backup
  > tar cfz /esp-backup/esp-backup.tar.gz /mnt/boot/efi/
  ```
  
- Edit `/etc/mkinitcpio.conf` and add to the list of HOOKS:
   -  `keymap encrypt lvm2 resume` if encryption has been setup. Ex: `HOOKS=(base udev autodetect modconf block keymap encrypt lvm2 resume filesystems keyboard fsck)`
   -  `mdadm_udev` if the PC uses a firmware RAID (module to manage firmware/software RAID configurations). See [Intel RAID and Arch Linux](https://blog.ironbay.co/intel-raid-and-arch-linux-8dcd508354d3) for more details.

- Regenerate the initial ramdisk archive `mkinitcpio -p linux`

  The command to create the initial ramdisk environment for booting the linux kernel is called `mkinitcpio` (for "Make Initial CPIO"): each "initial ramdisk" is generated as an image file available on the ESP when loading Linux. `cpio` is similar to `tar`: it creates an uncompress archive. By default, the initial ramdisk archived are compressed using GZIP (see `/etc/mkinitcpio.conf`) and have the `.img` extension.

  By default, `mkinitcpio` generates a default and a fallback image. The first one select the modules to load while the latter loads all modules at startup to make sure the system will start. 

- Setup GRUB to install the GRUB UEFI application `grubx64.efi` to `/boot/efi/EFI/grub` and install its modules to `/boot/grub/x86_64-efi/`.
  
  ```console
  >grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
  ```
 
  [GRUB](https://www.gnu.org/software/grub/) (GRand Unified Bootloader) is a multiboot boot loader.

  > A boot loader is the first program that runs when a computer starts. It is responsible for selecting, loading and transferring control to an operating system kernel. The kernel, in turn, initializes the rest of the operating system.
  >
  > - Arch Linux Wiki

- Edit `/etc/default/grub`:

  - Edit the following line for encryption: `GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdXZ:luks resume=/dev/mapper/Arch-swap"`

- Generate GRUB config. It will automatically detect the microcode `intel-ucode` and add the relevant instructions in the `grub.cfg` file.

  ```console
  > grub-mkconfig -o /boot/grub/grub.cfg
  ```

### Reboot

- Reboot the machine and make sure GRUB correctly displays with all the desired options

  ```console
  > exit # exit arch-chroot
  > umount -R /mnt
  > swapoff -a
  > reboot
  ```

### Configure time and timezone

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

### Configure locale

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

  - Set the system locale & Generate the locale

  ```console
  > vim /etc/locale.conf # Content: LANG=en_US.UTF-8
  > locale-gen
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
  > vim /etc/vconsole.conf # Content: KEYMAP=fr-latin9
  ```

### Configure Network

- Define the hostname:

```console
> vim /etc/hostname # Content: <hostname>
```

- Start/Enable the NetworkManager & connect to a wifi

```console
# As a root
> systemctl enable NetworkManager.service
> systemctl start NetworkManager.service
# Connect to a wifi
> nmcli device wifi connect SSID_or_BSSID password password
```

### Others

- Upgrade the whole system:

  [pacman](https://www.archlinux.org/pacman/pacman.8.html) is Arch Linux package manager, configured via `/etc/pacman.conf`. There is only one command needed to update the whole system:

  ```console
  > pacman -Syu
  ```

  where:

  - `S` or `sync`: operation to install packages.
  - `y` or `refresh`: option to download a fresh copy of the master package database from the servers defined in pacman.conf.
  - `u` or `sysupgrade`: option to upgrade all currently-installed packages that are out-of-date.

- More GRUB config:
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
