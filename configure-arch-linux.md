## Configure Arch Linux

- login root + password
- vim /etc/pacman.d/mirrorlist move US at the top, France 2nd
- connect to wifi
- enable auto connect:
  - pacman -S wpa_actiond
  - systemctl enable netctl-auto@wlp2s0.service
- pacman -S sudo
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
- install zsh
  - setup AUR: https://gist.github.com/Tadly/0e65d30f279a34c33e9b
  - https://github.com/zsh-users/zsh-autosuggestions + ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE
  - theme zeta
- Install Xorg server
  - lspci|grep -i VGA
  - pacman -S xf86-video-intel
  - pacman - xorg-server xorg-xinit
  - https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
    - fr / latin9 / asus_laptop / caps:shiftlock
  - dpi 120
- pacman -S i3
  - https://github.com/CSaratakij/i3wm-desktop-config
  - cp xserverrc xinitrc, comment default add exec i3 -V >> ~/i3log-$(date +'%F-%k-%M-%S') 2>&1
  - pacman -S rxvt-unicode + export TERMINAL=urxvt + .Xdefaults
  - wallpaper feh + exec --no-startup-id feh --bg-scale ~/Pictures/wallpaper/wallpaper.\*
  - rofi
  - pacman -S conky
    - own_window_transparent=true
    - own_window = true,
    - own_window_type = 'override',
    - https://github.com/madhur/awesome-conky
    - https://github.com/zenzire/conkyrc
    - https://blog.desdelinux.net/dmenu-un-lanzador-de-aplicaciones-ultra-ligero/
- chromium + lastpass + ghostery
- git
  - openssh + https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
  - add key github
  - git clone git@...
- pacaur -Syu visual-studio-code-bin
- nodejs npm yarn python2

- sound:

  - pacman -S alsa-utils
  - gpasswd -a jbe audio
  - vim /etc/modprobe.d/alsa-base.conf
    options snd_hda_intel enable=1 index=0
    options snd_hda_intel enable=0 index=1

- backlight

  - sudo tee /sys/class/backlight/intel_backlight/brightness <<< 50
