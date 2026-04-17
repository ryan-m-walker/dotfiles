source ~/zsh-defer/zsh-defer.plugin.zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"

# Set TERM for WezTerm to enable undercurl support
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
  export TERM=wezterm
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set keybindings to vi mode
set -o vi

# easier git checkout
gch() {
  local branches
  branches=$(git branch --all --sort=-committerdate | grep -v 'remotes/')
  
  selected=$(echo "$branches" | fzf)
  
  if [ -n "$selected" ]; then
    git checkout "$(echo "$selected" | tr -d '[:space:]')"
  fi
}

copyb() {
    local branchName=$(git status | grep "On branch" | awk '{print $3}')
    echo "$branchName" | pbcopy
    echo "📋 branch name $branchName copied to clipboard!"
}

shrug() {
    echo '¯\_(ツ)_/¯' | pbcopy
    echo '¯\_(ツ)_/¯'
}

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions web-search tmuxinator)

source $ZSH/oh-my-zsh.sh

alias vim=nvim
alias nv=nvim
alias xx="exit"

# NVM
source ~/.zsh-nvm/zsh-nvm.plugin.zsh

# instead of using --no-use flag, load nvm lazily:
if ! $found; then
  _load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  }

  for cmd in "${__NODE_GLOBALS[@]}"; do
    eval "function ${cmd}(){ unset -f ${__NODE_GLOBALS[*]}; _load_nvm; unset -f _load_nvm; ${cmd} \"\$@\"; }"
  done
fi
unset cmd value found __NODE_GLOBALS

# don't share history across tabs
# https://superuser.com/questions/1245273/iterm2-version-3-individual-history-per-tab
unsetopt inc_append_history
unsetopt share_history

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

alias tx="tmuxinator"
alias txend="tmux kill-session"

fzr() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            echo {1} | pbcopy && echo "📋 Copied filepath {1} to clipboard"
          else
            echo {+f} | cut -d: -f1 | pbcopy && echo "📋 Copied filepaths to clipboard"
          fi'
  fzf --disabled --ansi --multi \
      --reverse \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --theme auto:system --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --tmux 95%,95% \
      --header='🔍 Search Files - Enter: open file' \
      --query "$*"
)

fzt() {
  local temp_file=$(mktemp)
  RELOAD='reload:git ls-files "*.test.ts" "*.test.tsx"'
  OPENER='echo "pnpm test:unit {1}" > '"$temp_file"' && pnpm test:unit {1}'

  fzf --ansi \
      --reverse \
      --bind "start:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-/:toggle-preview" \
      --preview 'bat --style=full --color=always --theme auto:system {1} 2>/dev/null || head -50 {1}' \
      --preview-window '~4,+1+4/3,<80(up)' \
      --tmux 95%,95% \
      --header='🧪 Test Runner - Enter: run test' \
      --query "$*"
  
  # add command to history so you can more easily run it again without having to fuzzy search it again
  if [[ -f "$temp_file" && -s "$temp_file" ]]; then
    local cmd=$(cat "$temp_file")
    print -s "$cmd"
  fi
  rm -f "$temp_file"
}

source <(fzf --zsh)
eval "$(zoxide init zsh)"

