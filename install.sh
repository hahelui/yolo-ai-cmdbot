# Simple installer for yolo in the user's home directory

echo "Hello. Installing yolo..."
echo "- Creating yolo-ai-cmdbot in home directory..."
TARGET_DIR=~/yolo-ai-cmdbot
TARGET_FULLPATH=$TARGET_DIR/yolo.py
mkdir -p $TARGET_DIR

echo "- Copying files..."
cp yolo.py prompt.txt yolo.yaml ai_model.py requirements.txt $TARGET_DIR
chmod +x $TARGET_FULLPATH

echo "- Creating virtual environment..."
python3 -m venv $TARGET_DIR/venv
source $TARGET_DIR/venv/bin/activate
pip install -r $TARGET_DIR/requirements.txt
deactivate

# Creates two aliases for use
echo "- Creating yolo and computer aliases..."
AI_FUNCTION="
# Ai yolo script
function yolo-ai() {
    source \"$TARGET_DIR/venv/bin/activate\"
    python \"$TARGET_FULLPATH\" \"\$@\"
    deactivate
}"

# Add the aliases to the logon scripts
# Depends on your shell
if [[ "$SHELL" == "/bin/bash" ]]; then
  echo "- Adding aliases to ~/.bash_aliases"
  echo "$AI_FUNCTION" >> ~/.bash_aliases
  [ "$(grep '^alias yolo=' ~/.bash_aliases)" ]     && echo "alias yolo already created"     || echo "alias yolo='yolo-ai'"     >> ~/.bash_aliases 
  [ "$(grep '^alias computer=' ~/.bash_aliases)" ] && echo "alias computer already created" || echo "alias computer='yolo-ai'" >> ~/.bash_aliases
elif [[ "$SHELL" == "/bin/zsh" ]]; then
  echo "- Adding aliases to ~/.zshrc"
  echo "$AI_FUNCTION" >> ~/.zshrc
  [ "$(grep '^alias yolo=' ~/.zshrc)" ]     && echo "alias yolo already created"     || echo "alias yolo='yolo-ai'"     >> ~/.zshrc 
  [ "$(grep '^alias computer=' ~/.zshrc)" ] && echo "alias computer already created" || echo "alias computer='yolo-ai'" >> ~/.zshrc
else
  echo "Note: Shell was not bash or zsh."
  echo "      Consider configuring aliases (like yolo and/or computer) manually by adding them to your login script, e.g:"
  echo "      alias yolo=$TARGET_FULLPATH     >> <your_logon_file>"
fi

echo
echo "Done."
echo
echo "Make sure you have your LLM key (e.g. OpenAI API) set via one of these options:" 
echo "  - environment variable"
echo "  - .env or in"
echo "  - yolo.yaml"
echo
echo "Or just stick to the default configuration which uses G4f, No API key is required."
echo
echo "Yolo also supports Azure OpenAI, Ollama, groq, Claude, G4f now. Change settings in yolo.yaml accordingly."
echo
echo "You can now run `yolo` or `computer` to start yolo."
echo "Have fun!"
