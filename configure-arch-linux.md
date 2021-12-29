## Configure Arch Linux

### pacman

```bash
# Upgrade the whole system with pacman, Arch Linux package manager
# - `S` or `sync`: operation to install packages
# - `y` or `refresh`: option to download a fresh copy of the master package database from the servers defined in pacman.conf
# - `u` or `sysupgrade`: option to upgrade all currently-installed packages that are out-of-date
# See https://www.archlinux.org/pacman/pacman.8.html
pacman -Syu

# Configure pacman via `/etc/pacman.conf`
# - uncomment "Color" option
# - uncomment "multilib" section for 32 bit applications support
```

### GRUB

```bash
# Install GRUB theme from https://github.com/vandalsoul/darkmatter-grub2-theme/
cd /tmp
git clone --depth 1 https://github.com/vandalsoul/darkmatter-grub2-theme.git
cd darkmatter-grub2-theme
sudo python3 install.py

# Add missing grub icons
cd /boot/grub/theme/dark-theme/icons
cp help.png usb.png

# Add missing class `--class efi` next to `menuentry`
vim /etc/grub.d/30_uefi-firmware

# Ensure theme is correctly setup by rebooting
reboot
```

## Setup AUR: Yay

```bash
# Install Yay https://github.com/Jguer/yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Setup shell: Zsh

```bash
pacman -S zsh

# make it default shell
chsh -s /usr/bin/zsh

# install oh-my-zsh
yay -S oh-my-zsh-git
/usr/share/oh-my-zsh/tools/install.sh

# Add plugin https://github.com/zsh-users/zsh-autosuggestions
pacman -S zsh-autosuggestions
ln -s /usr/share/zsh/plugins/zsh-autosuggestions .oh-my-zsh/custom/plugins/

# Add plugin https://github.com/zsh-users/zsh-syntax-highlighting
pacman -S zsh-syntax-highlighting
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting .oh-my-zsh/custom/plugins/

# edit .zshrc & add the following plugins
# plugins=(
#   git
#	  sudo
#	  zsh-autosuggestions
#	  zsh-syntax-highlighting
# )
vim .zshrc

# Add additional site functions completion https://github.com/zsh-users/zsh-completions
pacman -S zsh-completions

# theme https://github.com/romkatv/powerlevel10k
pacman -S zsh-theme-powerlevel10k
ln -s /usr/share/zsh-theme-powerlevel10k .oh-my-zsh/custom/themes/

# edit .zshrc & add the following theme
# ZSH_THEME="zsh-theme-powerlevel10k/powerlevel10k"
vim .zshrc

source .zshrc
```

## Spice up shell

```bash
# install https://github.com/nvbn/thefuck
pacman -S thefuck
# edit .zshrc & add the following
# eval $(thefuck --alias)
vim .zshrc

# install https://github.com/rupa/z
pacman -S z
# edit .zshrc & add the following
# [[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh
vim .zshrc

# install https://github.com/sharkdp/bat
pacman -S bat
```

### Setup Xorg

```bash
# check graphic card
lspci|grep -i VGA

# install relevant driver. ex for intel:
pacman -S xf86-video-intel

# install Xorg
pacman -S xorg-server xorg-xinit
# allow rootless Xorg by editing/creating the following file & content
# needs_root_rights = no
vim /etc/X11/Xwrapper.config
```

- Install Xorg server
  - https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
    - fr / latin9 / asus_laptop / caps:shiftlock
    - fix delete return ~ + nice console shortcuts? https://www.linuxquestions.org/questions/linux-general-1/insert-and-delete-key-returns-~-in-a-terminal-876401/
  - dpi 120
  - xrandr --output <output> --mode <mode>
  - driver touchpad
  
### Setup i3

```bash
# install i3 with gaps + compositor for transparency
pacman -S i3-gaps picom

# Copy xinitrc template
cp /etc/X11/xinit/xinitrc ~/.xinitrc
# Replace "start some nice programs here" section with the following:
# exec i3 -V >> /tmp/i3log-$(date + '%F-%k-%M-%S') 2>&1
vim .xinitrc

# Copy xserverrc template
cp /etc/X11/xinit/xserverrc ~/.xserverrc
# Replace the main exec line with:
# exec /usr/bin/X -nolisten tcp "$@" vt$XDG_VTNR
vim .xserverrc
```

  - https://github.com/CSaratakij/i3wm-desktop-config
  - wallpaper feh
    `mkdir -p pictures/wallpapers`
    `cp backgrounds/* pictures/wallpapers`
  - pacman -Syu xautolock
  - pacman -R i3lock
  - pacaur -S i3lock-color
  - pacaur -S i3-battery-popup-git
  - rofi
  - pacman -S conky
    - own_window_transparent=true
    - own_window = true,
    - own_window_type = 'override',
    - https://github.com/madhur/awesome-conky
    - https://github.com/zenzire/conkyrc
    - https://blog.desdelinux.net/dmenu-un-lanzador-de-aplicaciones-ultra-ligero/
  
### Setup terminal emulator: Kitty

```bash
pacman -S kitty
# create template config file by hitting ctrl+shift+f2

# re-run powerlevel10k config
p10k config

# add font
yay -S ttf-meslo-nerd-font-powerlevel10k

# configure kitty font and add the following line to it:
# font_family MesloLGS NF
vim ~/.config/kitty/kitty.conf
```

### Others

- chromium
  - choose font: ttf_liberation
  - choose: libx264
  - update downloads folder to lower case: "downloads"
  - extensions: lastpass + ghostery
- git
  - pacman -Syu openssh + https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
  - add key github
  - git clone git@...
- pacaur -Syu visual-studio-code-bin
  - extensions: prettier + gitlens
  - settings:
  ```json
  {
    "editor.formatOnSave": true,
    "workbench.editor.enablePreview": false,
    "javascript.validate.enable": false
  }
  ```
- pacaur -Syu slack-desktop
- pacman -Syu python2 nodejs npm yarn
- pacman -Syu feh gimp imagemagick + peek # image viewer + editor + converter + gif maker
- pacman -Syu wget unzip # alternative to curl + unzip
- pacman -Syu youtube-dl # video converter

- sound:

  - pacman -S alsa-utils
  - gpasswd -a jbe audio #logout/login to take group changes into effect
  - pacman -Syu pulseaudio pavucontrol
  - cp default.pa ./.config/pulse/default.pa
  - vim /etc/modprobe.d/alsa-base.conf
    options snd_hda_intel enable=1 index=0
    options snd_hda_intel enable=0 index=1

- webcam

  - check `uvcvideo` is loaded with `lsmod|grep uvc`
  - check available devices `v4l2-ctl --list-devices`
  - pacman -S zvbi #for vlc
  - usermod -aG video jbe #logout/login to take group changes into effect

- backlight

  - sudo tee /sys/class/backlight/intel_backlight/brightness <<< 50

- remote desktop:

  - pacman -Syu remmina freerdp

- printer

  Install CUPS to manage printers

  - pacman -S cups cups-pdf
  - systemctl enable org.cups.cupsd.service
  - systemctl start org.cups.cupsd.service

  Install Avahi to detect netwrok printers

  - pacman -S nss-mdns
  - systemctl enable avahi-daemon.service
  - systemctl start avahi-daemon.service
  - sudo vim /etc/nsswitch.conf
  - change the hosts line to include mdns_minimal [NOTFOUND=return] before resolve and dns

  Create a printer queue:

  - List the devices: `sudo lpinfo -v`

    From [Using Network Printers - CUPS.org](https://www.cups.org/doc/network.html):

    > Most network printers support a protocol known as Bonjour, which is a combination of zero-configuration networking ("ZeroConf"), multicast DNS (mDNS), and DNS service discovery (DNS-SD) standards published by the Internet Engineering Task Force (IETF)
    > A printer that supports Bonjour can be found automatically using the dnssd backend

    DNS-SD or DNS-Based Service Discovery is a protocol that allows clients to find services on their local network like networked printers, without needing a central directory or any manual configuration.

    There are different network protocols which provide more or less control over the printer, including:

    - `socket`: The AppSocket protocol or JetDirect protocol is the simplest, fastest, and generally the most reliable network protocol used for printers. AppSocket printing normally happens over port 9100 and uses the socket backend.
    - `ipp`: Internet Printing Protocol. IPP is the only protocol that CUPS supports natively and is supported by most network printers and print servers. IPP supports encryption and other security features over port 631 and uses the http (Windows), ipp, and ipps backends.

    Example of output with one HP network printer supporting both `socket` and `ipp` protocols (each is listed twice, via the dnssd and its resolved address):

    ```
    network beh
    network lpd
    file cups-pdf:/
    network ipp
    network http
    network https
    network ipps
    network socket
    network dnssd://HP%20ENVY%205640%20series%20%5BE5A506%5D._ipp._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-d0bf9ce5a506
    network dnssd://HP%20ENVY%205640%20series%20%5BE5A506%5D._pdl-datastream._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-d0bf9ce5a506
    network socket://192.168.1.10:9100
    network ipp://HPD0BF9CE5A506.local:631/ipp/print
    ```

  - List the models: `lpinfo -m`

  List available PostScript Printer Definition (PPD) files/drivers.

  ```
  lsb/usr/cupsfilters/Fuji_Xerox-DocuPrint_CM305_df-PDF.ppd Fuji Xerox
  drv:///sample.drv/dymo.ppd Dymo Label Printer
  drv:///sample.drv/epson9.ppd Epson 9-Pin Series
  drv:///sample.drv/epson24.ppd Epson 24-Pin Series
  drv:///generic-brf.drv/gen-brf.ppd Generic Braille embosser, 1.0
  CUPS-PDF_noopt.ppd Generic CUPS-PDF Printer (no options)
  CUPS-PDF_opt.ppd Generic CUPS-PDF Printer (w/ options)
  drv:///cupsfilters.drv/pwgrast.ppd Generic IPP Everywhere Printer
  drv:///sample.drv/generpcl.ppd Generic PCL Laser Printer
  lsb/usr/cupsfilters/Generic-PDF_Printer-PDF.ppd Generic PDF Printer
  drv:///sample.drv/generic.ppd Generic PostScript Printer
  drv:///cupsfilters.drv/textonly.ppd Generic Text-Only Printer
  drv:///generic-ubrl.drv/gen-ubrl.ppd Generic UBRL generator, 1.0
  lsb/usr/cupsfilters/HP-Color_LaserJet_CM3530_MFP-PDF.ppd HP Color LaserJet CM3530 MFP PDF
  lsb/usr/cupsfilters/pxlcolor.ppd HP Color LaserJet Series PCL 6 CUPS
  drv:///cupsfilters.drv/dsgnjt600pcl.ppd HP DesignJet 600 pcl, 1.0
  drv:///cupsfilters.drv/dsgnjt750cpcl.ppd HP DesignJet 750c pcl, 1.0
  drv:///cupsfilters.drv/dsgnjt1050cpcl.ppd HP DesignJet 1050c pcl, 1.0
  drv:///cupsfilters.drv/dsgnjt4000pcl.ppd HP DesignJet 4000 pcl, 1.0
  drv:///cupsfilters.drv/dsgnjtt790pcl.ppd HP DesignJet T790 pcl, 1.0
  drv:///cupsfilters.drv/dsgnjtt1100pcl.ppd HP DesignJet T1100 pcl, 1.0
  drv:///sample.drv/deskjet.ppd HP DeskJet Series
  driverless:ipp://HPD0BF9CE5A506.local:631/ipp/print HP ENVY 5640 series, driverless, cups-filters 1.20.4
  drv:///sample.drv/laserjet.ppd HP LaserJet Series PCL 4/5
  lsb/usr/cupsfilters/pxlmono.ppd HP LaserJet Series PCL 6 CUPS
  drv:///indexv3.drv/i4waves3.ppd Index 4-Waves PRO, 1.0
  drv:///indexv3.drv/i4x4pro3.ppd Index 4x4 PRO V3, 1.0
  drv:///indexv3.drv/ibasicd3.ppd Index Basic-D V3, 1.0
  drv:///indexv4.drv/ibasicd4.ppd Index Basic-D V4/V5, 1.0
  drv:///indexv3.drv/ibasics3.ppd Index Basic-S V3, 1.0
  drv:///indexv4.drv/ibasics4.ppd Index Basic-S V4/V5, 1.0
  drv:///indexv4.drv/ibrlbox4.ppd Index Braille Box V4/V5, 1.0
  drv:///indexv3.drv/ieveres3.ppd Index Everest-D V3, 1.0
  drv:///indexv4.drv/ieveres4.ppd Index Everest-D V4/V5, 1.0
  drv:///sample.drv/intelbar.ppd Intellitech IntelliBar Label Printer, 2.1
  drv:///sample.drv/okidata9.ppd Oki 9-Pin Series
  drv:///sample.drv/okidat24.ppd Oki 24-Pin Series
  raw Raw Queue
  lsb/usr/cupsfilters/Ricoh-PDF_Printer-PDF.ppd Ricoh PDF Printer
  drv:///sample.drv/zebracpl.ppd Zebra CPCL Label Printer
  drv:///sample.drv/zebraep1.ppd Zebra EPL1 Label Printer
  drv:///sample.drv/zebraep2.ppd Zebra EPL2 Label Printer
  drv:///sample.drv/zebra.ppd Zebra ZPL Label Printer
  everywhere IPP Everywhere
  ```

  - Adda new queue: `sudo lpadmin -p hp-envy-5640 -E -v "dnssd://HP%20ENVY%205640%20series%20%5BE5A506%5D._ipp._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-d0bf9ce5a506" -m "driverless:ipp://HPD0BF9CE5A506.local:631/ipp/print"`
  - check list of queues: `lpstat -a | cut -f1 -d ' '`

- setup backlight: pacman -S upower python-dbus
  `dbus-send --system --type=method_call --dest="org.freedesktop.UPower" "/org/freedesktop/UPower/KbdBacklight" "org.freedesktop.UPower.KbdBacklight.SetBrightness" int32:100`
- detect usb keys
