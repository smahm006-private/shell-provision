xdg_dir() {
# create xdg directories
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_DATA_HOME/gnupg
mkdir -p $XDG_DATA_HOME/python
mkdir -p $XDG_DATA_HOME/npm
mkdir -p $XDG_DATA_HOME/wine
mkdir -p $XDG_DATA_HOME/fonts
mkdir -p $XDG_DATA_HOME/icons
mkdir -p $XDG_DATA_HOME/themes
mkdir -p $XDG_DATA_HOME/terminfo
mkdir -p $XDG_DATA_HOME/.pki
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CONFIG_HOME/X11
mkdir -p $XDG_CONFIG_HOME/wgetrc
mkdir -p $XDG_CONFIG_HOME/git
mkdir -p $XDG_CONFIG_HOME/gtk-2.0
mkdir -p $XDG_CONFIG_HOME/aws
mkdir -p $XDG_CONFIG_HOME/python
mkdir -p $XDG_CONFIG_HOME/npm
mkdir -p $XDG_CONFIG_HOME/npm/config
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_CACHE_HOME/X11
mkdir -p $XDG_CACHE_HOME/python
mkdir -p $XDG_STATE_HOME
mkdir -p $XDG_STATE_HOME/bash
mkdir -p $XDG_STATE_HOME/less
mkdir -p $XDG_STATE_HOME/python
mkdir -p $XDG_STATE_HOME/node

# create workstation directory
mkdir -p $WORKSTATION
mkdir -p $WORKSTATION/projects
mkdir -p $WORKSTATION/projects/personal
mkdir -p $WORKSTATION/projects/work
mkdir -p $WORKSTATION/projects/sandbox
mkdir -p $WORKSTATION/resources
mkdir -p $WORKSTATION/architecture
mkdir -p $WORKSTATION/architecture/toolchains
mkdir -p $WORKSTATION/architecture/toolchains/rust
mkdir -p $WORKSTATION/architecture/virtualmachines
mkdir -p $WORKSTATION/architecture/virtualmachines/vagrant

# create dump (downloads) directory
mkdir -p $DUMP

# create media directory
mkdir -p $MEDIA
mkdir -p $MEDIA/audio
mkdir -p $MEDIA/pictures
mkdir -p $MEDIA/pictures/wallpapers
mkdir -p $MEDIA/pictures/screenshots
mkdir -p $MEDIA/pictures/misc
mkdir -p $MEDIA/videos

# create org directory
mkdir -p $ORG
mkdir -p $ORG/documents
mkdir -p $ORG/misc
mkdir -p $ORG/books
mkdir -p $ORG/backup
mkdir -p $ORG/proffesional

# create apps directory
mkdir -p $APPLICATIONS

# create .ssh directory
mkdir -p $HOME/.ssh

# set XDG global environment_variables
sudo tee /etc/profile.d/xdg.sh >/dev/null <<EOF
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Setting \$XDG_RUNTIME_DIR
if test -z "\${XDG_RUNTIME_DIR}"; then
     export XDG_RUNTIME_DIR=/tmp/\${UID}-runtime-dir
     if ! test -d "\${XDG_RUNTIME_DIR}"; then
         mkdir "\${XDG_RUNTIME_DIR}"
         chmod 0700 "\${XDG_RUNTIME_DIR}"
     fi
 fi
EOF
sudo chmod 0644 /etc/profile.d/xdg.sh

# set user-dirs
tee $XDG_CONFIG_HOME/user-dirs.dirs >/dev/null <<EOF
XDG_DESKTOP_DIR="$HOME"
XDG_DOWNLOAD_DIR="$HOME/dump"
XDG_TEMPLATES_DIR="$HOME"
XDG_PUBLICSHARE_DIR="$HOME"
XDG_DOCUMENTS_DIR="$ORG"
XDG_MUSIC_DIR="$MEDIA/audio"
XDG_PICTURES_DIR="$MEDIA/pictures"
XDG_VIDEOS_DIR="$MEDIA/videos"
EOF
xdg-user-dirs-update
}

xdg_cbins() {
    git -C /usr/local/cbins pull &>/dev/null || (sudo rm -rf /usr/local/cbins && git clone ${GITURL}smahm006-private/cbins.git /tmp/cbins && sudo mv /tmp/cbins /usr/local/cbins)
}

xdg_dotfiles() {
    set -e
    git -C $HOME/.dotfiles pull &>/dev/null || (rm -rf $HOME/.dotfiles && git clone ${GITURL}smahm006-private/.dotfiles.git $HOME/.dotfiles)
    cd $HOME/.dotfiles
    if ! stow * &>/dev/null; then
	    dirs=$(stow * 2>&1 | grep "existing target is neither a link nor a directory:" | sed 's/^.*: //')
	    for dir in $dirs; do rm -rf $HOME/$dir; done
	    stow *
    fi
}

xdg_emacs() {
    git -C $XDG_CONFIG_HOME/emacs pull &>/dev/null || (rm -rf $XDG_CONFIG_HOME/emacs && git clone ${GITURL}smahm006/emacs.git $XDG_CONFIG_HOME/emacs)
}

if [ $# -gt 0 ]; then
	xdg_$1 $@
else
	for cmd in $(function_list_parser xdg); do
		xdg_$cmd
	done
fi
