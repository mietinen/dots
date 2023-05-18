# ------------------------------------------------------------------------------
# Shell options
# ------------------------------------------------------------------------------
unsetopt beep
unsetopt nomatch
setopt prompt_subst
stty -ixon

HISTSIZE=5000
SAVEHIST=5000
setopt hist_ignore_dups hist_ignore_space
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

mkdir -p "${HISTFILE%/*}" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'
zmodload zsh/complist
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots)

# ------------------------------------------------------------------------------
# Simple fallback PS1
# ------------------------------------------------------------------------------
PS1="%B%F{cyan}%~%F{red} >%f%b "

# ------------------------------------------------------------------------------
# Vi mode
# ------------------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# ------------------------------------------------------------------------------
# Vi mode cursor
# ------------------------------------------------------------------------------
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-keymap-select
zle -N zle-line-init
preexec() { echo -ne '\e[5 q' ;}

# ------------------------------------------------------------------------------
# Bash like keybindings
# ------------------------------------------------------------------------------
typeset -A key
key=(
	BackSpace  "${terminfo[kbs]}"
	Home       "${terminfo[khome]}"
	End        "${terminfo[kend]}"
	Insert     "${terminfo[kich1]}"
	Delete     "${terminfo[kdch1]}"
	Up         "${terminfo[kcuu1]}"
	Down       "${terminfo[kcud1]}"
	Left       "${terminfo[kcub1]}"
	Right      "${terminfo[kcuf1]}"
	PageUp     "${terminfo[kpp]}"
	PageDown   "${terminfo[knp]}"
	Shift-Tab  "${terminfo[kcbt]}"
)

function bind2maps () {
    local i sequence widget
    local -a maps
    while [[ "$1" != "--" ]]; do
        maps+=( "$1" )
        shift
    done
    shift
    if [[ "$1" == "-s" ]]; then
        shift
        sequence="$1"
    else
        sequence="${key[$1]}"
    fi
    widget="$2"
    [[ -z "$sequence" ]] && return 1
    for i in "${maps[@]}"; do
        bindkey -M "$i" "$sequence" "$widget"
    done
}

bind2maps emacs viins       -- BackSpace   backward-delete-char
bind2maps             vicmd -- BackSpace   vi-backward-char
bind2maps emacs             -- Home        beginning-of-line
bind2maps       viins vicmd -- Home        vi-beginning-of-line
bind2maps emacs             -- End         end-of-line
bind2maps       viins vicmd -- End         vi-end-of-line
bind2maps emacs viins       -- Insert      overwrite-mode
bind2maps             vicmd -- Insert      vi-insert
bind2maps emacs             -- Delete      delete-char
bind2maps       viins vicmd -- Delete      vi-delete-char
bind2maps emacs viins vicmd -- Up          up-line-or-history
bind2maps emacs viins vicmd -- Down        down-line-or-history
bind2maps emacs             -- Left        backward-char
bind2maps       viins vicmd -- Left        vi-backward-char
bind2maps emacs             -- Right       forward-char
bind2maps       viins vicmd -- Right       vi-forward-char
bind2maps emacs viins vicmd -- Shift-Tab   reverse-menu-complete
bind2maps emacs viins vicmd -- -s '\e'${key[Right]} forward-word
bind2maps emacs viins vicmd -- -s '\e'${key[Left]}  backward-word
bind2maps emacs viins vicmd -- -s '\eOc' forward-word
bind2maps emacs viins vicmd -- -s '\eOd' backward-word
bind2maps emacs viins vicmd -- -s '\e\e[C' forward-word
bind2maps emacs viins vicmd -- -s '\e\e[D' backward-word
bind2maps emacs viins vicmd -- -s '\e[1;5C' forward-word
bind2maps emacs viins vicmd -- -s '\e[1;5D' backward-word
bind2maps emacs viins vicmd -- -s '^[[1;3C' forward-word
bind2maps emacs viins vicmd -- -s '^[[1;3D' backward-word

# ------------------------------------------------------------------------------
# Make sure the terminal is in application mode, when zle is active.
# ------------------------------------------------------------------------------
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx; }
	function zle_application_mode_stop { echoti rmkx; }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# ------------------------------------------------------------------------------
# Syntax highlighting, etc
# ------------------------------------------------------------------------------
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
. /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# ------------------------------------------------------------------------------
# Source custom stuff
# ------------------------------------------------------------------------------
. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" 2>/dev/null
. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/promptrc" 2>/dev/null
