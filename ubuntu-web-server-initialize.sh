#!/bin/bash
# Ubuntu Web Server Initialize
# Author: Jerrico Duran (duran.jerrico@gmail.com)
# Version: 1.0
# Description: A utility script for congiruing ubuntu instances for web server development and deployment.

# for multi-platform support, create a script that copies and runs this file on the target server, then delete the copied file after execution.
# one method for doing this is through executing ssh commands



# color codes

# UTILITY FUNCTIONS
# 1: Prompt string (default=true)
function ynPrompt () {
    local ynRes
    printf "\n"
    read -p "$1 (y/n?) (default: y) -> " -n 1 ynRes
    if [[ $ynRes = "y" || $ynRes = "Y" ]]; then
        return 0
    elif [[ $ynRes = "n" || $ynRes = "N" ]]; then
        return 1
    elif [[ $ynRes = "" ]]; then
        printf "\033[2K\033[1A"
        printf "$1 (y/n?) (default: y) -> y"
        return 0
    else
        printf "\nunknown response"
        return 2
    fi
}

# 1: Max choices (default=1), 2: Prompt string
function varPrompt () {
    varOut=""
    local varRes
    printf "$2"
    printf "\n"
    read -p "(1-$1) (default: 1) -> " -n 1 varRes
    if [[ $varRes -gt 0 && $varRes -lt $(($1+1)) ]]; then
        varOut=$varRes
    elif [[ $varRes = "" ]]; then
        printf "\033[2K\033[1A"
        printf "(1-$1) (default: 1) -> 1"
        varOut=1 
    elif [[ $varRes -lt 1 || $varRes -gt $1 ]]; then
        printf "\nunknown response"
        return 1
    else
        printf "\nundefined error"
        return 3
    fi
}

# 1: Prompt string, 2: Default value (empty=forced)
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
            printf "\033[2K\033[1A"
            printf "$1 (default: $2) -> $2"
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

function continuePrompt () {
    printf "\n"
    read -p "Press enter to continue"
    printf "\033[2K\033[1A                       "
}

# 1: Array name, 2: Label mode (empty=unlabelled, 1=numbered)
function dispList () {
    # declarations
    local -n arr=$1
    local arrLen=${#arr[@]} bar i l=-1 n

    # get longest string length
    for i in ${!arr[@]}; do
        if [[ ${#arr[$i]} -gt $l ]]; then
            l=${#arr[$i]}
        fi
    done
    # compensate l length according to label mode
    if [[ $2 -eq 1 ]]; then
        ((l+= ${#arrLen} + 2))
    fi
    # generate bar string
    until [[ ${#bar} -eq $l ]]; do
        bar+="="
    done

    # display list
    printf "\n$bar"
    # unnumbered list
    if [[ -z $2 || $2 = "" ]]; then
        for i in ${!arr[@]}; do
            # display array element
            printf "\n${arr[$i]}"
        done
    # numbered list
    elif [[ $2 -eq 1 ]]; then
        for i in ${!arr[@]}; do
            # # offset zero-index to start list at 1 with n placeholder for list number
            n="$(($i + 1)):"
            # compare n with longest number length
            until [[ ${#n} -gt ${#arrLen} ]]; do
                # add whitespace
                n+=" "
            done
            # display array element
            printf "\n$n ${arr[$i]}"
        done
    fi
    printf "\n$bar"
    return
}

# 1: Output array, # 2: List array 1, #3: List array 2
function alignList () {
    # declarations
    local -n outArr=$1 inArr1=$2 inArr2=$3
    local i l=-1 str tmpArr

    # get longest string length
    for i in ${!inArr1[@]}; do
        if [[ ${#inArr1[$i]} -gt $l ]]; then
            l=${#inArr1[$i]}
        fi
    done

    # compare string with length then add whitespace
    for i in ${!inArr1[@]}; do
        str=${inArr1[$i]}
        until [[ ${#str} -eq $l ]]; do
            str+=" "
        done
        tmpArr+=("$str |")
    done

    # append second array if exists
    if [[ -n $inArr2 || ${#inArr2[@]} -ne 0 || $inArr2 != ""  ]]; then
        for i in ${!tmpArr[@]}; do
            outArr+=("${tmpArr[$i]} ${inArr2[$i]}")
        done
    elif [[ -z $inArr2 || ${#inArr2[@]} -eq 0 || $inArr2 = ""  ]]; then
        outArr=(${tmpArr[@]})
    fi 
}



# ENTRY POINT
function main () {
    {   # Menu
        printf "================================="
        printf "\nUbuntu Web Server Initialize v1.0"
        printf "\n================================="
        printf "\nA utility script for configuring ubuntu instances for web server development and deployment"
        printf "\nNote: This script is intended for use with fresh installations.\nUse of this script on pre-configured instances is strongly discouraged."
        printf "\n"
    }
    {   # 1. Update
        printf "\nscript will perform update on packages:"
        varPrompt "2" "\n1: dist-upgrade will install latest package dependencies\n2: upgrade is recommended for mission-critical environments"
        if [[ $varOut -eq 1 ]]; then
            sudo apt -y dist-upgrade
        elif [[ $varOut -eq 2 ]]; then
            # sudo apt -y upgrade
            printf "\nskipping"
        else
            printf "\nunknown function output"
            return 2
        fi
        printf "\n"
        # sudo apt update -y
    }
    {   # 2. SSH keys
        if ynPrompt "Inject SSH Key?" && [[ $? -ne 2 ]]; then
            printf "\nretrieving system accounts"
            printf "\n"
            {   # get userData
                local tmp=$(mktemp /tmp/usrData.XXXXXX)
                (eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d':' -f1,6 > $tmp) & pid=$!
                local sp="—\|/" i=0
                # spinner
                while kill -0 $pid 2> /dev/null; do
                    i=$(( (i+1) %4 ))
                    printf "\rplease wait ${sp:$i:1}"
                    sleep .1
                done
                printf "\r             "
                if userData=$(cat $tmp); then
                    rm "$tmp"
                fi
                # select which user to install key to
                local userNames=($(grep -Po "^[_a-z][-\w_]*(?!:\/(?>[-\w_\/]*|[^\S\r\n]*)*[^\/]?$)?" <<< $userData))
                local userDirs=($(grep -Po "^[_a-z][-\w_]*:\K\/(?>[-\w_\/]*|[^\S\r\n]*)*[^\/]?$" <<< $userData))
                alignList listUserNamesDirs userNames userDirs
                varPrompt ${#userNames[@]} "\nplease select a user$(dispList listUserNamesDirs 1)"
                # define selectedUser
                local selectedUserDir=${userDirs[(($varOut - 1))]} selectedUserName=${userNames[(($varOut - 1))]}
                printf "\nselected: $varOut=$selectedUserDir"
                printf "\n"

                # check if user directory is normal
                if [[ $selectedUserDir != /home/$selectedUserName ]]; then
                    printf "\nuser directory in /home not found"
                    printf "\nchanging user directory..."
                    continuePrompt
                    usermod -d /home/$selectedUserName $selectedUserName
                fi

                # check if .ssh directory exists
                if [[ ! -d $selectedUserDir/.ssh/ ]]; then
                    printf "\n.ssh directory does not exist"
                    printf "\ncreating .ssh directory"
                    continuePrompt
                    mkdir $selectedUserDir/.ssh/;
                fi

                # check if authorized_keys file exists
                if [[ ! -f $selectedUserDir/.ssh/authorized_keys ]]; then
                    printf "\nauthorized_keys file does not exist"
                    printf "\ncreating authorized_keys file..."
                    continuePrompt
                    touch $selectedUserDir/.ssh/authorized_keys;
                fi
                # check for file-folder ownership
                if [[ $(stat -c "%U" $selectedUserDir/.ssh/) != $selectedUserName ]]; then chown $selectedUserName: $selectedUserDir/.ssh; fi
                if [[ $(stat -c "%U" $selectedUserDir/.ssh/authorized_keys) != $selectedUserName ]]; then chown $selectedUserName: $selectedUserDir/.ssh/authorized_keys; fi
                # check for file-folder permissions
                if [[ $(stat -c %a $selectedUserDir/.ssh/) != "700" ]]; then chmod 700 $selectedUserDir/.ssh; fi
                if [[ $(stat -c %a $selectedUserDir/.ssh/authorized_keys) != "644" ]]; then chmod 644 $selectedUserDir/.ssh/authorized_keys; fi

                # check contents of authorized_keys
                if [[ -s $selectedUserDir/.ssh/autohrized_keys ]]; then
                    printf "\nssh \`authorized_keys\` file is empty"
                elif [[ ! -s $selectedUserDir/.ssh/autohrized_keys ]]; then
                    printf "\nauthorized_keys contains the following principals:"
                    local principals=($(grep -Po "[a-z,A-Z,0-9\.\-]{2,}\@[a-z,A-Z,0-9\.\-]{2,}" $selectedUserDir/.ssh/authorized_keys))
                    dispList principals
                    continuePrompt
                fi 
                # paste key prompt
                printf "\n"
                printf "Paste your certificate:\n"
                IFS= read -d '' -n 1 publicKey   
                while IFS= read -d '' -n 1 -t 2 c
                do
                    publicKey+=$c
                done
                printf "\nPublic key:\n$publicKey"
                continuePrompt
                
                echo $publicKey >> $selectedUserDir/.ssh/authorized_keys
            }
        elif [[ $? -eq 1 || $? -eq 2 ]]; then
            printf "\nskipping ssh key injection"
        else
            printf "undefined error"
            return 1
        fi
    }


    # 2. install packages
    for x in $packages[@]; do
        case $x in
            npm+node)
                ;;
            nodejs)
                ;;
            nginx)
                ;;
            dgraph)
                ;;
        esac
    done
    # npm nodejs nginx

    # 3. configure system services

    # 4. configure system settings
        # -max file watchers limit
        # ssh timeout

    # 5. optional configure nginx

    # 6. optional configure network (if nginx template applied)

    # 7. print ip addresses

    # 8. custom commands (dgraphstat, systemstat, nginxreload)

    
    return 0
}
# call main function
main
printf "\nexiting script with status code $?...\n"
exit $?
