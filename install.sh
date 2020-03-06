#!/bin/bash
root_dir=$(pwd)
issh_name="issh.sh"
issh_shell_file="$root_dir/$issh_name"
bash_profile="$HOME/.bash_profile"
zsh_profile="$HOME/.zshrc"

echo "==== install issh ===="
if [[ ! -d ~/.issh ]]; then
    mkdir -p ~/.issh
fi

echo "$root_dir" > ~/.issh/rootdir

if [[ "$SHELL" = "/bin/zsh" || "$SHELL" = "/usr/local/bin/zsh" ]]; then

    sh_profile=$zsh_profile

elif [[ "$SHELL" = "/bin/bash" ]]; then

    sh_profile=$bash_profile

else
    echo "[-] not Support shell:$SHELL"
    exit
fi

echo "[+] detect current shell profile: $sh_profile"

sed -i "" '/source.*issh\.sh/d' $sh_profile 2>/dev/null
# add issh.sh to shell_profile
echo "[*] add \"source $issh_shell_file\" to $sh_profile"
echo -e "\nsource $issh_shell_file" >> $sh_profile

# done 
echo "[+] install finished, you can re-source $sh_profile or open a new terminal"
echo "======================"