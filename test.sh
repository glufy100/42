#!/bin/bash

# Script pour installer et configurer Zsh avec une configuration personnalisée.
# Compatible avec Debian/Ubuntu, Fedora/CentOS, et Arch Linux.

# --- Variables de couleur pour une sortie plus lisible ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Fonctions ---

# Détecte le gestionnaire de paquets et installe les dépendances
install_dependencies() {
    echo -e "${BLUE}Détection de la distribution et installation des dépendances...${NC}"
    
    local pkgs="zsh git fzf zoxide"
    
    if command -v apt-get &> /dev/null; then
        echo "Distribution de type Debian/Ubuntu détectée."
        sudo apt-get update
        sudo apt-get install -y $pkgs
    elif command -v dnf &> /dev/null; then
        echo "Distribution de type Fedora/CentOS détectée."
        sudo dnf install -y $pkgs
    elif command -v pacman &> /dev/null; then
        echo "Distribution de type Arch Linux détectée."
        sudo pacman -Syu --noconfirm $pkgs
    else
        echo -e "${YELLOW}Gestionnaire de paquets non supporté. Veuillez installer manuellement : zsh, git, fzf, zoxide.${NC}"
        exit 1
    fi
}

# Sauvegarde la configuration existante et crée le nouveau .zshrc
setup_zshrc() {
    echo -e "${BLUE}Configuration du fichier ~/.zshrc...${NC}"

    # Sauvegarde de l'ancien .zshrc s'il existe
    if [ -f "$HOME/.zshrc" ]; then
        echo -e "${YELLOW}Fichier .zshrc existant trouvé. Sauvegarde en cours vers ~/.zshrc.bak...${NC}"
        mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi

    echo "Création du nouveau fichier ~/.zshrc."
    # Utilisation de cat avec un 'heredoc' pour écrire le fichier de configuration
cat << 'EOF' > "$HOME/.zshrc"
# Configuration Zsh avec le thème risto

# Activation du prompt subst nécessaire pour les thèmes OMZ
setopt promptsubst

# Options de configuration avancées
HYPHEN_INSENSITIVE="true"        # Traite - et _ comme équivalents lors de la complétion
ENABLE_CORRECTION="true"         # Corrige automatiquement les fautes de frappe
COMPLETION_WAITING_DOTS="true"   # Affiche des points pendant l'attente d'une complétion
HIST_STAMPS="mm/dd/yyyy"         # Format de date pour l'historique

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Prompt temporaire simple pendant le chargement
PS1="READY > "

# Chargement de la bibliothèque git et du plugin git en mode Turbo
zinit wait lucid for \
    OMZL::git.zsh \
    atload"unalias grv" \
    OMZP::git

# Chargement du thème risto avec les fonctions prompt nécessaires
zinit wait'!' lucid for \
    OMZL::prompt_info_functions.zsh \
    OMZT::risto

# Chargement des plugins en mode Turbo
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab \
    OMZP::sudo

# Load completions (sera appelé automatiquement par zicompinit dans fast-syntax-highlighting)
# autoload -Uz compinit && compinit

# zinit cdreplay -q (pas nécessaire avec zicdreplay)

# Configuration du thème risto
# Le thème sera chargé automatiquement via Zinit Turbo mode

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion:*' ignore-case 'yes'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 50 8
zstyle ':fzf-tab:*' show-group none
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Configuration pour l'affichage automatique de fzf-tab
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Support pour HYPHEN_INSENSITIVE et correction
setopt CORRECT                    # Correction des commandes
setopt CORRECT_ALL               # Correction des arguments (optionnel)

# Aliases utiles
alias ls='ls --color'
# alias vim='nvim' # Décommentez si vous utilisez Neovim
alias c='clear'

# Fonction pour navigation directe (tapez juste le nom du dossier)
setopt AUTO_CD

# Fonction pour complétion intelligente des répertoires
setopt CDABLE_VARS

# Alias pour écraser la commande test et aller dans le dossier test
test() {
    if [[ -d "./test" ]]; then
        cd test
    else
        # Fallback vers la vraie commande test si le dossier n'existe pas
        command test "$@"
    fi
}

# Shell integrations
# Check if fzf supports --zsh flag, fallback to older method
if fzf --zsh &>/dev/null; then
    eval "$(fzf --zsh)"
else
    # Fallback for older fzf versions
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    # Or try the distribution-specific locations
    [ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
    [ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh
fi

eval "$(zoxide init --cmd cd zsh)"
EOF
}

# --- Script principal ---

echo -e "${GREEN}Démarrage de l'installation de la configuration Zsh...${NC}"

install_dependencies
setup_zshrc

# Proposer de changer le shell par défaut
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${YELLOW}Votre shell actuel n'est pas Zsh.${NC}"
    read -p "Voulez-vous définir Zsh comme votre shell par défaut ? (o/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        if chsh -s "$(which zsh)"; then
            echo -e "${GREEN}Shell par défaut changé en Zsh.${NC}"
            echo -e "${YELLOW}Veuillez vous déconnecter et vous reconnecter pour que le changement prenne effet.${NC}"
        else
            echo -e "${YELLOW}Impossible de changer le shell. Veuillez le faire manuellement avec 'chsh -s \$(which zsh)'${NC}"
        fi
    fi
fi

echo -e "\n\n${GREEN}--- Installation terminée ! ---${NC}"
echo -e "\n${YELLOW}Étapes finales importantes :${NC}"
echo -e "1. ${BLUE}Démarrez une nouvelle session Zsh :${NC} Fermez et rouvrez votre terminal (ou déconnectez-vous/reconnectez-vous)."
echo
echo -e "2. ${BLUE}Le thème risto sera automatiquement chargé${NC} - aucune configuration supplémentaire n'est nécessaire."
echo
echo "Profitez de votre nouveau shell avec le thème risto !"