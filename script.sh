#!/bin/bash
targets=("1.Google" "2.VS Code" "3.Hyper" "4.Node" "5.React Native" "6.Yarn" "7.ZSH")

resultado=""

for str in "${targets[@]}"; do
    resultado="${resultado}${str}\n"
done

echo -e "O que você quer configurar? Escolha uma das opções abaixo:\n\n$resultado"
echo -n "Resposta: "
read option


config_google_chrome() {
    echo "================================ Download Chrome... ================================"
    wget -O ~/Downloads/chrome-installer https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    echo "================================ Install Chrome... ================================"
    sudo dpkg -i ~/Downloads/chrome-installer
    echo "================================ Delete Chrome... ================================"
    rm ~/Downloads/chrome-installer
}
config_vscode() {
    URL="https://code.visualstudio.com/docs/?dv=linux64_deb"
    # Use o curl para fazer o download da página
    pagina=$(curl -s "$URL")
    echo $pagina
}
config_node() {

    # URL da página web
    URL="https://nodejs.org/en"

    pagina=$(curl -s "$URL")

    # Use grep e awk para extrair a primeira tag "a" com "LTS" no atributo "title"
    tag_a=$(echo "$pagina" | grep -o '<a [^>]*title="[^"]*LTS[^"]*"[^>]*>.*</a>' | head -n 1)

    # Extrair o valor do atributo "data-version" da tag "a"
    VERSION=$(echo "$tag_a" | awk -F 'data-version="' '{print $2}' | awk -F '"' '{print $1}')
    DISTRO="linux-x64"
    
    #Download arquivo
    echo "================================ Downloading NodeJs... ================================"
    wget -O ~/Downloads/node-$VERSION-$DISTRO.tar.xz https://nodejs.org/dist/$VERSION/node-$VERSION-$DISTRO.tar.xz

    # Diretório de destino
    INSTALL_DIR="/usr/local/lib/nodejs"

    # Crie o diretório de destino se não existir
    sudo mkdir -p $INSTALL_DIR

    # Descompacte o arquivo binário
    sudo tar -xJvf ~/Downloads/node-$VERSION-$DISTRO.tar.xz -C $INSTALL_DIR && rm -f ~/Downloads/node-$VERSION-$DISTRO.tar.xz

    # Passo 2: Configure a variável de ambiente no ~/.profile
    PROFILE_FILE="$HOME/.profile"

    # Verifique se o arquivo ~/.profile existe
    if [ -f "$PROFILE_FILE" ]; then
    # Verifique se a variável já está definida no ~/.profile
    if grep -q "export PATH=.*node-$VERSION-$DISTRO/bin" "$PROFILE_FILE"; then
        echo "A variável de ambiente já está definida em $PROFILE_FILE"
    else
        echo "export PATH=$INSTALL_DIR/node-$VERSION-$DISTRO/bin:\$PATH" | sudo tee -a "$PROFILE_FILE"
        echo "Variável de ambiente adicionada ao $PROFILE_FILE"
    fi
    else
    echo "O arquivo $PROFILE_FILE não foi encontrado. Certifique-se de configurar a variável de ambiente manualmente."
    fi

    # Passo 3: Atualizar o perfil
    . ~/.profile

    echo "Node.js $VERSION foi instalado e configurado com sucesso."
}
config_react_native() {
    # JAVA_VERSION="11"
    # echo "Instalando JAVA"
    # sudo apt install openjdk-$JAVA_VERSION-jre-headless

    # #android-studio
    
    # ANDROID_STUDIO_VERSION="2022.3.1.19"
    # LINK_DOWNLOAD="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$ANDROID_STUDIO_VERSION/android-studio-$ANDROID_STUDIO_VERSION-linux.tar.gz"
    URL="https://developer.android.com/studio"

    # Faz o download da página da web
    page_content=$(curl -s "$URL")

    # Use o comando grep para encontrar a primeira tag "a" com os atributos desejados
    # e extrair o valor do atributo "href"
    href=$(echo "$page_content" | grep -oP '<a[^>]+data-category="sdk_linux_download"[^>]+data-action="download"[^>]+href="\K[^"]+')

    # Imprime o valor do atributo "href"
    echo "O valor do atributo href é: $href"
}
config_yarn() {
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install yarn
}
config_hyper() {
    url="https://releases.hyper.is/download/deb"
    echo "================================Download Hyper...================================"
    wget -O ~/Downloads/hyper-installer $url
    echo "================================Install Hyper...================================"
    sudo dpkg -i ~/Downloads/hyper-installer
    echo "================================Delete Hyper...================================"
    rm ~/Downloads/hyper-installer
}
config_zsh() {
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
    sleep 10
    echo "Alterando arquivo zshrc"
    wget -O ~/.zshrc https://raw.githubusercontent.com/pabloalvesdev/zsh-file/master/.zshrc
    chsh -s $(which zsh)
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /opt/Hyper/hyper 50
    hyper install hyper-custom-controls
}

case $option in
    "1")
        echo "Configurando Chrome"
        config_google_chrome
        ;;
    "2")
        echo "Configurando VS Code"
        config_vscode
        ;;
    "3")
        echo "Configurando Hyper"
        config_hyper
        ;;
    "4")
        echo "Configurando Node"
        config_node
        ;;
    "5")
        echo "Configurando React Native"
        config_react_native
        ;;
    "6")
        echo "Configurando YARN..."
        config_yarn
        ;;
    "7")
        echo "Configurando ZSH..."
        config_zsh
        ;;
    *)
        echo "Opção inválida"
        ;;
esac
