# Night light
redshift -P -O 2750 &

# Disable mouse acceleration
xset m 0 0

# Restore wallpaper
nitrogen --restore &

# Run dwmblocks
dwmblocks &

# Launch dunst
dunst &

# Launch time calibration
#~/.local/bin/timeCalibration &

# Launch clipboard daemon
clipmenud &

# Turn on numlock key: https://unix.stackexchange.com/a/607769
#numlockx on

# Hides mouse
unclutter &

# Compositor
picom &
#picom --experimental-backends &
#xcompmgr -c &
#xcompmgr -c -C -t-5 -l-5 -r4.2 -o.55 &

# For java starting as blank windows
#wmname LG3D

# Sound configuration
~/.local/bin/sound &

# For screenshots
flameshot &

# Faster scrolling
imwheel -b 45

# Use AltGr as mod key for dwm
#xmodmap -e "remove mod5 = ISO_Level3_Shift"
#xmodmap -e "add mod1 = ISO_Level3_Shift"

#~/.local/bin/screen &

# Move mouse focus to middle of first screen
xdotool mousemove --sync --screen=$1 960 500

# Start GNOME keyring
dbus-update-activation-environment --systemd DISPLAY
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

#exec dwm
exec $HOME/.local/bin/startdwm
