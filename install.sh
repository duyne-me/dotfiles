#!/bin/bash

set -e

echo "🚀 Starting DevOps/SRE dotfiles installation..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${GREEN}OS: $OS${NC}"
echo -e "${GREEN}Architecture: $ARCH${NC}"

# Update and install basic packages
echo -e "${YELLOW}📦 Installing basic packages...${NC}"
sudo apt-get update -qq
sudo apt-get install -y curl wget git zsh vim unzip jq python3-pip bat fzf ripgrep htop

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}🎨 Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
echo -e "${YELLOW}🔌 Installing zsh plugins...${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Install kubectl
echo -e "${YELLOW}☸️  Installing kubectl...${NC}"
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install kubectx and kubens
echo -e "${YELLOW}🔄 Installing kubectx and kubens...${NC}"
if ! command -v kubectx &> /dev/null; then
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
fi

# Install k9s
echo -e "${YELLOW}🐕 Installing k9s...${NC}"
if ! command -v k9s &> /dev/null; then
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
    wget -q https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
    tar -xzf k9s_Linux_amd64.tar.gz
    sudo mv k9s /usr/local/bin/
    rm k9s_Linux_amd64.tar.gz LICENSE README.md
fi

# Install Helm
echo -e "${YELLOW}⎈ Installing Helm...${NC}"
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Install Terraform
echo -e "${YELLOW}🏗️  Installing Terraform...${NC}"
if ! command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r '.tag_name' | sed 's/v//')
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# Install AWS CLI
echo -e "${YELLOW}☁️  Installing AWS CLI...${NC}"
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install gcloud CLI
echo -e "${YELLOW}☁️  Installing gcloud CLI...${NC}"
if ! command -v gcloud &> /dev/null; then
    curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
    echo 'source $HOME/google-cloud-sdk/path.zsh.inc' >> ~/.zshrc
    echo 'source $HOME/google-cloud-sdk/completion.zsh.inc' >> ~/.zshrc
fi

# Install Docker Compose
echo -e "${YELLOW}🐳 Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Install yq
echo -e "${YELLOW}📝 Installing yq...${NC}"
if ! command -v yq &> /dev/null; then
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')
    sudo wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

# Install stern (multi pod log tailing)
echo -e "${YELLOW}📋 Installing stern...${NC}"
if ! command -v stern &> /dev/null; then
    STERN_VERSION=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | jq -r '.tag_name')
    wget -q https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz
    tar -xzf stern_${STERN_VERSION#v}_linux_amd64.tar.gz
    sudo mv stern /usr/local/bin/
    rm stern_${STERN_VERSION#v}_linux_amd64.tar.gz
fi

# Install lazydocker
echo -e "${YELLOW}🐋 Installing lazydocker...${NC}"
if ! command -v lazydocker &> /dev/null; then
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

# Symlink dotfiles
echo -e "${YELLOW}🔗 Symlinking dotfiles...${NC}"
DOTFILES_DIR="$HOME/.dotfiles"

# Create symlinks
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${YELLOW}🐚 Changing default shell to zsh...${NC}"
    sudo chsh -s $(which zsh) $USER
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run: exec zsh${NC}"