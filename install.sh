#!/bin/bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'
CYAN='\033[0;36m'

# Default values
TARGET_DIR="$HOME/yolo-ai-cmdbot"
CREATE_VENV=1
CONFIGURE_SHELL=1
CREATE_OPTIONAL=0

# Check for required files
echo -e "${BLUE}${BOLD}Checking required files...${NC}"
for file in yolo.py prompt.txt yolo.yaml ai_model.py; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: $file is missing in $(pwd), cannot install${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All required files found${NC}\n"

# Print installation options
print_options() {
    echo -e "${BLUE}${BOLD}Installation Options:${NC}"
    echo -e "1. Full Installation (Recommended)"
    echo -e "   - Creates virtual environment"
    echo -e "   - Configures shell integration"
    echo -e "   - Installs all dependencies\n"
    
    echo -e "2. Minimal Installation"
    echo -e "   - No virtual environment"
    echo -e "   - Basic shell aliases only"
    echo -e "   - Manual dependency management\n"
    
    echo -e "3. Custom Installation"
    echo -e "   - Choose components to install"
    echo -e "   - Configure paths manually\n"
    
    echo -e "4. Cancel Installation\n"
}

# Print optional files menu
print_optional_menu() {
    echo -e "\n${BLUE}${BOLD}Optional Files:${NC}"
    echo -e "\nNote: By default, Yolo uses G4F which requires no API key."
    echo -e "These options are only needed if you want to use other providers.\n"
    echo -e "[Y] Yes - Create optional API key files"
    echo -e "[N] No  - Skip (recommended for G4F)"
    echo -e "[O] Only create optional files and exit"
    echo -e "[C] Cancel"
}

handle_optional_files() {
    clear
    print_optional_menu
    read -p "Let me know which option you want to select [Y/N/O/C]: " choice
    case "$choice" in
        [Yy])
            create_api_key_files
            ;;
        [Oo])
            create_api_key_files
            exit 0
            ;;
        [Cc])
            echo -e "\n${YELLOW}Cancelled optional files setup${NC}"
            ;;
        *)
            echo -e "\n${GREEN}Skipping optional files (using G4F by default)${NC}"
            ;;
    esac
}

create_api_key_files() {
    echo -e "\n${BLUE}${BOLD}Creating optional API key files...${NC}"
    
    # Create .env file
    if [ ! -f "$TARGET_DIR/.env" ]; then
        mkdir -p "$TARGET_DIR"
        cat > "$TARGET_DIR/.env" << EOL
# API Keys for different providers
OPENAI_API_KEY=
AZURE_OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GROQ_API_KEY=
EOL
        chmod 600 "$TARGET_DIR/.env"
        echo -e "${GREEN}✓ Created .env template at $TARGET_DIR/.env${NC}"
    else
        echo -e "${YELLOW}⚠ .env file already exists, skipping${NC}"
    fi

    # Create .openai.apikey file
    if [ ! -f "$HOME/.openai.apikey" ]; then
        read -p "Would you like to create .openai.apikey file? [y/N]: " create_apikey
        if [[ "$create_apikey" =~ ^[Yy]$ ]]; then
            read -p "Enter your OpenAI API key (or press Enter to skip): " apikey
            if [ ! -z "$apikey" ]; then
                echo "$apikey" > "$HOME/.openai.apikey"
                chmod 600 "$HOME/.openai.apikey"
                echo -e "${GREEN}✓ Created .openai.apikey at $HOME/.openai.apikey${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ .openai.apikey already exists, skipping${NC}"
    fi
}

# Create API key file
create_apikey_file() {
    echo -e "\n${BLUE}${BOLD}Creating API Key File...${NC}"
    read -p "Enter your OpenAI API key (or press Enter to skip): " api_key
    if [ -n "$api_key" ]; then
        echo "$api_key" > "$HOME/.openai.apikey"
        chmod 600 "$HOME/.openai.apikey"  # Set secure permissions
        echo -e "${GREEN}✓ API key file created at ~/.openai.apikey${NC}"
    fi
}

# Create environment file
create_env_file() {
    echo -e "\n${BLUE}${BOLD}Creating .env File...${NC}"
    # Ensure target directory exists
    mkdir -p "$TARGET_DIR"
    
    if [ ! -f "$TARGET_DIR/.env" ]; then
        cat > "$TARGET_DIR/.env" << EOL
# API Keys for different providers
OPENAI_API_KEY=
AZURE_OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GROQ_API_KEY=
EOL
        chmod 600 "$TARGET_DIR/.env"  # Set secure permissions
        echo -e "${GREEN}✓ .env template created at $TARGET_DIR/.env${NC}"
    else
        echo -e "${YELLOW}⚠ .env file already exists, skipping${NC}"
    fi
}

# Handle optional files
handle_optional_files_menu() {
    print_optional_menu
    read -p "Select an option (Y/N/O/C): " opt
    case ${opt:0:1} in
        [Yy]*)
            CREATE_OPTIONAL=1
            ;;
        [Nn]*)
            CREATE_OPTIONAL=0
            ;;
        [Oo]*)
            create_apikey_file
            create_env_file
            exit 0
            ;;
        [Cc]*)
            echo -e "${RED}Installation cancelled${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            handle_optional_files_menu
            ;;
    esac
}

# Get user choice
get_choice() {
    local choice
    read -p "Select an option (1-4): " choice
    case $choice in
        1) # Full installation
            CREATE_VENV=1
            CONFIGURE_SHELL=1
            ;;
        2) # Minimal installation
            CREATE_VENV=0
            CONFIGURE_SHELL=1
            ;;
        3) # Custom installation
            echo -e "\n${BLUE}${BOLD}Custom Installation Options:${NC}"
            read -p "Create virtual environment? (y/n): " venv_choice
            [[ $venv_choice == "y" ]] && CREATE_VENV=1 || CREATE_VENV=0
            
            read -p "Configure shell integration? (y/n): " shell_choice
            [[ $shell_choice == "y" ]] && CONFIGURE_SHELL=1 || CONFIGURE_SHELL=0
            
            read -p "Enter installation directory [$TARGET_DIR]: " custom_dir
            [[ -n $custom_dir ]] && TARGET_DIR=$custom_dir
            ;;
        4) # Cancel
            echo -e "${RED}Installation cancelled${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please select 1-4${NC}"
            get_choice
            ;;
    esac
}

# Main installation process
main_install() {
    # Create target directory
    echo -e "\n${BLUE}${BOLD}Setting up Yolo AI Command Bot...${NC}"
    echo -e "Installation directory: ${BOLD}$TARGET_DIR${NC}"
    mkdir -p $TARGET_DIR
    
    # Copy files
    echo -e "\n${BLUE}${BOLD}Copying files...${NC}"
    cp yolo.py prompt.txt yolo.yaml ai_model.py requirements.txt $TARGET_DIR
    echo -e "${GREEN}✓ Files copied successfully${NC}"
    
    # Setup virtual environment if requested
    if [ $CREATE_VENV -eq 1 ]; then
        echo -e "\n${BLUE}${BOLD}Creating virtual environment...${NC}"
        python3 -m venv $TARGET_DIR/venv
        source $TARGET_DIR/venv/bin/activate
        pip install -r $TARGET_DIR/requirements.txt
        deactivate
        echo -e "${GREEN}✓ Virtual environment created and dependencies installed${NC}"
    fi
    
    # Configure shell integration if requested
    if [ $CONFIGURE_SHELL -eq 1 ]; then
        echo -e "\n${BLUE}${BOLD}Configuring shell integration...${NC}"
        
        # Function definition for bash/zsh
        YOLO_FUNCTION="
# Yolo AI Command Bot
function yolo-ai() {
    if [ -f \"$TARGET_DIR/venv/bin/activate\" ]; then
        source \"$TARGET_DIR/venv/bin/activate\"
        python \"$TARGET_DIR/yolo.py\" \"\$@\"
        deactivate
    else
        python \"$TARGET_DIR/yolo.py\" \"\$@\"
    fi
}"

        # Function definition for fish
        FISH_FUNCTION="
# Yolo AI Command Bot
function yolo-ai
    if test -f \"$TARGET_DIR/venv/bin/activate.fish\"
        source \"$TARGET_DIR/venv/bin/activate.fish\"
        python \"$TARGET_DIR/yolo.py\" \$argv
        deactivate
    else
        python \"$TARGET_DIR/yolo.py\" \$argv
    end
end"
        
        # Add to appropriate shell config
        if [[ "$SHELL" == "/bin/bash" ]]; then
            ALIASES_FILE="$HOME/.bash_aliases"
            # Create .bash_aliases if it doesn't exist
            touch "$ALIASES_FILE"
            # Add source .bash_aliases to .bashrc if not already there
            if ! grep -q "source ~/.bash_aliases" "$HOME/.bashrc"; then
                echo "if [ -f ~/.bash_aliases ]; then" >> "$HOME/.bashrc"
                echo "    source ~/.bash_aliases" >> "$HOME/.bashrc"
                echo "fi" >> "$HOME/.bashrc"
            fi
            echo "$YOLO_FUNCTION" >> "$ALIASES_FILE"
            echo "alias yolo='yolo-ai'" >> "$ALIASES_FILE"
            echo "alias computer='yolo-ai'" >> "$ALIASES_FILE"
            echo -e "${GREEN}✓ Added configuration to ${BOLD}~/.bash_aliases${NC}"
            # Source bashrc immediately
            exec bash -l
        elif [[ "$SHELL" == "/bin/zsh" ]]; then
            ZSHRC="$HOME/.zshrc"
            echo "$YOLO_FUNCTION" >> "$ZSHRC"
            echo "alias yolo='yolo-ai'" >> "$ZSHRC"
            echo "alias computer='yolo-ai'" >> "$ZSHRC"
            echo -e "${GREEN}✓ Added configuration to ${BOLD}~/.zshrc${NC}"
            # Source zshrc immediately
            exec zsh -l
        elif [[ "$SHELL" == "/usr/bin/fish" ]] || [[ "$SHELL" == "/bin/fish" ]]; then
            FISH_DIR="$HOME/.config/fish/functions"
            mkdir -p "$FISH_DIR"
            echo "$FISH_FUNCTION" > "$FISH_DIR/yolo-ai.fish"
            echo "alias yolo 'yolo-ai'" > "$FISH_DIR/yolo.fish"
            echo "alias computer 'yolo-ai'" > "$FISH_DIR/computer.fish"
            echo -e "${GREEN}✓ Fish functions created${NC}"
            # Source fish config immediately
            exec fish -l
        else
            echo -e "${RED}Unsupported shell ($SHELL). Please add aliases manually:${NC}"
            echo -e "Add these lines to your shell's configuration file:"
            echo "$YOLO_FUNCTION"
            echo "alias yolo='yolo-ai'"
            echo "alias computer='yolo-ai'"
        fi
        echo -e "${GREEN}✓ Shell integration configured${NC}"
    fi
}

# Print API key guide
print_apikey_guide() {
    echo -e "\n${BLUE}${BOLD}API Key Configuration Guide:${NC}"
    echo -e "\nYou have several options to configure your API keys:"
    
    echo -e "\n${BOLD}1. Environment Variables (Recommended)${NC}"
    echo -e "Add to your shell's rc file (~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish):"
    echo -e "   export OPENAI_API_KEY=\"your-key-here\""
    echo -e "   export AZURE_OPENAI_API_KEY=\"your-key-here\""
    echo -e "   export ANTHROPIC_API_KEY=\"your-key-here\""
    echo -e "   export GROQ_API_KEY=\"your-key-here\""
    
    echo -e "\n${BOLD}2. Configuration File${NC}"
    echo -e "Edit ${BOLD}$TARGET_DIR/yolo.yaml${NC} and add your keys:"
    echo -e "   openai_api_key: your-key-here"
    echo -e "   azure_openai_api_key: your-key-here"
    echo -e "   anthropic_api_key: your-key-here"
    echo -e "   groq_api_key: your-key-here"
    
    echo -e "\n${BOLD}3. Environment File${NC}"
    echo -e "Create ${BOLD}$TARGET_DIR/.env${NC} with:"
    echo -e "   OPENAI_API_KEY=your-key-here"
    echo -e "   AZURE_OPENAI_API_KEY=your-key-here"
    echo -e "   ANTHROPIC_API_KEY=your-key-here"
    echo -e "   GROQ_API_KEY=your-key-here"
    
    echo -e "\n${GREEN}${BOLD}Note:${NC} The default configuration uses G4F which ${GREEN}doesn't require an API key!${NC}"
    echo -e "To use other providers, configure the appropriate API key and update ${BOLD}yolo.yaml${NC}"
    echo -e "Supported providers: OpenAI, Azure OpenAI, Anthropic (Claude), Groq, Ollama, and G4F\n"
}

# Print success message
print_success() {
    echo -e "\n${GREEN}${BOLD}Installation Complete!${NC}"
    echo -e "\nTo start using Yolo AI Command Bot:"
    echo -e "1. Restart your terminal or run: ${BOLD}source ~/.$(basename $SHELL)rc${NC}"
    echo -e "2. Run: ${BOLD}yolo what time is it${NC}"
    echo -e "\nFor configuration options, check: ${BOLD}$TARGET_DIR/yolo.yaml${NC}"
    if [ $CREATE_VENV -eq 1 ]; then
        echo -e "Virtual environment is at: ${BOLD}$TARGET_DIR/venv${NC}"
    fi
}

print_completion_guide() {
    echo -e "\n${GREEN}${BOLD}✓ Finished Installing Yolo${NC}"
    echo -e "\nRun commands using:"
    echo -e "  ${CYAN}\`yolo [Enter Prompt Here]\`${NC}"
    
    # Print warning about directory dependencies
    echo -e "\n${YELLOW}${BOLD}Warning:${NC}"
    if [ "$CUSTOM_INSTALL" = true ]; then
        echo -e "If ${TARGET_DIR} is moved or deleted, the yolo command will not work."
    else
        echo -e "If the installation directory is moved or deleted, the yolo command will not work."
    fi
    echo -e "You will need to run install.sh again to recreate the configuration."
    
    # Print API configuration guide
    echo -e "\n${BLUE}${BOLD}API Key Configuration:${NC}"
    echo -e "\nBy default, Yolo uses G4F which requires no API key."
    echo -e "However, if you want to use other providers, you'll need their respective API keys."
    echo -e "\nThere are multiple options for providing API keys:"
    
    echo -e "\n1. ${BOLD}Environment Variables${NC} (Recommended)"
    echo -e "   Add these to your shell's config file (.bashrc, .zshrc, or config.fish):"
    echo -e "   ${CYAN}export OPENAI_API_KEY=\"[yourkey]\""
    echo -e "   export AZURE_OPENAI_API_KEY=\"[yourkey]\""
    echo -e "   export ANTHROPIC_API_KEY=\"[yourkey]\""
    echo -e "   export GROQ_API_KEY=\"[yourkey]\"${NC}"
    
    echo -e "\n2. ${BOLD}Configuration File${NC}"
    echo -e "   Edit yolo.yaml and add your keys:"
    echo -e "   ${CYAN}Location: ${TARGET_DIR}/yolo.yaml${NC}"
    
    echo -e "\n3. ${BOLD}Environment File${NC}"
    echo -e "   Create or edit .env file with your keys:"
    echo -e "   ${CYAN}Location: ${TARGET_DIR}/.env${NC}"
    
    echo -e "\n4. ${BOLD}API Key File${NC}"
    echo -e "   For OpenAI, you can also use:"
    echo -e "   ${CYAN}Location: ~/.openai.apikey${NC}"
    
    echo -e "\n${BOLD}Supported Providers:${NC}"
    echo -e "- G4F (Default, no key needed)"
    echo -e "- OpenAI"
    echo -e "- Azure OpenAI"
    echo -e "- Anthropic (Claude)"
    echo -e "- Groq"
    echo -e "- Ollama"
    
    echo -e "\nTo change providers, update the 'api' setting in yolo.yaml"
}

finish_installation() {
    if [ $? -eq 0 ]; then
        print_completion_guide
        echo -e "\n${GREEN}${BOLD}Installation Complete!${NC}"
    else
        echo -e "\n${RED}${BOLD}Installation failed. Please check the errors above.${NC}"
    fi
}

# Main execution
clear
echo -e "${BOLD}Welcome to Yolo AI Command Bot Installer${NC}\n"
print_options
get_choice
handle_optional_files_menu
if [ $CREATE_OPTIONAL -eq 1 ]; then
    create_apikey_file
    create_env_file
fi
main_install
print_apikey_guide
finish_installation
