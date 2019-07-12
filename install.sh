#!/bin/bash
shell_root_dir=$(pwd)
shell_file_name="issh.sh"
shell_file=$shell_root_dir"/"$shell_file_name

bash_profile=$HOME"/.bash_profile"
zsh_profile=$HOME"/.zshrc"


function xlog(){
    echo "[log]: "$1
}

if [[ ! -d ~/.issh ]]; then
	mkdir -p ~/.issh
fi
echo "$shell_root_dir" > ~/.issh/rootdir

if [[ "$SHELL" = "/bin/zsh" ]]; then
	# add issh.sh to bash_profile
	xlog "source "$zsh_profile

	grep 'issh.sh' $zsh_profile > /dev/null
	if [ $? -eq 0 ]; then
	    xlog $zsh_profile" has include "$shell_file_name" just source it."
	else
	    xlog "not install. gogogo..."
	    echo -e "\nsource $shell_file" >> $zsh_profile
	fi

	zsh -c "source $zsh_profile > /dev/null"
	xlog "done!"
	exit
fi


# add issh.sh to bash_profile
xlog "source "$bash_profile
grep 'issh.sh' $bash_profile > /dev/null
if [ $? -eq 0 ]; then
    xlog $bash_profile" has include "$shell_file_name" just source it."
else
    xlog "not install. gogogo..."
    echo -e "\nsource $shell_file" >> $bash_profile
fi

source $bash_profile > /dev/null
xlog "done!"