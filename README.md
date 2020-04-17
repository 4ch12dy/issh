# issh
> issh is a tool like adb on android for iOS reversing and debugging. save your time for working on jailbroken idevice.



### Introduction 

Nothing,  It's just for me to work on jailbreak device. Some commands can save fxxk time.

if you stuck in setup iOS debug environment, here is you need. 



### Install

> defaults command is need，it can get from cydia repo[https://xia0z.github.io](https://xia0z.github.io)

- `git clone issh_git_project;`
- `cd issh`
- `./install.sh`
- If your shell is bash run: `source ~/.bash_profile` 
- If your shell is zsh run :`source ~/.zshrc`


**Notice: issh some commands may not support zsh, it recommend you to use bash**

### Commands

```bash
[*]:First Run issh on new idevice, you will only input ssh password twice! 
issh ip [set, remove]               set/remove ip to localhost or remote ip 
issh show [dylib/Preferences/apps]  show some info       
issh scp remote/local local/remote  cp file from connect device or to device 
issh dump                           Use Frida(frida-ios-dump) to dump IPA 
issh debug [-a wechat -x backboard] auto sign debugserver[Test on iOS9/10/11/12] and happy to debug 
issh install                        install app form local to connect device 
issh device                         show some info about device 
issh screen                         get screenshot of device now 
issh log                            show system log of device 
issh crashlog                       get crash log info from device 
issh apps                           show current running app info 
issh fixnetwork                     fix cydia can not connect internet by remove network config  
issh du                             show idevice disk usage 
issh shell                          get the shell of connect device 
issh clean                          rm authorized_keys and xia0_ssh.lock from device 
issh run                            execute shell command on connect device 
issh respring                       kill SpringBoard     
issh ldrestart                      kill all daemon without reJailbreak 
issh reboot                         !!!if do reboot, you need reJailbreak! 
issh help/-h                        show this help info 
```


### Screenshot

...

### Credits

- https://github.com/AloneMonkey/frida-ios-dump
- https://github.com/libimobiledevice/usbmuxd

