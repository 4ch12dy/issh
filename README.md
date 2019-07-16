# issh
> 自动登录ssh，自动打开端口映射，自动签名debugserver，一键调试，一键shell等等，越狱设备用issh就够了


### Install

> Before install, make sure you have installed iproxy,cfgutil cmds

- `git clone issh_git_project;`
- `cd issh`
- `./install.sh`
- If your shell is bash run: `source ~/.bash_profile` 
- If your shell is zsh run :`source ~/.zshrc`

### Command

- `issh shell`

  get the shell of connect device

- `issh debug [debugArgs:-a pid/processName -x backboard/auto]`

  like `issh debug -a wechat` attach the wechat app

  配合[xia0LLDB](https://github.com/4ch12dy/xia0LLDB)食用更加

- `issh dump [dumpArgs:-l]`

  用的frida-ios-dump脚本，会自动下载并运行

- `issh run "cmd"`

  run shell command on connect idevice like `issh run ls`

- `issh respring/reboot`

  注销和重启设备

- `issh apps`

  显示所有app（包括系统app），包名，显示名，进程名，完整路径等


### Screenshot

![issh-debug](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-debug.png?raw=true)



![issh-device](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-device.png?raw=true)



![issh-dump](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-dump.png?raw=true)



![issh-install](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-install.png?raw=true)



![issh-run](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-run.png?raw=true)



![issh-scp](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-scp.png?raw=true)



![issh-shell](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-shell.png?raw=true)



![issh-show-dylib](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-show-dylib.png?raw=true)

### Credits

- https://github.com/AloneMonkey/frida-ios-dump
- https://github.com/libimobiledevice/usbmuxd

