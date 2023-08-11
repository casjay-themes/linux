#!/usr/bin/env bash

SCRIPTNAME="$(basename $0)"
SCRIPTDIR="$(dirname "${BASH_SOURCE[0]}")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.pro
# @File        : install
# @Created     : Mon, Dec 31, 2019, 00:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : installer script for linux
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

if [ -f /usr/local/share/CasjaysDev/scripts/functions/app-installer.bash ]; then
    . /usr/local/share/CasjaysDev/scripts/functions/app-installer.bash
elif [ -f "$HOME/.local/share/scripts/functions/app-installer.bash" ]; then
    . "$HOME/.local/share/scripts/functions/app-installer.bash"
else
    mkdir -p "$HOME/.local/share/scripts/functions"
    curl -LSs https://github.com/casjay-dotfiles/scripts/raw/main/functions/app-installer.bash -o "$HOME/.local/share/scripts/functions/app-installer.bash"
    . "$HOME/.local/share/scripts/functions/app-installer.bash"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Defaults

# USER
BIN="$HOME/.local/bin"
CONF="$HOME/.config"
SHARE="$HOME/.local/share"
LOGDIR="$HOME/.local/logs"
BACKUPDIR="$HOME/.local/backups/home"
REPO="https://github.com/casjay-themes"

# SYSTEM
SYSBIN="/usr/local/bin"
SYSCONF="/usr/local/etc"
SYSSHARE="/usr/local/share"
SYSLOGDIR="$HOME/.local/logs"
SYSBACKUPDIR="$/usr/local/share/backups"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set options

APPNAME="linux"
PIPNAME=""
PLUGNAME=""
if sudoif ; then
APPDIR="$SYSSHARE/CasjaysDev/themes"
PLUGDIR="$CONF/$APPNAME/$PLUGNAME"
else
APPDIR="$CONF/themes"
PLUGDIR="$CONF/$APPNAME/$PLUGNAME"
fi
PIPVERSION="3"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Requires root

#sudoreq  # sudo required
#sudorun  # sudo optional

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# prerequisites

APP=""
PKG=""
PIP=""
MISSING=""
PIPMISSING=""

# - - - - - - - - - - - - - - -

for cmd in xfce4-about
do
    cmd_exists $cmd || MISSING+="$cmd "
done

# - - - - - - - - - - - - - - -

if [ ! "$(cmd_exists apt)" ]; then PKG="xfce4"
elif [ ! "$(cmd_exists yum)" ]; then PKG="xfce4"
elif [ ! "$(cmd_exists pacman)" ]; then PKG="xfce4"
fi

# - - - - - - - - - - - - - - -

if [ ! -z "$MISSING" ]; then printf_warning "This requires $MISSING"
  if cmd_exists "pkmgr"; then
  for miss in $PKG
    do execute \
    "requiresudo pkmgr silent $miss" \
    "Attemping install of $miss"
    done
  fi
fi

# - - - - - - - - - - - - - - -

#cmd_exists PIPNAME || PIPMISSING+="PIPNAME "

# - - - - - - - - - - - - - - -

#if [ ! -z "$PIPMISSING" ]; then printf_warning "This requires $PIPMISSING"
#  if cmd_exists "pkmgr"; then
#  for pippkg in $PIPMISSING
#   do execute "requiresudo pkmgr pip $pippkg" \
#   "Attempting to install $pippkg"
#   done
#  fi
#fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Ensure directories exist

mkd "$BACKUPDIR"
mkd "$CONF/CasjaysDev/apps"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Main progam

if [ -d "$APPDIR/.git" ]; then
    execute \
        "cd $APPDIR && \
         git_update" \
        "Updating $APPNAME configurations"
else
    if [ -d "$BACKUPDIR/$APPNAME" ]; then
        rm_rf "$BACKUPDIR"/"$APPNAME"
    fi
    execute \
        "mv_f $APPDIR $BACKUPDIR/$APPNAME && \
         git_clone -q $REPO/$APPNAME $APPDIR" \
        "Installing $APPNAME configurations"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Plugins

#if [ -d "$PLUGDIR"/.git ]; then
#   execute \
#       "cd $PLUGDIR && git_update" \
#       "Installing NAME for $APPNAME"
#else
#     execute \
#       "git_clone GITREPO $PLUGDIR" \
#       "Plugin NAME has been installed\n"
#fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# run post install scripts

if sudoif; then

    execute \
        "sudo cp -Rf $APPDIR/icons/* /usr/share/icons && \
         sudo fc-cache -f /usr/share/icons/N.I.B./ && \
         sudo fc-cache -f /usr/share/icons/Obsidian-Purple/" \
        "Installing icons"

  sudo find /usr/share/icons -mindepth 1 -maxdepth 1 -type d | while read -r THEME; do
   if [ -f "$THEME/index.theme" ]; then
    execute \
        "gtk-update-icon-cache -f -q $THEME" \
        "Updating ICON $THEME"
   fi
  done
  
else

if [ -L ~/.local/share/icons ]; then unlink ~/.local/share/icons ; fi
if [ -d ~/.local/share/icons ] && [ ! -L ~/.local/share/icons ]; then
 mv -f ~/.local/share/icons ~/.local/share/icons.old
fi

if [ -d ~/.local/share/icons.old ]; then
    execute \
        "ln -sf $APPDIR/icons ~/.local/share/icons && \
         rsync -aqh ~/.local/share/icons.old/* ~/.local/share/icons/ 2>/dev/null && \
         rm -Rf ~/.local/share/icons.old/ && \
         fc-cache -f ~/.local/share/icons/N.I.B./ && \
         fc-cache -f ~/.local/share/icons/Obsidian-Purple/" \
        "$APPDIR/icons → ~/.local/share/icons"
else
    execute \
        "ln -sf $APPDIR/icons ~/.local/share/icons && \
         fc-cache -f ~/.local/share/icons/N.I.B./ && \
         fc-cache -f ~/.local/share/icons/Obsidian-Purple/" \
        "$APPDIR/icons → ~/.local/share/icons"
fi

find ~/.local/share/icons/ -mindepth 1 -maxdepth 1 -type d | while read -r THEME; do
 if [ -f "$THEME/index.theme" ]; then
    execute \
        "gtk-update-icon-cache -f -q $THEME" \
        "Updating ICON $THEME"
 fi
done
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if sudoif; then

    execute \
        "sudo cp -Rf $APPDIR/themes/* /usr/share/themes" \
        "Installing themes"
else
if [ -L ~/.local/share/themes ]; then unlink ~/.local/share/themes ; fi
if [ -d ~/.local/share/themes ] && [ ! -L ~/.local/share/themes ]; then
 mv -f ~/.local/share/themes ~/.local/share/themes.old
fi

if [ -d ~/.local/share/themes.old ]; then
    execute \
        "ln -sf $APPDIR/themes ~/.local/share/themes && \
         rsync -ahq ~/.local/share/themes.old/* ~/.local/share/themes/ 2>/dev/null && \
         rm -Rf ~/.local/share/themes.old/"
        "$APPDIR/themes → ~/.local/share/themes"
else
    execute \
        "ln -sf $APPDIR/themes ~/.local/share/themes" \
        "$APPDIR/themes → ~/.local/share/themes"
fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if sudoif ; then


    execute \
        "sudo cp -Rf $APPDIR/fonts/* /usr/share/fonts" \
        "Installing fonts"

else

if [ -L ~/.local/share/fonts ]; then unlink ~/.local/share/fonts ; fi
if [ -d ~/.local/share/fonts ] && [ ! -L ~/.local/share/fonts ]; then
 mv -f ~/.local/share/fonts ~/.local/share/fonts.old
fi

if [ -d ~/.local/share/fonts.old ]; then
    execute \
        "ln -sf $APPDIR/fonts ~/.local/share/fonts && \
         rsync -ahq ~/.local/share/fonts.old/* ~/.local/share/fonts/ 2>/dev/null && \
         rm -Rf ~/.local/share/fonts.old/ && \
         fc-cache -f" \
        "$APPDIR/fonts → ~/.local/share/fonts"

else
    execute \
        "ln -sf $APPDIR/fonts ~/.local/share/fonts && \
         fc-cache -f" \
        "$APPDIR/fonts → ~/.local/share/fonts"
fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if sudoif ; then

 if [ -f /usr/sbin/grub-mkconfig ]; then
  GRUB="/usr/sbin/grub-mkconfig"
 else
  GRUB="/usr/sbin/grub2-mkconfig"
 fi

    if [ -f /boot/grub/grub.cfg ]; then
     if [ ! -d /boot/grub/themes ]; then
      sudo mkdir -p /boot/grub/themes
     fi

    execute \
        "sudo cp -Rf $APPDIR/boot/grub /etc/default/grub && \
         sudo cp -Rf $APPDIR/boot/themes/* /boot/grub/themes && \
         sudo sed -i 's|^\(GRUB_TERMINAL\w*=.*\)|#\1|' /etc/default/grub && \
         sudo sed -i 's|grubdir|grub|g' /etc/default/grub && \
         sudo ${GRUB} -o /boot/grub/grub.cfg" \
        "Installing grub customizations"

    fi
    ########
    if [ -f /boot/grub2/grub.cfg ]; then
     if [ ! -d /boot/grub2/themes ]; then
      sudo mkdir -p /boot/grub2/themes
     fi

    execute \
        "sudo cp -Rf $APPDIR/boot/grub /etc/default/grub && \
         sudo cp -Rf $APPDIR/boot/themes/* /boot/grub2/themes && \
         sudo sed -i 's|^\(GRUB_TERMINAL\w*=.*\)|#\1|' /etc/default/grub && \
         sudo sed -i 's|grubdir|grub2|g' /etc/default/grub && \
         sudo ${GRUB} -o /boot/grub2/grub.cfg" \
        "Installing grub customizations"

    fi

fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if sudoif ; then

LXDM=$(which lxdm 2>/dev/null)
 if [ -d /usr/share/lightdm-gtk-greeter-settings ]; then
LIGHTDMG=/usr/share/lightdm-gtk-greeter-settings
 elif [ -d /usr/share/lightdm-gtk-greeter ]; then
LIGHTDMG=/usr/share/lightdm-gtk-greeter
else
LIGHTDMG=/usr/share/lightdm/lightdm-gtk-greeter.conf.d
fi

  if [ -d /etc/lightdm ]; then
     execute \
        "sudo cp -Rf $APPDIR/login/lightdm/etc/* /etc/lightdm/ && \
         sudo cp -Rf $APPDIR/login/lightdm/share/lightdm/* /usr/share/lightdm/ && \
         sudo cp -Rf $APPDIR/login/lightdm/share/lightdm-gtk-greeter-settings/* $LIGHTDMG/" \
        "Installing lightdm customizations"
  fi

    ########
  if [ -d /etc/lxdm ]; then
     execute \
        "sudo cp -Rf $APPDIR/login/lxdm/share/* /usr/share/lxdm/" \
        "Installing lxdm customizations"
  fi

   if [ ! -z "$LXDM" ]; then

    sudo sed -i "s|.*numlock=.*|numlock=1|g" /etc/lxdm/lxdm.conf
    sudo sed -i "s|.*bg=.*|bg=/usr/share/lxdm/themes/BlackArch/blackarch.jpg|g" /etc/lxdm/lxdm.conf
    sudo sed -i "s|.*tcp_listen=.*|tcp_listen=1|g" /etc/lxdm/lxdm.conf
    sudo sed -i "s|gtk_theme=.*|gtk_theme=Arc-Pink-Dark|g" /etc/lxdm/lxdm.conf
    sudo sed -i "s|theme=.*|theme=BlackArch|g" /etc/lxdm/lxdm.conf

    if [ -f /etc/X11/default-display-manager ]; then
    sudo sed -i "s|lightdm|lxdm|g" /etc/X11/default-display-manager
    fi

#     execute \
#        "sudo systemctl disable -f lightdm 2>/dev/null && \
#         sudo systemctl enable -f lxdm 2>/dev/null" \
#        "Enabling the LXDM login manager"

  fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# create version file

if [ ! -f "$CONF/CasjaysDev/apps/$APPNAME" ] && [ -f "$APPDIR/version.txt" ]; then
    ln -s "$APPDIR/version.txt" "$CONF/CasjaysDev/apps/$APPNAME"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exit
if [ ! -z "$EXIT" ]; then exit "$EXIT"; fi

# end
#/* vim set expandtab ts=4 noai
