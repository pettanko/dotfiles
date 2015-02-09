xrdb -merge ~/.Xresources
udiskie --tray &
#For watching films on my tv
#xrandr --output LVDS1 --off --output VGA1 --auto

xrandr --output LVDS1 --off --output HDMI1 --auto
xsetroot -cursor_name left_ptr &
compton --config /home/sweeb/.compton.conf -b --vsync opengl
unclutter &
feh --bg-fill Misc/images/Walls/huh.jpg
sxhkd &
setxkbmap ie
#redshift -l 53:06 &

exec bspwm
