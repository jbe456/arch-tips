## Configure Arch Linux

- login root + password
- vim /etc/pacman.d/mirrorlist move US at the top, France 2nd
- connect to wifi
- enable auto connect:
  - pacman -S wpa_actiond
  - systemctl enable netctl-auto@wlp2s0.service
- useradd -m -s /bin/bash jbe
  - passwd jbe
  - add user to sudoers: visudo, add user line, exit login again
- check boot errors:journalctl -b -p 4
  - ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
  - ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
  - https://itpeernetwork.intel.com/how-to-maximise-cpu-performance-for-the-oracle-database-on-linux/
  - pacman -S x86_energy_perf_policy
  - x86_energy_perf_policy -v performance did not work
  - pacman -S cpupower
  - cpupower frequency-info
  - cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
- get laptop model:
  - pacman -S dmidecode
  - dmidecode|less
- check hardware recommendations
  - https://wiki.debian.org/InstallingDebianOn/Asus/UX301LA
- setup AUR: from https://gist.github.com/Tadly/0e65d30f279a34c33e9b
  - `curl -Ls https://goo.gl/cF2iJy | bash`
  - uncomment "Color" option in /etc/pacman.conf
- install zsh
  - make it default shell: chsh -s /bin/zsh
  - pacman -S zsh-autosuggestions (https://github.com/zsh-users/zsh-autosuggestions + ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE)
  - pacaur -S oh-my-zsh-git
  - theme https://github.com/skylerlee/zeta-zsh-theme
    `sudo cp zeta.zsh.theme /usr/share/oh-my-zsh/custom/themes`
- Install Xorg server
  - lspci|grep -i VGA
  - pacman -S xf86-video-intel
  - pacman - xorg-server xorg-xinit
  - https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
    - fr / latin9 / asus_laptop / caps:shiftlock
    - fix delete return ~ + nice console shortcuts? https://www.linuxquestions.org/questions/linux-general-1/insert-and-delete-key-returns-~-in-a-terminal-876401/
  - dpi 120
  - xrandr --output <output> --mode <mode>
  - driver touchpad
  - to start: xinit
  - NB: Check [Xorg server won't start troubleshooting](./general-tips.md#xorg-server-wont-start) section for potential problems.
- pacman -S i3 compton
  - https://github.com/CSaratakij/i3wm-desktop-config
  - cp xserverrc xinitrc
  - pacman -S rxvt-unicode
    - export TERMINAL=urxvt + .Xdefaults
    - pacaur -Syu ttf-meslo
  - wallpaper feh
    `mkdir -p pictures/wallpapers`
    `cp backgrounds/* pictures/wallpapers`
  - pacman -Syu xautolock
  - pacman -R i3lock
  - pacaur -S i3lock-color
  - rofi
  - pacman -S conky
    - own_window_transparent=true
    - own_window = true,
    - own_window_type = 'override',
    - https://github.com/madhur/awesome-conky
    - https://github.com/zenzire/conkyrc
    - https://blog.desdelinux.net/dmenu-un-lanzador-de-aplicaciones-ultra-ligero/
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
- pacman -Syu feh gimp imagemagick # image viewer + editor + converter
- pacman -Syu wget unzip # alternative to curl + unzip

- sound:

  - pacman -S alsa-utils
  - gpasswd -a jbe audio + logout/login to take group changes into effect
  - pacman -Syu pulseaudio pavucontrol
  - cp default.pa ./.config/pulse/default.pa
  - if problem `pulseaudio --kill` then `pulseaudio --start`
  - vim /etc/modprobe.d/alsa-base.conf
    options snd_hda_intel enable=1 index=0
    options snd_hda_intel enable=0 index=1

- backlight

  - sudo tee /sys/class/backlight/intel_backlight/brightness <<< 50

- GRUB themes: https://github.com/shvchk/poly-dark

- printer

  - https://wiki.archlinux.org/index.php/CUPS
  - https://wiki.archlinux.org/index.php/Avahi
