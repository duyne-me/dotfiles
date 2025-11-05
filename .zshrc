# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    docker
    kubectl
    terraform
    aws
    gcloud
    helm
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ========================================
# User Configuration
# ========================================

# Editor
export EDITOR='vim'
export VISUAL='vim'

# History
HISTSIZE=50000
SAVEHIST=50000

# ========================================
# Kubernetes Aliases
# ========================================

alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kx='kubectx'
alias kns='kubens'
alias ke='kubectl edit'
alias kdesc='kubectl describe'
alias kexec='kubectl exec -it'

# Kubectl with watch
alias kgpw='watch kubectl get pods'
alias kgnw='watch kubectl get nodes'

# Get all resources in namespace
alias kga='kubectl get all'

# Port forwarding shortcut
kpf() {
    kubectl port-forward "$1" "$2"
}

# Quick pod shell access
ksh() {
    kubectl exec -it "$1" -- /bin/sh
}

kbash() {
    kubectl exec -it "$1" -- /bin/bash
}

# ========================================
# Docker Aliases
# ========================================

alias d='docker'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'

# Clean up Docker
alias dprune='docker system prune -af --volumes'
alias drmi='docker rmi $(docker images -q)'
alias drm='docker rm $(docker ps -aq)'

# ========================================
# Git Aliases
# ========================================

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch -d'


# ========================================
# Terraform Aliases
# ========================================

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfw='terraform workspace'

# ========================================
# AWS Aliases
# ========================================

alias awsl='aws s3 ls'
alias awsec2='aws ec2 describe-instances'
alias awseks='aws eks list-clusters'

# ========================================
# GCP Aliases
# ========================================

alias gke='gcloud container clusters'
alias gcel='gcloud compute instances list'
alias gsutil='gsutil'

# ========================================
# General Aliases
# ========================================

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Use bat instead of cat if available
if command -v bat &> /dev/null; then
    alias cat='bat'
fi

# Grep with color
alias grep='grep --color=auto'

# Show top 10 processes by memory
alias topmem='ps aux | sort -rk 4,4 | head -n 10'

# Show top 10 processes by CPU
alias topcpu='ps aux | sort -rk 3,3 | head -n 10'

# ========================================
# Functions
# ========================================

# Get pod logs by label
klabel() {
    kubectl logs -l "$1" -f
}

# Describe resource quickly
kdesc() {
    kubectl describe "$1" "$2"
}

# Get events sorted by time
kevents() {
    kubectl get events --sort-by='.lastTimestamp'
}

# Switch AWS profile
awsp() {
    export AWS_PROFILE="$1"
    echo "Switched to AWS profile: $1"
}

# Quick port forward to pod
kpfw() {
    local pod=$(kubectl get pods | grep "$1" | head -1 | awk '{print $1}')
    echo "Port forwarding to pod: $pod"
    kubectl port-forward "$pod" "$2"
}

# Get all pods in all namespaces
kgpa() {
    kubectl get pods --all-namespaces
}

# Quick context info
kinfo() {
    echo "Context: $(kubectl config current-context)"
    echo "Namespace: $(kubectl config view --minify --output 'jsonpath={..namespace}')"
}

# ========================================
# Auto-completions
# ========================================

# kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
fi

# helm completion
if command -v helm &> /dev/null; then
    source <(helm completion zsh)
fi

# terraform completion
if command -v terraform &> /dev/null; then
    complete -o nospace -C /usr/local/bin/terraform terraform
fi

# ========================================
# Custom Prompt (Optional)
# ========================================

# Show current kubernetes context in prompt
PROMPT='%{$fg[cyan]%}%~%{$reset_color%} $(kube_ps1)$ '

kube_ps1() {
    if command -v kubectl &> /dev/null; then
        local context=$(kubectl config current-context 2>/dev/null)
        if [ -n "$context" ]; then
            echo "%{$fg[yellow]%}[k8s: $context]%{$reset_color%} "
        fi
    fi
}

# ========================================
# Environment Variables
# ========================================

# Increase kubectl timeout
export KUBECTL_TIMEOUT=30s

# Set default editor for kubectl edit
export KUBE_EDITOR='vim'

# FZF configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ========================================
# PATH additions
# ========================================

# Add local bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add custom scripts directory
if [ -d "$HOME/.dotfiles/scripts" ]; then
    export PATH="$HOME/.dotfiles/scripts:$PATH"
fi

echo "🚀 DevOps/SRE environment loaded!"