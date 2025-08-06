# ~/.bashrc base for Naicibox
export HISTFILE=~/.bash_history
export PROMPT_COMMAND='history -a'
eval "$(starship init bash)"
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi