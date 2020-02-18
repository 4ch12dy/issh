#  _    _____    _____   _    _ 
# (_)  / ____|  / ____| | |  | |
#  _  | (___   | (___   | |__| |
# | |  \___ \   \___ \  |  __  |
# | |  ____) |  ____) | | |  | |
# |_| |_____/  |_____/  |_|  |_|
                              


iSSH_ROOT_DIR=`cat ~/.issh/rootdir`
iSSH_REMOTE_IP="$HOME/.issh/remote-ip"
iSSH_REMOTE_PORT="$HOME/.issh/remote-port"
REMOTE_IP="localhost"
REMOTE_PORT="2222"

function iSSHILOG(){

    echo -e "\033[32m[*]:$1 \033[0m"
}

function iSSHELOG(){
    
    echo -e "\033[31m[-]:$1 \033[0m"
    
}

function iSSHDLOG(){
    echo "[DEBUG]:$1" > /dev/null
}

function sshRunCMD(){
    iSSHILOG "Run $1"
    ssh root@$REMOTE_IP -p $REMOTE_PORT -o stricthostkeychecking=no "$1"
}

function sshRunCMDClean(){
    ssh root@$REMOTE_IP -p $REMOTE_PORT "$1" 
}

function iFileExsit(){
    # if exist return "1", Not return "0"
    ret=`sshRunCMDClean "[ -f $1 ] && echo "1" || echo "0""`
    echo $ret
}

function iDirExsit(){
    ret=`sshRunCMDClean "[ -d $1 ] && echo "1" || echo "0""`
    echo $ret
}

function removeRSA(){
    # cat ~/.ssh/known_hosts | grep -v "2222" && ( > ~/.ssh/known_hosts)|| (cat /dev/null > ~/.ssh/known_hosts)
    sed -i "" '/.*2222.*/d' ~/.ssh/known_hosts
}

function isshNoPWD(){
    if [[ "$1" = "clean" ]]; then
        iSSHILOG "rm authorized_keys and xia0_ssh.lock from device"
        sshRunCMD "rm /var/root/\.ssh/authorized_keys; rm /var/root/\.ssh/xia0_ssh.lock"
        return 0
    fi
    removeRSA
    #  check is need password
    ssh -p $REMOTE_PORT -o PasswordAuthentication=no -o StrictHostKeyChecking=no root@$REMOTE_IP "exit" 2>/dev/null ; 

    if [[ $? == 0 ]]; then

        iSSHILOG "++++++++++++++++++ Nice to Work :) +++++++++++++++++++++";

    else
        # check id_rsa.pub is exist?
        if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
            iSSHELOG "~/.ssh/id_rsa.pub is not exist, you should use ssh-keygen to create it!"
            return 1
        fi

        iSSHILOG "scp id_rsa.pub to connect iDevice [1/2]"
        scp -P 2222 -o StrictHostKeyChecking=no ~/.ssh/id_rsa.pub root@localhost:/tmp > /dev/null 2>&1
        if [[ $? == 1 ]]; then
            return 1
        fi

        iSSHILOG "add id_rsa.pub to authorized_keys [2/2]"
        
        sshScript="[ -d /var/root/\.ssh ] \
        || (mkdir -p /var/root/\.ssh);  \
        [ -f /var/root/\.ssh/authorized_keys ] \
        && (cat /tmp/id_rsa.pub >> /var/root/\.ssh/authorized_keys;touch /var/root/\.ssh/xia0_ssh.lock) \
        || (mv /tmp/id_rsa.pub /var/root/\.ssh/authorized_keys;touch  /var/root/\.ssh/xia0_ssh.lock)"

        # cat /dev/null > ~/.ssh/known_hosts
        ssh root@localhost -p 2222 -o stricthostkeychecking=no $sshScript 2> /dev/null
        
        iSSHILOG "++++++++++++++++++ Nice to Work :) +++++++++++++++++++++";
    fi

    return 0
}



function checkIproxy(){
    if hash iproxy 2>/dev/null; then 
        iSSHILOG "iproxy install. lets go"
    else 
        iSSHELOG "iproxy not install. try \"brew install usbmuxd\""
        return 1
    fi

    ret=`lsof -i tcp:2222 | grep "iproxy"`
    if [[ "$?" = "0" ]]; then
        iproxyPid=`echo $ret | awk '{print $2}'`
        iSSHILOG "iproxy process for 2222 port alive, pid=$iproxyPid"
    else
        iSSHILOG "iproxy process for 2222 port dead, start iproxy 2222 22"
        (iproxy 2222 22 &) > /dev/null 2>&1
        sleep 1
    fi
}

function printUsage(){
    iSSHILOG "First Run issh on new idevice, you will only input ssh password twice!"
    printf "issh %-30s %-20s \n" "ip [set, remove]" "set/remove ip to localhost or remote ip"
    printf "issh %-30s %-20s \n" "show [dylib/Preferences/apps]" "show some info" 
    printf "issh %-30s %-20s \n" "scp remote/local local/remote" "cp file from connect device or to device"
    printf "issh %-30s %-20s \n" "dump" "Use Frida(frida-ios-dump) to dump IPA"
    printf "issh %-30s %-20s \n" "debug [-a wechat -x backboard]" "auto sign debugserver[Test on iOS9/10/11/12] and happy to debug"
    printf "issh %-30s %-20s \n" "install" "install app form local to connect device"
    printf "issh %-30s %-20s \n" "device" "show some info about device"
    printf "issh %-30s %-20s \n" "screen" "get screenshot of device now"
    printf "issh %-30s %-20s \n" "log" "show system log of device"
    printf "issh %-30s %-20s \n" "crashlog" "get crash log info from device"
    printf "issh %-30s %-20s \n" "apps" "show current running app info"
    printf "issh %-30s %-20s \n" "fixnetwork" "fix cydia can not connect internet by remove network config "
    printf "issh %-30s %-20s \n" "du" "show idevice disk usage"
    printf "issh %-30s %-20s \n" "shell" "get the shell of connect device"
    printf "issh %-30s %-20s \n" "clean" "rm authorized_keys and xia0_ssh.lock from device"
    printf "issh %-30s %-20s \n" "run" "execute shell command on connect device"
    printf "issh %-30s %-20s \n" "respring" "kill SpringBoard"
    printf "issh %-30s %-20s \n" "ldrestart" "kill all daemon without reJailbreak"
    printf "issh %-30s %-20s \n" "reboot" "!!!if do reboot, you need reJailbreak!"
    printf "issh %-30s %-20s \n" "help/-h" "show this help info"
}


function initIPAndPort(){
    if [[ -f $iSSH_REMOTE_IP ]]; then
        REMOTE_IP=$(cat $iSSH_REMOTE_IP)
        REMOTE_PORT="22"
    else
        REMOTE_IP="localhost"
        REMOTE_PORT="2222"
    fi
}

function issh(){
    
    initIPAndPort

    # $setCmd
    # usage/help
    if [[ "$1" = "help" || "$1" = "-h" || $# == 0 ]]; then
        printUsage
        return
    fi

    if [[ "$1" = "ip" ]]; then
        if [[ "$2" = "-s" || "$2" = "set" ]]; then

            echo "$3" > $iSSH_REMOTE_IP

        elif [[ "$2" = "-r" || "$2" = "remove" ]]; then
            test -f $iSSH_REMOTE_IP && rm $iSSH_REMOTE_IP
        else
            test -f $iSSH_REMOTE_IP && cat $iSSH_REMOTE_IP || XADBILOG "not set remote ip"
        fi

        return 
    fi

    if [[ "$1" = "device" ]]; then
        # brew uninstall ideviceinstaller
        # brew uninstall libimobiledevice
        # brew uninstall usbmuxd
        # brew install usbmuxd --HEAD
        # brew install --HEAD libimobiledevice
        # brew unlink libimobiledevice && brew link libimobiledevice
        # brew install --HEAD ideviceinstaller
        # brew unlink ideviceinstaller && brew link ideviceinstaller
        # sudo chmod -R 777 /var/db/lockdown
        if hash ideviceinfo 2>/dev/null; then 
            iSSHILOG "libimobiledevice installed. continue..."
        else
            iSSHELOG "libimobiledevice not installed. try \"brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown\""
            brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown
            return
        fi

        DeviceName=`ideviceinfo -k DeviceName`
        SerialNumber=`ideviceinfo -k SerialNumber`
        ProductType=`ideviceinfo -k ProductType`
        ProductVersion=`ideviceinfo -k ProductVersion`
        ProductName=`ideviceinfo -k ProductName`
        PhoneNumber=`ideviceinfo -k PhoneNumber`
        UniqueChipID=`ideviceinfo -k UniqueChipID`
        UniqueDeviceID=`ideviceinfo -k UniqueDeviceID`
        InternationalMobileEquipmentIdentity=`ideviceinfo -k InternationalMobileEquipmentIdentity`

        printf "%-20s %-50s \n" "DeviceName" "$DeviceName"
        printf "%-20s %-50s \n" "ProductName" "$ProductName"
        printf "%-20s %-50s \n" "ProductType" "$ProductType"
        printf "%-20s %-50s \n" "ProductVersion" "$ProductVersion"
        printf "%-20s %-50s \n" "SerialNumber" "$SerialNumber"
        printf "%-20s %-50s \n" "UCID" "$UniqueChipID"
        printf "%-20s %-50s \n" "UDID" "$UniqueDeviceID"
        printf "%-20s %-50s \n" "IMEI" "$InternationalMobileEquipmentIdentity"
        printf "%-20s %-50s \n" "PhoneNumber" "$PhoneNumber"
        return
    fi

    if [[ "$1" = "screen" ]]; then
        # brew uninstall ideviceinstaller
        # brew uninstall libimobiledevice
        # brew uninstall usbmuxd
        # brew install usbmuxd --HEAD
        # brew install --HEAD libimobiledevice
        # brew unlink libimobiledevice && brew link libimobiledevice
        # brew install --HEAD ideviceinstaller
        # brew unlink ideviceinstaller && brew link ideviceinstaller
        # sudo chmod -R 777 /var/db/lockdown
        if hash ideviceinfo 2>/dev/null; then 
            iSSHILOG "libimobiledevice installed. continue..."
        else
            iSSHELOG "libimobiledevice not installed. try \"brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown\""
            brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown
            return
        fi
        idevicescreenshot
        return
    fi

    if [[ "$1" = "log" ]]; then
        # brew uninstall ideviceinstaller
        # brew uninstall libimobiledevice
        # brew uninstall usbmuxd
        # brew install usbmuxd --HEAD
        # brew install --HEAD libimobiledevice
        # brew unlink libimobiledevice && brew link libimobiledevice
        # brew install --HEAD ideviceinstaller
        # brew unlink ideviceinstaller && brew link ideviceinstaller
        # sudo chmod -R 777 /var/db/lockdown
        if hash ideviceinfo 2>/dev/null; then 
            iSSHILOG "libimobiledevice installed. continue..."
        else
            iSSHELOG "libimobiledevice not installed. try \"brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown\""
            brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown
            return
        fi
        idevicesyslog
        return
    fi

    if [[ "$1" = "crashlog" ]]; then
        # brew uninstall ideviceinstaller
        # brew uninstall libimobiledevice
        # brew uninstall usbmuxd
        # brew install usbmuxd --HEAD
        # brew install --HEAD libimobiledevice
        # brew unlink libimobiledevice && brew link libimobiledevice
        # brew install --HEAD ideviceinstaller
        # brew unlink ideviceinstaller && brew link ideviceinstaller
        # sudo chmod -R 777 /var/db/lockdown
        if hash ideviceinfo 2>/dev/null; then 
            iSSHILOG "libimobiledevice installed. continue..."
        else
            iSSHELOG "libimobiledevice not installed. try \"brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown\""
            brew install --HEAD libimobiledevice;sudo chmod -R 777 /var/db/lockdown
            return
        fi
        idevicecrashreport ${@:2:$#}
        return
    fi

    if [[ "$1" = "install" ]]; then
        if hash ideviceinstaller 2>/dev/null; then
            iSSHILOG "ideviceinstaller installed. continue..."
        else
            iSSHELOG "ideviceinstaller not installed. try \"brew install --HEAD ideviceinstaller\""
            brew install --HEAD ideviceinstaller
            return
        fi

        ideviceinstaller -i $2
        return
    fi

    if [[ $REMOTE_IP = "localhost" ]]; then
        checkIproxy
        if [[ $? == 1 ]]; then
            iSSHELOG "something wrong in iproxy, please check it"
            return 1
        fi
    else
        iSSHILOG "ip is not localhost, not need iproxy"
    fi

    # run isshNoPWD for no pwd login later
    if [[ "$1" = "clean" ]]; then
        # _sshRunCMD "cat $2" > "$3"
        isshNoPWD clean
    else
        isshNoPWD
    fi
    
    if [[ $? == 1 ]]; then
        iSSHELOG "failed to connect idevice, check the usb connect and make sure device jailbroken!"
        return 1
    fi

    # xia0 command
    if [ "$1" = "show" ];then
        case $2 in
            dylib )
                sshRunCMD "ls /Library/MobileSubstrate/DynamicLibraries"
                ;;

            pref* )
                sshRunCMD "ls /var/mobile/Library/Preferences/"
                ;;
            
            app* )
                issh listApp                
                ;;
            *)
                ;;
        esac
    fi

    if [[ "$1" = "scp" ]]; then
        targetFile="$2"
        # _sshRunCMD "cat $2" > "$3"
        if [[ -f "$targetFile" || -d "$targetFile" ]]; then
            iSSHILOG "$targetFile is local file, so cp it to device"
            scp -P $REMOTE_PORT -r "$targetFile" root@$REMOTE_IP:$3
            return
        fi
        iSSHILOG "$targetFile is remote file, so cp it from device"
        scp -P $REMOTE_PORT -r root@$REMOTE_IP:$targetFile $3
    fi


    if [[ "$1" = "debug" ]]; then
        debugArgs=${@:2:$#}
        #  create iOSRE dir if need
        ret=`iDirExsit /iOSRE`
        if [[ "$ret" = "1" ]]; then
            iSSHILOG "iOSRE dir exist"
        else
            iSSHILOG "iOSRE dir not exist"
            sshRunCMD "mkdir -p /iOSRE/tmp;mkdir -p /iOSRE/dylib;mkdir -p /iOSRE/deb;mkdir -p /iOSRE/tools"
        fi

        ret1=`iFileExsit /Developer/usr/bin/debugserver`
        ret2=`iFileExsit /iOSRE/tools/debugserver`
        if [[ "$ret" = "0" && ret2 = "0" ]]; then
            iSSHELOG "/Developer/usr/bin/debugserver not exist. please connect idevice to Xcode"
            iSSHELOG "also you can get all iOS DeviceSupport file at https://github.com/iGhibli/iOS-DeviceSupport"
            return
        fi
        
        # check iproxy 1234 port is open?
        ret=`lsof -i tcp:1234 | grep "iproxy"`
        if [[ "$?" = "0" ]]; then
            iproxyPid=`echo $ret | awk '{print $2}'`
            iSSHILOG "iproxy process for 1234 port alive, pid=$iproxyPid"
        else
            iSSHILOG "iproxy process for 1234 port dead, start iproxy 1234 1234"
            (iproxy 1234 1234 &) > /dev/null 2>&1
            sleep 1
        fi

        # check debugserver is alive

        killDebugserverIfAlive="ps -e | grep debugserver | grep -v grep; [[ $? == 0 ]] && (killall -9 debugserver 2> /dev/null)"

        sshRunCMD "$killDebugserverIfAlive"
        
        # kill app process if use -x backboard  
        if [[ "$debugArgs" =~ "backboard" ]]; then
            iSSHILOG "kill app because debug with -x backboard"
            
            tmpAppPath=$(echo $debugArgs | awk '{print $NF}')
            tmpAppExename=$(basename $tmpAppPath)
            killAppIfAlive="ps -e | grep $tmpAppPath | grep -v grep; [[ $? == 0 ]] && (killall -9 $tmpAppExename 2> /dev/null)"
            sshRunCMD "$killAppIfAlive"
        fi
        
        # check tools debugserver
        ret=`iFileExsit /iOSRE/tools/debugserver`
        if [[ "$ret" = "1" ]]; then
            iSSHILOG "/iOSRE/tools/debugserver file exist, Start debug..."
            sshRunCMD "/iOSRE/tools/debugserver 127.0.0.1:1234 $debugArgs"
        else
            iSSHILOG "/iOSRE/tools/debugserver file not exist"

            # create ent.xml 
            sshRunCMD 'cat > /iOSRE/tmp/ent.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.backboardd.debugapplications</key>
    <true/>
    <key>com.apple.backboardd.launchapplications</key>
    <true/>
    <key>com.apple.diagnosticd.diagnostic</key>
    <true/>
    <key>com.apple.frontboard.debugapplications</key>
    <true/>
    <key>com.apple.frontboard.launchapplications</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.springboard.debugapplications</key>
    <true/>
    <key>com.apple.system-task-ports</key>
    <true/>
    <key>get-task-allow</key>
    <true/>
    <key>platform-application</key>
    <true/>
    <key>run-unsigned-code</key>
    <true/>
    <key>task_for_pid-allow</key>
    <true/>
</dict>
</plist> 
EOF'
        
            debugCMD="cp /Developer/usr/bin/debugserver /iOSRE/tmp/;\
            cd /iOSRE/tmp;ldid -Sent.xml /iOSRE/tmp/debugserver;\
            chmod +x  /iOSRE/tmp/debugserver;\
            cp /iOSRE/tmp/debugserver /iOSRE/tools/;\
            "
            sshRunCMD "$debugCMD"
            sshRunCMD "/iOSRE/tools/debugserver 127.0.0.1:1234 $debugArgs"
        fi

    fi


    if [[ "$1" = "listApp" ]]; then
        function handleXargs(){
            infoPlist=$1
            scp -P $REMOTE_PORT -r "root@$REMOTE_IP:$infoPlist" /tmp/isshAppTest
        }

        ret=`sshRunCMDClean "hash defaults > /dev/null 2>&1 && echo 1 || echo 0"`
        if [[ "$ret" = "0" ]]; then
            iSSHELOG "defaults not exist. install defaults from https://xia0z.github.io"
            return
        fi

        mkdir -p /tmp/isshAppTest
        # CFBundleDisplayName
        # sshRunCMDClean "find /var/containers/Bundle/Application/ -regex \"[^\.]*/[^\.]*\.app/Info\.plist$\" -print0 | \
        # xargs -0 -i echo \"root@localhost:{}\" /tmp/isshAppTest " | xargs -n 2
        # sshRunCMDClean "find /var/containers/Bundle/Application/ -regex \"[^\.]*/[^\.]*\.app/Info\.plist$\"" | \
        # xargs -I% sh -c "echo "\n%"; scp -P 2222 -r root@localhost:\"'%'\" /tmp/isshAppTest > /dev/null 2>&1; defaults read /tmp/isshAppTest/Info.plist CFBundleIdentifier;";
        sshRunCMD "find /var/containers/Bundle/Application/ -regex \"[^\.]*/[^\.]*\.app$\" -exec sh -c \" echo '=========';echo \"{}\";defaults read \"{}/Info.plist\" CFBundleIdentifier; \
        defaults read \"{}/Info.plist\" CFBundleExecutable; defaults read \"{}/Info.plist\" CFBundleDisplayName; \" \;"

        sshRunCMD "find /Applications/ -regex \"[^\.]*/[^\.]*\.app$\" -exec sh -c \" echo '=========';echo \"{}\";defaults read \"{}/Info.plist\" CFBundleIdentifier; \
        defaults read \"{}/Info.plist\" CFBundleExecutable; defaults read \"{}/Info.plist\" CFBundleDisplayName; \" \;"
    fi

    if [[ "$1" =~ "app" ]]; then
        # PSOUT=$(sshRunCMDClean "ps -ef | egrep '/var/containers/Bundle/Application|/Applications' | grep -v egrep")
        # echo $PSOUT
        ret=`sshRunCMDClean "hash defaults > /dev/null 2>&1 && echo 1 || echo 0"`
        if [[ "$ret" = "0" ]]; then
            iSSHELOG "defaults not exist. install defaults from https://xia0z.github.io"
            return
        fi

        PSOUT=$(sshRunCMDClean "ps -ef  | grep -v grep | egrep '/var/containers/Bundle/Application|/Applications'" )
        # echo $sss
        appPathArr=()
        appPidArr=()
        while read line 
        do
            # x=`echo "$line" | sed -e s/\>/\\\\\\>/g`
 
            process=( $line )
            appPid=${process[1]}
            appPath=${process[7]}

            # appDir=$(dirname $appPath)
           
            # appBundleid=$(sshRunCMDClean "defaults read $appDir/Info.plist CFBundleIdentifier")
            # echo $appBundleid
            array=(${appPath//// })
            if [[ ${#array[@]} -eq 7 || ${#array[@]} -eq 33 ]]; then
                appPidArr[${#appPidArr[*]}]="$appPid"
                appPathArr[${#appPathArr[*]}]="$appPath"
            fi

        done <<EOF
$PSOUT
EOF
        printf "==========\n"
        printf "%-5s %-25s %-50s\n" "Pid" "Bundleid" "$App path"
        for i in "${!appPathArr[@]}"; do 
            curAppDir=$(dirname ${appPathArr[$i]})
            curAppBundleid=$(sshRunCMDClean "defaults read $curAppDir/Info.plist CFBundleIdentifier")
            curAppPid=${appPidArr[$i]}
            curAppPath=${appPathArr[$i]}

            array=(${curAppPath//// })
            if [[ ${#array[@]} -eq 7 || ${#array[@]} -eq 33 ]]; then
                printf "%-5s %-25s %-50s\n" "$curAppPid" "$curAppBundleid" "$curAppPath"
            fi
            
        done
        printf "==========\n"
        return
    fi

    if [[ "$1" = "dump" ]]; then
        dumpArgs=${@:2:$#}
        dumpFile=$iSSH_ROOT_DIR"/frida-ios-dump/dump.py"; 
        echo $dumpFile

        if [ ! -f $dumpFile ];then
            cd $iSSH_ROOT_DIR && git clone https://github.com/AloneMonkey/frida-ios-dump.git;
            pip install --user -r $iSSH_ROOT_DIR"/frida-ios-dump/requirements.txt" --upgrade
        fi

        python "$dumpFile" $dumpArgs
    fi

    if [[ "$1" = "iOSRE" ]]; then
        ret=`iDirExsit /iOSRE`
        if [[ "$ret" = "1" ]]; then
            iSSHILOG "iOSRE dir exist"
        else
            iSSHILOG "iOSRE dir not exist"
            sshRunCMDC "mkdir -p /iOSRE/tmp;mkdir -p /iOSRE/dylib;mkdir -p /iOSRE/deb;mkdir -p /iOSRE/tools"
        fi
    fi

    if [[ "$1" = "fixnetwork" ]]; then
        sshRunCMD "rm /Library/Preferences/com.apple.networkextension.plist /Library/Preferences/com.apple.networkextension.necp.plist /Library/Preferences/com.apple.networkextension.cache.plist"
    fi

    if [[ "$1" = "du" ]]; then
        shellCMD="echo "========";path=$2;du -k -d 0 \$path/* 2>/dev/null | sort -hr | awk '
        function keep2(x){
            printf(\"%.1f\", x)
        }
        function human(x) {
            if (x<1000) {return x \"K\"} else {x/=1024}
            s=\"MGTEPZY\";
            while (x>=1000 && length(s)>1)
                {x/=1024; s=substr(s,2)}
            return keep2(x) substr(s,1,1)
        }
        {sub(/^[0-9]+/, human(\$1)); print}' "
        # sshRunCMD "du $2 -sh * | sort -r -h"
        sshRunCMD "$shellCMD"
    fi


    if [[ "$1" = "run" ]]; then
        sshRunCMD "$2"
    fi

    if [ "$1" = "shell" ];then

        ssh root@$REMOTE_IP -p $REMOTE_PORT -o stricthostkeychecking=no

    fi

    if [[ "$1" = "respring" ]]; then
        sshRunCMD "killall -9 SpringBoard"
    fi

    if [[ "$1" = "ldrestart" ]]; then
        sshRunCMD "/usr/bin/ldrestart"
    fi

    if [[ "$1" = "reboot" ]]; then
        sshRunCMD "reboot"
    fi
}