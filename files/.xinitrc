#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# transparency
picom &
# background
feh --bg-scale ~/.wallpapers/background/arch.png &
# auto lock
xidlehook --not-when-audio --timer 300 'betterlockscreen -l --off 10 & betterlockscreen -u ~/.wallpapers/lockscreen' '' &

# gestures (normally there's an autostart?)
libinput-gestures-setup start &
# networkmanager applet
nm-applet &
# i3
exec i3 -V >> /tmp/i3log-$(date +'%F-%k-%M-%S') 2>&1
