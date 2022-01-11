#!/bin/bash
# Ubuntu Web Server Initialize
# Author: Jerrico Duran (duran.jerrico@gmail.com)
# Version: 1.0
# Description: A utility script for congiruing ubuntu instances for web server development and deployment.

# for multi-platform support, create a script that copies and runs this file on the target server, then delete the copied file after execution.
# one method for doing this is through executing ssh commands



# color codes

# utility function yes/no selector
function ynPrompt () {
    ynOut=""
    local ynRes
    printf "\n"
    read -p "$1 (y/n?) (default: y) -> " -n 1 ynRes
    if [[ $ynRes = "y" ]] || [[ $ynRes = "Y" ]]; then
        ynOut="true"
        return 0
    elif [[ $ynRes = "n" ]] || [[ $ynRes = "N" ]]; then
        ynOut="false"
        return 0
    elif [[ $ynRes = "" ]]; then
        ynOut="true"
    else
        printf "\nunknown response"
        return 1
    fi
}

function varPrompt () {
    varOut=""
    local varRes
    printf "$2"
    printf "\n"
    read -p "(1-$1) (default: 1) -> " -n 1 varRes
    if [[ $varRes -gt 0 ]] && [[ $varRes -lt $(($1+1)) ]]; then
        varOut=$varRes
    elif [[ $varRes = "" ]]; then
        varOut=1 
    elif [[ $varRes -lt 1 ]] || [[ $varRes -gt $1 ]]; then
        printf "\nunknown response"
        return 1
    else
        printf "\nundefined error"
        return 3
    fi
}
# pass empty string to argument 2 for forced prompt
function stringPrompt () {
    stringOut=""
    while [[ $stringOut = "" ]]; do
        # variabe message prompt on default value
        if [[ $2 != "" ]]; then
            printf "\n"
            read -p "$1 (default: $2) -> " stringRes
        elif [[ $2 = "" ]]; then
            printf "\n"
            read -p "$1 (required) -> " stringRes
        fi
        
        # default value selector
        if [[ $2 != "" ]] && [[ $stringRes = "" ]]; then
            stringOut=$2
        elif [[ $2 != "" ]] && [[ $stringRes != "" ]]; then
            stringOut=$stringRes
        elif [[ $2 = "" ]] && [[ $stringRes = "" ]]; then
            printf "\n$1 cannot be empty"
        else
            printf "\nundefined error"
            return 3
        fi
    done
}
# pass "forced" to argument 2 for forced prompt
function passPrompt () {
    passOut=""
    local passLoop="true" passRes1 passRes2
    while [[ $passLoop = "true" ]]; do
        # variabe message prompt on default value
        if [[ $2 != "forced" ]]; then
            printf "\n"
            read -s -p "$1 (default: empty) -> " passRes1
        elif [[ $2 = "forced" ]]; then
            printf "\n"
            read -s -p "$1 (required) -> " passRes1
        fi

        # default value selector
        if [[ $2 != "forced" ]] && [[ $passRes1 = "" ]]; then
            passOut=""
            passLoop="false"
        elif [[ $2 != "forced" ]] && [[ $passRes1 != "" ]]; then
            printf "\n"
            read -s -p "repeat $1 -> " passRes2
            if [[ $passRes1 = $passRes2 ]]; then
                passOut=$pass1
                passLoop="false"
            elif [[ $passRes1 != $passRes2 ]]; then
                printf "\n$1 not match"
            else
                printf "\nundefined error"
            return 3
            fi
        elif [[ $2 = "forced" ]] && [[ $passRes1 = "" ]]; then
            printf "\n$1 cannot be empty"
        else
            printf "\nundefined error"
            return 3
        fi
    done
}

function getUserData() {
    printf "\ngettingusers..."
    eval users=$(eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d':' -f1,6)
    echo $(eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d':' -f1,6)
    printf "\n$users"
    return
}
# entry point: menu and installation options
function main {
    printf "\nUbuntu Web Server Initialize v1.0"
    printf "\nA utility script for configuring ubuntu instances for web server development and deployment"
    printf "\nNote: This script is intended for use with fresh installations.\nUse of this script on pre-configured instances is strongly discouraged."

    # 1. update
    printf "\nscript will perform update on packages\noption 1 will run \`dist-upgrade\` and install latest package dependencies"
    printf "\noption 2 will run \`upgrade\` without affecting dependencies"
    varPrompt "2" "\n1: dist-upgrade\n2: upgrade"
    if [[ $varOut -eq 1 ]]; then
        sudo apt -y dist-upgrade
    elif [[ $varOut -eq 2 ]]; then
        # sudo apt -y upgrade
        printf "\nskipping"
    else
        printf "\nunknown function output"
        return 2
    fi
    # sudo apt update -y

    # 2. SSH keys
    # select which user to install key to
    printf "\nretrieving system accounts"
    printf "\n"

    tmp=$(mktemp /tmp/usrData.XXXXXX)
    printf "\nTMP THEN: $tmp CONTENTS: $(cat $tmp)"
    (eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d':' -f1,6 > $tmp) & pid=$!
    local sp="—\|/" i=0
    while kill -0 $pid 2> /dev/null; do
        i=$(( (i+1) %4 ))
        printf "\rplease wait ${sp:$i:1}"
        sleep .1
    done
    printf "\nTMP NOW: $tmp CONTENTS: $(cat $tmp)"

    if userData=$(cat $tmp); then
        rm "$tmp"
    fi
    if [[ -f $tmp ]]; then echo "\nTMP EXISTS"; elif [[ ! -f $tmp ]]; then echo "\nTMP DOES NOT EXIST"; fi




    printf "\nuserData: $userData"
    local userName=$(grep -Po "^[_a-z][-\w_]*(?!:\/(?>[-\w_\/]*|[^\S\r\n]*)*[^\/]?$)?" <<< $userData)
    local userDir=$(grep -Po "^[_a-z][-\w_]*:\K\/(?>[-\w_\/]*|[^\S\r\n]*)*[^\/]?$" <<< $userData)
    printf "\nuserName: $userName"
    printf "\nuserDir: $userDir"

    printf "\n"
    read -p "Press enter to continue"
    # create varPrompt text that assigns a number to each user

    # get result of varPrompt then assign currentUser to lsUsers[<index of user directory>] from user input

    # check if .ssh directory exists
    printf "user: $USER"
    if [[ $HOME != /home/$USER ]]; then usermod -d /home/$USER $USER; fi
    if [[ ! -d $HOME/.ssh/ ]]; then mkdir $HOME/.ssh/; fi
    # check if authorized_keys file exists
    if [[ ! -d $HOME/.ssh/authorized_keys ]]; then touch $HOME/.ssh/authorized_keys; fi
    # check for folder ownership
    if [[ $(stat -c "%U" $HOME/.ssh/) != $USER ]]; then chown $USER: $HOME/.ssh; fi
    # check for file ownership
    if [[ $(stat -c "%U" $HOME/.ssh/authorized_keys) != $USER ]]; then chown $USER: $HOME/.ssh/authorized_keys; fi
    # check for file permissions
    if [[ $(stat -c %a $HOME/.ssh/) != "700" ]]; then chmod 700 $HOME/.ssh; fi
    if [[ $(stat -c %a $HOME/.ssh/authorized_keys) != "644" ]]; then chmod 644 $HOME/.ssh/authorized_keys; fi

    if [[ -s /.ssh/autohrized_keys ]]; then
        printf "\nssh \`authorized_keys\` file is empty"
    elif [[ ! -s /.ssh/autohrized_keys ]]; then
        printf "\n\`authorized_keys\` contains the following principals:"
        local principals=$(grep -Po "[a-z,A-Z,0-9\.\-]{2,}\@[a-z,A-Z,0-9\.\-]{2,}" $HOME/.ssh/authorized_keys)
        # make an automatically resizing gui based on list contents and their length
        local l=-1
        for x in ${principals[@]}; do
            if [[ ${#x} -gt $l ]]; then
                l=${#x}
            fi
        done
        local i=1 bar
        until [[ i -gt $l ]]; do
            bar="$bar="
            ((i++))
        done
        printf "\n$bar"
        for x in ${principals[@]}; do
            printf "\n${x}"
        done
        printf "\n$bar"
    fi
        printf "\nit is strongly recommended to inject ssh keys for this instance if not already"
        ynPrompt "inject SSH key?"
    if [[ $ynOut = "true" ]]; then
        stringPrompt "public key" ""
        publicKey=$stringOut
        echo $publicKey >> $HOME/.ssh/authorized_keys
    elif [[ $ynOut = "false" ]]; then
        printf "\nskipping ssh key injection"
    else
        printf "\nunknown function output"
        return 2
    fi
    printf "\n"
    

    # installation functions

    # 2. install packages

    # 3. configure system services

    # 4. configure nginx

    # 5. configure system settings

    # 6. configure network

    # 7. print ip addresses

    
    return 0
}
# call main function
main
printf "\nexiting script with status code $?...\n"
exit $?
