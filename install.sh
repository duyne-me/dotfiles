#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting DevOps/SRE dotfiles installation..."

# Detect OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "OS: $OS"
echo "Architecture: $ARCH"

# Update and install basic packages
echo "📦 Installing basic packages..."
sudo apt-get update -qq
sudo apt-get install -y curl wget git zsh vim unzip jq python3-pip bat fzf ripgrep htop

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🎨 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
echo "🔌 Installing zsh plugins..."
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
echo "☸️  Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install kubectx and kubens
echo "🔄 Installing kubectx and kubens..."
if ! command -v kubectx &> /dev/null; then
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
fi

# Install k9s
echo "🐕 Installing k9s..."
if ! command -v k9s &> /dev/null; then
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
    wget -q https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
    tar -xzf k9s_Linux_amd64.tar.gz
    sudo mv k9s /usr/local/bin/
    rm k9s_Linux_amd64.tar.gz LICENSE README.md
fi

# Install Helm
echo "⎈ Installing Helm..."
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Install Terraform
echo "🏗️  Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r '.tag_name' | sed 's/v//')
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# Install AWS CLI
echo "☁️  Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install gcloud CLI
echo "☁️  Installing gcloud CLI..."
if ! command -v gcloud &> /dev/null; then
    curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
    echo 'source $HOME/google-cloud-sdk/path.zsh.inc' >> ~/.zshrc
    echo 'source $HOME/google-cloud-sdk/completion.zsh.inc' >> ~/.zshrc
fi

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Install yq
echo "📝 Installing yq..."
if ! command -v yq &> /dev/null; then
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')
    sudo wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

# Install stern (multi pod log tailing)
echo "📋 Installing stern..."
if ! command -v stern &> /dev/null; then
    STERN_VERSION=$(curl -s https://api.github.com/repos/stern/stern/releases/latest | jq -r '.tag_name')
    wget -q https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz
    tar -xzf stern_${STERN_VERSION#v}_linux_amd64.tar.gz
    sudo mv stern /usr/local/bin/
    rm stern_${STERN_VERSION#v}_linux_amd64.tar.gz
fi

# Install lazydocker
echo "🐋 Installing lazydocker..."
if ! command -v lazydocker &> /dev/null; then
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

# Symlink dotfiles
echo "🔗 Symlinking dotfiles..."
# Lấy đường dẫn của thư mục chứa script này một cách linh hoạt
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Danh sách các file cần symlink
dotfiles=(".zshrc" ".gitconfig" ".vimrc")

# Tạo symlink cho từng file
for file in "${dotfiles[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        echo "Creating symlink for $file"
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    else
        echo "Warning: $file not found in $DOTFILES_DIR. Skipping."
    fi
done

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Changing default shell to zsh..."
    sudo chsh -s $(which zsh) $USER
fi

echo "✅ Installation complete!"
echo "Please restart your terminal or run: exec zsh"