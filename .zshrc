export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ys"
source $ZSH/oh-my-zsh.sh

export SUDO_EDITOR="nvim"

# The next line disable tty binding for Ctrl-z
stty susp "^P"

# The next line is for adding custom binaries to path
export PATH=$PATH:/Users/nanda/bin

# the next line loads antigen
source "$HOME/antigen.zsh"

# below assumes you already installed oh-my-zsh

# Plugins
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

# initialise completions with ZSH compinit
autoload -Uz compinit && compinit

# Load bundles from the default repo (oh-my-zsh)
antigen bundle git
antigen bundle jsontools
antigen bundle kubectl

# Theme
# antigen theme fox
antigen theme ys

# Apply configuration
antigen apply

# (asdf) The next line is for asdf
export ASDF_DATA_DIR="$HOME/.asdfdir"

# (asdf) append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

# (asdf) shims
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# (zoxide)
eval "$(zoxide init zsh)"

# this hooks direnv into zsh
eval "$(direnv hook zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nanda/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nanda/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nanda/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nanda/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$HOME/.local/bin:$PATH"

# (go) bin
export PATH="$(go env GOPATH)/bin:$PATH"

# (mason) 
export PATH="/home/nanda/.local/share/nvim/mason/bin:$PATH"

