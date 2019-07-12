#!/bin/bash
shell_root_dir=$(pwd)
shell_file_name="issh.sh"
shell_file=$shell_root_dir"/"$shell_file_name

bash_profile=$HOME"/.bash_profile"



function xlog(){
    echo "[log]: "$1
}

if [[ ! -d ~/.issh ]]; then
	mkdir -p ~/.issh
fi
echo "$shell_root_dir" > ~/.issh/rootdir


grep 'issh.sh' $bash_profile > /dev/null
if [ $? -eq 0 ]; then
    xlog $bash_profile" has include "$shell_file_name" just source it."
    source $bash_profile
    exit 0
else
    xlog "not install. gogogo..."
fi


echo -e "\nsource $shell_file" >> $bash_profile

xlog "source "$bash_profile

source $bash_profile > /dev/null

xlog "done!"