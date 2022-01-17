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
vim /etc/pacman.conf
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

# edit .zshrc & disable auto updates
###########
# zstyle ':omz:update' mode disable
###########
vim .zshrc

# Add plugin https://github.com/zsh-users/zsh-autosuggestions
pacman -S zsh-autosuggestions
ln -s /usr/share/zsh/plugins/zsh-autosuggestions .oh-my-zsh/custom/plugins/

# Add plugin https://github.com/zsh-users/zsh-syntax-highlighting
pacman -S zsh-syntax-highlighting
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting .oh-my-zsh/custom/plugins/

# edit .zshrc & add the following plugins
###########
# plugins=(
#   git
#   sudo
#   zsh-autosuggestions
#   zsh-syntax-highlighting
# )
###########
vim .zshrc

# Add additional site functions completion https://github.com/zsh-users/zsh-completions
pacman -S zsh-completions

# theme https://github.com/romkatv/powerlevel10k
pacman -S zsh-theme-powerlevel10k
ln -s /usr/share/zsh-theme-powerlevel10k .oh-my-zsh/custom/themes/

# edit .zshrc & add the following theme
###########
# ZSH_THEME="zsh-theme-powerlevel10k/powerlevel10k"
###########
vim .zshrc

source .zshrc

# configure p10k if not already done
p10k configure
```

## Spice up shell

```bash
# install https://github.com/nvbn/thefuck
pacman -S thefuck
# edit .zshrc & add the following
###########
# eval $(thefuck --alias)
###########
vim .zshrc

# install https://github.com/rupa/z
pacman -S z
# edit .zshrc & add the following
###########
# [[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh
###########
vim .zshrc

# install https://github.com/sharkdp/bat
pacman -S bat
```

### Setup Xorg

```bash
# check graphic card
lspci|grep -i VGA

# pick "modesetting" driver. there is nothing to install
# do not install xf86-video-intel as there are some bugs

# enable vulkan
# use vulkaninfo to confirm
pacman -S vulkan-icd-loader vulkan-intel vulkan-tools

# enable Video Hardware Acceleration
# use intel_gpu_top to confirm
pacman -S intel-media-driver intel-gpu-tools

# install Xorg server, xinit & xrandr
# Configure keyboard if needed https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
pacman -S xorg-server xorg-xinit xorg-xrandr

# allow rootless Xorg by editing/creating the following file & content
###########
# needs_root_rights = no
###########
vim /etc/X11/Xwrapper.config

# autostart Xorg on login for tty1
###########
# if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#   exec startx
# fi
###########
vim ~/.zprofile

# check graphic performances
yay -S glmark2
# run benchmark
glmark2

# TODO add pinch zoom to touchpad + swipe workspace (libinput-gestures?)
```

### Setup sound

```bash
# logout/login to take group changes into effect
# run `groups` to check groups the user belong to
gpasswd -a jbe audio

# install console & GUI to control sounds
pacman -S alsa-utils pulseaudio pavucontrol

# unmute master
alsamixer

# add auto switch module
###########
# .include /etc/pulse/default.pa
#
# # automatically switch to newly-connected devices
# load-module module-switch-on-connect
###########
cp default.pa ~/.config/pulse/default.pa
```

### Setup webcam

```bash
# check `uvcvideo` is loaded
lsmod|grep uvc

# check available devices
v4l2-ctl --list-devices

# logout/login to take group changes into effect
# run `groups` to check groups the user belong to
gpasswd -a jbe video

# TODO pacman -S zvbi #for vlc
```

### Setup i3

```bash
# install i3 with gaps
pacman -S i3-gaps
# edit i3 config
# - cleanup unwanted lines
###########
# for_window [class=".*"] border pixel 0
# for_window [class="zoom"] floating enable
# gaps inner 0
###########
vim .config/i3/config

# install picom compositor for transparency
pacman -S picom
mkdir ~/.config/picom
cp /etc/xdg/picom.conf ~/.config/picom/picom.conf
# Add the following rules
###########
# opacity-rule = [
#   "80:class_g = 'kitty' && focused",
#   "60:class_g = 'kitty' && !focused"
# ];
#
# shadow-exclude = [
#  ...
#  # remove zoom screen sharing shadow
#  "name = 'cpt_frame_window'",
#  "class_g *?= 'zoom'",
#   ...
# ]
###########
vim ~/.config/picom/picom.conf

# create wallpaper directory and copy image from repository
mkdir -p .wallpapers/background
mkdir -p .wallpapers/lockscreen
pacman -S feh

yay -S betterlockscreen
# enable betterlockscreen on system suspend
systemctl enable betterlockscreen@$user
# update cache
betterlockscreen -u ~/.wallpapers/lockscreen
# edit i3 config
###########
# bindsym $mod+l exec --no-startup-id betterlockscreen -l --off 10 & betterlockscreen -u ~/.wallpapers/lockscreen
###########
vim .config/i3/config

# edit i3 config and add brightness control
pacman -S brightnessctl
###########
# bindsym XF86MonBrightnessUp exec brightnessctl set +10%
# bindsym XF86MonBrightnessDown exec brightnessctl set 10%-
###########
vim .config/i3/config

# edit i3 config and add print screen control
pacman -S scrot
###########
# bindsym Print exec sleep 0.2 && scrot -s ~/Downloads/screenshots-$(date '+%Y%m%d-%H%M%S').png
###########
vim .config/i3/config

pacman -S rofi
yay -S polybar

cd /tmp/
git clone --depth=1 https://github.com/adi1090x/polybar-themes.git
./setup.sh
# configure theme
vim .config/polybar/forest/modules.ini
vim .config/polybar/forest/config.ini

# edit i3 config
###########
# bindsym $mod+d exec --no-startup-id ~/.config/polybar/forest/scripts/launcher.sh
# bindsym $mod+Shift+e exec --no-startup-id ~/.config/polybar/forest/scripts/powermenu.sh
###########
vim .config/i3/config

yay -S networkmanager-dmenu-git
cp /usr/share/doc/networkmanager-dmenu-git/config.ini.example .config/networkmanager-dmenu/config.ini
# configure it
###########
# dmenu_command = rofi -no-config -no-lazy-grab -show drun -modi drun -theme ~/.config/polybar/forest/scripts/rofi/launcher.rasi
# rofi_highlight = True
# compact = True
###########
vim .config/networkmanager-dmenu/config.ini

# install i3 autoname https://github.com/justbuchanan/i3scripts
cd ~/.config/i3
git clone https://github.com/justbuchanan/i3scripts
pacman -S python-i3ipc
yay -S python-fontawesome
# run script on i3 start up
###########
# exec_always ~/.config/i3/i3scripts/autoname_workspaces.py
###########
vim .config/i3/config

# install xidlehook
yay -S xidlehook

# Copy xinitrc template
cp /etc/X11/xinit/xinitrc ~/.xinitrc
# In the "start some nice programs here" section, under the xinitrc.d part, replace with:
###########
# # transparency
# picom &
# # background
# feh --bg-scale ~/.wallpapers/background/arch.png &
# # auto lock
# xidlehook --not-when-audio --timer 300 'betterlockscreen -l --off 10 & betterlockscreen -u ~/.wallpapers/lockscreen' '' &
# # launch polybar
# ~/.config/polybar/launch.sh --forest &
# # launch i3
# exec i3 -V >> /tmp/i3log-$(date +'%F-%k-%M-%S') 2>&1
###########
vim .xinitrc

# Copy xserverrc template
cp /etc/X11/xinit/xserverrc ~/.xserverrc
# Replace the main exec line with:
###########
# exec /usr/bin/X -nolisten tcp "$@" vt$XDG_VTNR
###########
vim .xserverrc

# TODO spotify polybar
```

### Setup terminal emulator: Kitty

```bash
pacman -S kitty
# create template config file by hitting ctrl+shift+f2

# move current p10k config
mv .p10k.zsh .p10k-tty.zsh
# re-run powerlevel10k config & pick the `pure` style
p10k config
# edit .zshrc and replace `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh` with:
###########
# if [[ $TERM == linux ]]; then
#  POWERLEVEL9K_CONFIG_FILE=~/.p10k-tty.zsh
# else
#  POWERLEVEL9K_CONFIG_FILE=~/.p10k.zsh
# fi
#
# [[ ! -f $POWERLEVEL9K_CONFIG_FILE ]] || source $POWERLEVEL9K_CONFIG_FILE
###########
vim .zshrc

# add font
yay -S ttf-meslo-nerd-font-powerlevel10k

# configure kitty font and add the following line to it:
# inspired from https://github.com/connorholyday/kitty-snazzy/blob/master/snazzy.conf
# final look & feel should match https://github.com/sindresorhus/pure (zsh + powerline10k pure style + kitty snazzy theme + font meslo)
###########
# font_family MesloLGS NF
# cursor                #97979B
# cursor_text_color     #282A36
# foreground            #eff0eb
# background            #282a36
###########
vim ~/.config/kitty/kitty.conf
```

### Extra libs

```bash
# setup autorandr https://github.com/phillipberndt/autorandr
pacman -S autorandr
# configure your screen and save config with
autorandr --save laptop
###########
# bindsym $mod+x exec --no-startup-id autorandr -c
###########
vim .config/i3/config

# install Chromium + extensions: lastpass, ghostery
# TODO choose font: ttf_liberation + update downloads folder to lower case: "downloads"
pacman -S chromium

# setup Git
git config --global core.editor vim
# https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
pacman -S openssh
ssh-keygen -t ed25519 -C "your_email@example.com"
# TODO use ssh agent? https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases
# Add the SSH key to your account on GitHub: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
git clone git@github.com:your-repo.git
cd your-repo
git config user.email "your-email@users.noreply.github.com"
git config user.name "Your Name"

# install vs code + extension Prettier
# update settings
###########
# {
#   "workbench.colorTheme": "Default Dark+",
#   "editor.formatOnSave": true,
#   "workbench.editor.enablePreview": false,
#   "javascript.validate.enable": false
# }
###########
yay -S visual-studio-code-bin

# - gimp: image editor
# - youtube-dl: video converter
# - wget: curl alternative
# - remmina: remote desktop
# - unzip
# - Slack
# - Spotify
# - Zoom
# Additional: imagemagick (converter), peek (gif maker)
pacman -S gimp youtube-dl wget unzip vlc
yay -S spotify slack-desktop zoom
```

### Update firmwares

```bash
# install https://wiki.archlinux.org/title/Fwupd
pacman -S udisks2 fwupd
# check ESP is detected & available updates
fwupdmgr get-devices
fwupdmgr refresh
fwupdmgr get-updates
# update firmwares
fwupdmgr update
```

### Others

- TODO frequency scaling

  - scaling governor/energy perf policy https://wiki.archlinux.org/title/CPU_frequency_scaling
  - ACPID event https://wiki.archlinux.org/title/Acpid

- graphic card performance https://wiki.archlinux.org/title/improving_performance#Graphics

- pacman -Syu python2 nodejs npm yarn

- detect usb keys

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
