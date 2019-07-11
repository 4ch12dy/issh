# issh
> 自动登录ssh，自动打开端口映射，自动签名debugserver，一键调试，一键shell等等，越狱设备用issh就够了



### install

- `git clone issh_git_project;`
- `cd issh`
- `./install.sh`

### command

- `issh shell`

  get the shell of connect device

- `issh debug [debugArgs:-a pid/processName -x backboard/auto]`

  like `issh debug -a wechat` attach the wechat app

- `issh dump [dumpArgs:-l]`

  用的庆哥的frida-ios-dump脚本，会自动下载并运行

- `issh run "cmd"`

  run shell command on connect idevice like `issh run ls`

- `issh respring/reboot`

  注销和重启设备

  

  

  

  

  

  