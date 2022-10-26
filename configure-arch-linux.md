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

# enable Hardware Video Acceleration
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

# add extra touch pad gestures using https://github.com/bulletmark/libinput-gestures/
pacman -s libinput-gestures wmctrl xdotool
gpasswd -a jbe input
###########
# gesture swipe up	_internal ws_up
# gesture swipe down	_internal ws_down
# gesture swipe left	xdotool key alt+Left
# gesture swipe right	xdotool key alt+Right
# gesture pinch in	xdotool key ctrl+minus
# gesture pinch out	xdotool key ctrl+plus
###########
cp /etc/libinput-gestures.conf .config
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
pacman -S scrot xclip
###########
# bindsym Print exec sleep 0.2 && scrot -s ~/downloads/screenshots-$(date '+%Y%m%d-%H%M%S').png -e 'xclip -selection clipboard -target image/png -i $f'
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
# # polybar
# ~/.config/polybar/launch.sh --forest &
# # gestures (normally there's an autostart?)
# libinput-gestures-setup start &
# # networkmanager applet
# nm-applet &
# # i3
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

# install Chromium and:
# - add extensions: lastpass, ghostery
# - update downloads folder to lower case: "downloads"
pacman -S chromium
# add extra fonts to cover the whole UTF-8 spectrum
pacman -S ttf-liberation ttf-dejavu oto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra

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
# - unzip
# - vlc + zvbi to be able to use webcam with VLC
# - remmina: remote desktop
# - Spotify: music
# - Slack: messaging app
# - Zoom: video conferencing
# Additional: imagemagick (converter), peek (gif maker)
pacman -S gimp youtube-dl wget unzip vlc zvbi remmina
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

### Setup printer

```bash
# install CUPS
pacman -S cups cups-pdf

# activate CUPS socket
systemctl enable cups.socket
systemctl start cups.socket

# install avahi to detect network printers
pacman -S avahi nss-mdns

# edit hosts line in config
###########
# hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
###########
vim /etc/nsswitch.conf

# activate avahi service
systemctl enable avahi-daemon.service
systemctl start avahi-daemon.service

# add drivers: https://wiki.archlinux.org/title/CUPS#Printer_drivers
pacman -S foomatic-db-engine foomatic-db foomatic-db-pps

# use web interface to administer printers
# connect to http://localhost:631/ then `Administration > Add Printer`
```

### Setup VPN

```bash
# install protonvpn & dependencies
pacman -S network-manager-applet gnome-keyring
yay -S protonvpn
# add public key to pacman. See https://protonvpn.com/support/official-linux-client-arch/
pacman-key --add downloads/public_key.asc
pacman-key --finger $XXX
pacman-key --lsign-key $XXX
# connect
# nm-applet should be running in the background
protonvpn-cli login $username
protonvpn-cli connect
```

### Setup CPU & battery management tool

```bash
# ensure performance are optimal
pacman -S s-tui
s-tui

# check scaling driver, governor & frequency
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

# Install TLP https://linrunner.de/tlp/installation/arch.html
pacman -S tlp tlp-rdw

systemctl enable tlp.service
systemctl start tlp.service
systemctl enable NetworkManager-dispatcher.service
systemctl start NetworkManager-dispatcher.service

systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

# edit conf
###########
# CPU_SCALING_GOVERNOR_ON_AC=performance
# CPU_SCALING_GOVERNOR_ON_BAT=powersave
# CPU_BOOST_ON_AC=1
# CPU_BOOST_ON_BAT=0
# CPU_HWP_DYN_BOOST_ON_AC=1
# CPU_HWP_DYN_BOOST_ON_BAT=0
###########

# Configure smbios thermal mode
smbios-thermal-ctl --set-thermal-mode=performance

# Install thermald for Tiger Lake CPUs
pacman -S thermald
sensors-detect
systemctl enable thermald.service
systemctl start thermald.service
```

### Others

- TODO detect usb keys

  - https://wiki.archlinux.org/title/Udisks
  - https://wiki.archlinux.org/title/List_of_applications/Utilities#Mount_tools

- pacman -Syu python2 nodejs npm yarn
