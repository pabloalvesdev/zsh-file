#!/bin/bash
#!/bin/zsh

sudo apt upgrade

# Papel de parede
gsettings set org.gnome.desktop.background picture-uri 'https://r4.wallpaperflare.com/wallpaper/630/403/749/bixby-creek-bridge-bridge-big-sur-california-wallpaper-791078cd611a7dfb8617a80f0091860d.jpg'

# Chrome
echo "================================Download Chrome...================================"
wget -O ~/Downloads/chrome-installer https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
echo "================================Install Chrome...================================"
sudo dpkg -i ~/Downloads/chrome-installer
echo "================================Delete Chrome...================================"
rm ~/Downloads/chrome-installer

#Extensions
sudo apt update
sudo apt install chrome-gnome-shell gnome-shell-extensions
sudo apt install gnome-tweaks

# Hyper
echo "================================Download Hyper...================================"
wget -O ~/Downloads/hyper-installer https://github.com/vercel/hyper/releases/download/v3.4.1/hyper_3.4.1_amd64.deb
echo "================================Install Hyper...================================"
sudo dpkg -i ~/Downloads/hyper-installer
echo "================================Delete Hyper...================================"
rm ~/Downloads/hyper-installer

# VS Code
echo "================================Download VS Code...================================"
wget -O ~/Downloads/vscode-installer https://az764295.vo.msecnd.net/stable/97dec172d3256f8ca4bfb2143f3f76b503ca0534/code_1.74.3-1673284829_amd64.deb
echo "================================Install VS Code...================================"
sudo dpkg -i ~/Downloads/vscode-installer
echo "================================Delete VS Code...================================"
rm ~/Downloads/vscode-installer

# Hyper Config ZSH
echo "Install ZSH, Git, Curl..."
sudo apt install zsh
sudo apt install curl
sudo apt install git
echo "Config ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
sudo rm ~/.zshrc
echo "Alterando arquivo zshrc"
wget -O ~/.zshrc https://raw.githubusercontent.com/pabloalvesdev/zsh-file/master/.zshrc
chsh -s $(which zsh)
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /opt/Hyper/hyper 50
hyper install hyper-custom-controls

# Node Js
echo "================================Download NodeJs...================================"
wget -O ~/Downloads/node-v18.13.0-linux-x64.tar.xz https://nodejs.org/dist/v18.13.0/node-v18.13.0-linux-x64.tar.xz
echo "================================Install NodeJs...================================"
sudo tar xf ~/Downloads/node-v18.13.0-linux-x64.tar.xz --directory /opt
echo "================================Alterando ./profile...================================"
sed -i '5s/$/\n# NodeJS\nexport NODEJS_HOME=\/opt\/node-v18.13.0-linux-x64\/bin\nexport PATH=$NODEJS_HOME:$PATH/' ~/.profile
echo "================================Alterando ./zshrc...================================"
sed -i '2s/$/\n# NodeJS\nexport NODEJS_HOME=\/opt\/node-v18.13.0-linux-x64\/bin\nexport PATH=\$NODEJS_HOME:$PATH\n# Android Studio\nexport ANDROID_SDK_HOME="~\/Android\/Sdk"\nalias emulator="$ANDROID_SDK_HOME\/emulator\/emulator"\n\n#React Native\nexport ANDROID_HOME=$HOME\/Android\/Sdk\nexport PATH=$PATH:$ANDROID_HOME\/emulator\nexport PATH=$PATH:$ANDROID_HOME\/tools\nexport PATH=$PATH:$ANDROID_HOME\/tools\/bin\nexport PATH=$PATH:$ANDROID_HOME\/platform-tools/' ~/.zshrc
echo "================================Alterando ./bashrc...================================"
sed -i '4s/$/\n# NodeJS\nexport NODEJS_HOME=\/opt\/node-v18.13.0-linux-x64\/bin\nexport PATH=\$NODEJS_HOME:$PATH\n# Android Studio\nexport ANDROID_SDK_HOME="~\/Android\/Sdk"\nalias emulator="$ANDROID_SDK_HOME\/emulator\/emulator"\n\n#React Native\nexport ANDROID_HOME=$HOME\/Android\/Sdk\nexport PATH=$PATH:$ANDROID_HOME\/emulator\nexport PATH=$PATH:$ANDROID_HOME\/tools\nexport PATH=$PATH:$ANDROID_HOME\/tools\/bin\nexport PATH=$PATH:$ANDROID_HOME\/platform-tools/' ~/.bashrc
echo "Delete NodeJs..."
rm ~/Downloads/node-v18.13.0-linux-x64.tar.xz
. ~/.profile ~/.zshrc ~/.bashrc

# Discord
echo "================================Download Discord================================"
wget -O ~/Downloads/discord-installer https://dl.discordapp.net/apps/linux/0.0.24/discord-0.0.24.deb
echo "================================Install Discord================================"
sudo dpkg -i ~/Downloads/discord-installer
echo "================================Delete Discord================================"
rm ~/Downloads/discord-installer

#Depois fazer um if pro discord caso n de pra instalar


# install extensions GoogleChrome
declare -A EXTlist=(
    ["google-translate"]="aapbdbdomjkkjkaonfhkkikfgjllcleb"
    ["gnome-shell-integration"]="gphhapmejobijbbhgpjhcjognlahblep"
)
for i in "${!EXTlist[@]}"; do
    # echo "Key: $i value: ${EXTlist[$i]}"
    echo '{"external_update_url": "https://clients2.google.com/service/update2/crx"}' > /opt/google/chrome/extensions/${EXTlist[$i]}.json
done

#Install Yarn
echo "================================ Install Yarn ================================"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn

# Install JAVA
sudo apt install openjdk-11-jre-headless

# Install Watchman
echo "================================Download Watchman================================"
wget -O ~/Downloads/watchman-installer https://github.com/facebook/watchman/releases/download/v2023.03.06.00/watchman_ubuntu22.04_v2023.03.06.00.deb
echo "================================Install Discord================================"
sudo dpkg -i ~/Downloads/watchman-installer
echo "================================Delete Discord================================"
rm ~/Downloads/watchman-installer

# Install pgAdmin
# Install the public key for the repository (if not done previously):
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

# Create the repository configuration file:
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# Install for both desktop and web modes:
sudo apt install pgadmin4


# Install spotify
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client
