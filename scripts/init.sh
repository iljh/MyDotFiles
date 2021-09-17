#!/bin/bash

ANDROID_HOME=$HOME/.local/android
isSudoExist=true
if [ ! -x "$(command -v sudo)" ]; then
    isSudoExist=false
fi
# update system
if [ "$isSudoExist" = true ]; then
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt auto-remove -y
    # install required softwares
    sudo apt install build-essential git curl tmux zsh openjdk-8-jdk -y
else
    apt update -y
    apt upgrade -y
    apt auto-remove -y
    # install required softwares
    apt install build-essential git curl tmux zsh openjdk-8-jdk -y
fi

# on-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ ! -d "$HOME/.local/bin" ]; then
    echo "create $HOME/.local/bin directory"
    mkdir -pv $HOME/.local/bin
fi

# android sdk
function installAndroidSdk() {
    if [ -x "$(command -v sdkmanager)" ]; then
        return 0
    fi

    if [ ! -d "$ANDROID_HOME" ]; then
        mkdir -pv $ANDROID_HOME
    fi

    if [ ! -d "$ANDROID_HOME/cmdline-tools" ]; then
        mkdir -pv $ANDROID_HOME/cmdline-tools
    fi

    if [ ! -d "$HOME/.local/android/cmdline-tools/tools" ]; then
      curl -o /tmp/cmdline-tools.zip -L https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
      unzip /tmp/cmdline-tools.zip -d $HOME/.local/android/cmdline-tools/
      cd $HOME/.local/android/cmdline-tools/
      mv cmdline-tools tools
    fi

    sdkmanager --install "platforms;android-31"
}

installAndroidSdk

# tmux
function compileInstallTmux() {
    sudo apt install libevent-dev libncurses5-dev bison -y
    git clone https://github.com/tmux/tmux.git /tmp/tmux
    cd /tmp/tmux && git checkout 3.2a
    sh autogen.sh && ./configure --prefix=$HOME/.local && make -j && make install
}

if [ ! -x "$HOME/.local/bin/tmux" ]; then
    echo "tmux not find in custom path, try install..."
    compileInstallTmux
fi


# neovim
function compileInstallNvim() {
    git clone https://github.com/neovim/neovim.git /tmp/neovim
    if [ "$isSudoExist" = true ]; then
        sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl -y
    else
        apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl -y
    fi
    cd /tmp/neovim
    cmake -Hthird-party -B.deps -GNinja && cmake --build .deps
    cmake -H. -BBuild -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=$HOME/.local && cmake --build Build --target install
}

if [ ! -x "$HOME/.local/bin/nvim" ]; then
    echo "neovim not find in custom path, try install..."
    compileInstallNvim
fi

# pip3
function installPip3() {
    PYTHON_VERSON=$(python3 --version | cut -d' ' -f 2)
    echo $PYTHON_VERSON
    if [ ! -x "$(command -v pip3)" ]; then
        curl -o /tmp/get-pip3.py -L https://bootstrap.pypa.io/get-pip.py
	python3 /tmp/get-pip3.py
    fi
}

installPip3


# node
if [ ! -x "$(command -v npm)" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi
if [ -f "$HOME/.zshrc" ]; then
    source ~/.zshrc
fi
nvm install node && npm install -g neovim
