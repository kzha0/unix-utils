#!/bin/bash




# shellGL
# A shell graphic library for creating interactive user interfaces on UNIX systems
#

#banners
{
    #array: banner_shellGL
    #big 92 cols
    banner_shellGL_bg[0]=" ██████████╗ ████╗ ████╗██████████╗████╗    ████╗      ████████████████═╗ ████████╗        "
    banner_shellGL_bg[1]="████████████╗████║ ████║██████████║████║    ████║    ████████████████████╗████████║        "
    banner_shellGL_bg[2]="████════════╝████║ ████║████══════╝████║    ████║    ████████████████████║████████║        "   
    banner_shellGL_bg[3]="███████████  ██████████║██████████╗████║    ████║    ████████╔═══════════╝████████║        "
    banner_shellGL_bg[4]="╚███████████╗██████████║██████████║████║    ████║    ████████║ ██████████╗████████║        " 
    banner_shellGL_bg[5]=" ╚══════████║████╔═████║████══════╝████║    ████║    ████████║ ██████████║████████║        "
    banner_shellGL_bg[6]="████████████║████║ ████║██████████╗████████╗████████╗████████║ ██████████║████████║        "
    banner_shellGL_bg[7]="╚██████████╔╝████║ ████║██████████║████████║████████║████████║ ╚═████████║████████████████╗"
    banner_shellGL_bg[8]=" ╚═════════╝ ╚═══╝ ╚═══╝╚═════════╝╚═══════╝╚═══════╝████████████████████║████████████████║"
    banner_shellGL_bg[9]="████████████████████████████████████████████████████╗████████████████████║████████████████║"
    banner_shellGL_bg[10]="████████████████████████████████████████████████████║╚═████████████████╔═╝████████████████║"
    banner_shellGL_bg[11]="╚═══════════════════════════════════════════════════╝  ╚═══════════════╝  ╚═══════════════╝"
    
    #medium 46 cols
    banner_shellGL_md[0]="▐████ ██ ██ █████ ██   ██   ▄███████▄ ████    "
    banner_shellGL_md[1]="██    ██ ██ ██    ██   ██   █████████ ████    "
    banner_shellGL_md[2]="▐███▌ █████ █████ ██   ██   ████ ▄▄▄▄ ████    "
    banner_shellGL_md[3]="   ██ ██ ██ ██    ██   ██   ████ ████ ████    "
    banner_shellGL_md[4]="████▌ ██ ██ █████ ████ ████ ████▄▄███ ████    "
    banner_shellGL_md[5]="▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ █████████ ████████"
    banner_shellGL_md[6]="▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀"
    
    #small 29 cols
    banner_shellGL_sm[0]="█▀▀ █ █ █▀▀ █  █  ▄████▄ ██  "
    banner_shellGL_sm[1]="▀▀█ █▀█ █▀▀ █  █  ██ ▄▄▄ ██  "
    banner_shellGL_sm[2]="▀▀▀ ▀ ▀ ▀▀▀ ▀▀ ▀▀ ██▄▄██ ██▄▄"
    banner_shellGL_sm[3]="▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀  ▀▀▀▀"
}

# Key bindings (will be updated to be portable for all UNIX distros)
{
    key_esc=$'\033'
    key_space=$' '
    key_enter=$'\012'
    key_up="${key_esc}[A"
    key_down="${key_esc}[B"
    key_right="${key_esc}[C"
    key_left="${key_esc}[D"
}

#screen controls
{
    #clrEnd="${key_esc}[0J" #cursor to screen end >>
    #clrHome="${key_esc}[1J" #cursor to screen home <<
    clrLineEnd="${key_esc}[0K" #cursor to line end |>
    #clrLineHome="${key_esc}[1K" #cursor to line home <|
    #clrLine="${key_esc}[2K" #line ||
    curHome="${key_esc}[H"
    #curEnd="${key_esc}[F"

    curVis="${key_esc}[?25h" #cursor visible
    #curInv="${key_esc}[?25l" #cursor invisible
}

#Format declarations
#
#font
{
    reset_mode="${key_esc}[0m"
}

#color
{
    fg_black="${key_esc}[30m"
    fg_white="${key_esc}[37m"
    #fg_red="${key_esc}[31m"

    #bg_black="${key_esc}[40m"
    bg_white="${key_esc}[47m"
    bg_red="${key_esc}[41m"
}

# Screen controller
# --updates only parts of screen that have changed states
# --finds difference between array lastState and nextState
# --if element of lastState and nextState are different, nextState element is rendered
# --if #elements of lastState and nextState are different, applies appropriate nextstate rendering
# --case: #lastState greater than #nextState = clear lines
# --case: #lastState less than #nextState = add lines
# --states evaluation occurs everytime state variables are changed

function compareState () {
    #compare array size
    if [[ ${#lastState[@]} -eq ${#nextState[@]} ]]; then #lastState = nextState, no line change
        for i in "${!nextState[@]}"; do
            if [[ ${lastState[$i]} != "${nextState[$i]}"  ]]; then
                renderState+=("$(tput cup "$i" 0)${nextState[$i]}")
            fi
        done
    elif [[ ${#lastState} -lt ${#nextState} ]]; then #lastState < nextState, add lines
        for i in "${!nextState[@]}"; do
            if [[ $i -gt ${#lastState[@]} ]]; then #within lastState limit elements
                if [[ ${lastState[$i]} != "${nextState[$i]}"  ]]; then
                    renderState+=("$(tput cup "$i" 0)${nextState[$i]}")
                fi
            elif [[ ! $i -gt ${#lastState[@]} ]]; then #outside lastState limit
                renderState+=("$(tput cup "$i" 0)${nextState[$i]}")
            fi
        done
    elif [[ ${#lastState} -gt ${#nextState} ]]; then #lastState > nextState, reduce lines
        for i in "${!lastState[@]}"; do
            if [[ $i -gt ${#nextState[@]} ]]; then #within nextState limit elements
                if [[ ${lastState[$i]} != "${nextState[$i]}"  ]]; then
                    renderState+=("$(tput cup "$i" 0)${nextState[$i]}")
                fi
            elif [[ ! $i -gt ${#nextState[@]} ]]; then #outside nextState limit
                renderState+=("$(tput cup "$i" 0)$clrLineEnd")
            fi
        done
    fi
}

function pushState () {
    compareState
    for i in "${!renderState[@]}"; do
        printf "%-s" "${renderState[$i]}${reset_mode}"
    done
    printf "%s%s" "${reset_mode}" "${curHome}"
    unset renderState
    unset lastState
    lastState=("${nextState[@]}")
    unset nextState
}

function mapState () {
    local posY=$1 string=$2 
    nextState[$posY]=$string
}

# Input handler
function navControl () {
    while true; do
        read -srN1 key # 1 char (not delimiter), silent
        #catch multi-char special key sequences
        read -srN1 -t 0.0001 k1
        read -srN1 -t 0.0001 k2
        read -srN1 -t 0.0001 k3
        key+=$k1$k2$k3
        case "$key" in
            "$key_up") printf "up";;
            "$key_down") printf "down";;
            "$key_right") printf "right";;
            "$key_left") printf "left";;
            "$key_space") printf "space";;
            "$key_enter") printf "enter";;
            *) continue;;
        esac
        break
    done
}

function getBoxPos () {
    local boxWidth=$1 boxHeight=$2 alignment=$3
    if [[ $alignment = "centered" ]]; then
        marginTop=$((($(tput lines)-boxHeight)/2))
        marginRight=$((($(tput cols)-boxWidth)/2))
    fi
}

function fillSpace () {
    local limit=$1 i=0 tmpString
    until [[ i -gt limit ]]; do
        tmpString+=" "
        ((i++))
    done
    printf "%s" "${tmpString}"
    unset tmpString
}

# Yes/No Prompt
# String prompt
# Press any key to continue
# List generator
# Multi-option seelct
# Multi-option checklist

function getCursorCol () {
    IFS=';' read -srdR -p $'\033[6n' LINE COL
    printf "%s" "${COL#*[}"
}

function getCursorLine () {
    IFS=';'
    read -srdR -p $'\033[6n' LINE COL
    printf "%s" "${LINE#*[}"
}

function debugLog () {
    #Error Codes:
    #0: Undefined
    local debugString=$1 errCode=$2 tmpString formatString="${bg_red}${fg_white}"
    tmpString+="${formatString}"
    if [[ -n ${debugString} ]]; then
        if [[ -z ${errCode} ]]; then
            tmpString+=" ${BASH_SOURCE[1]} : ${BASH_LINENO[0]} > ${debugString}"
        elif [[ -n ${errCode} ]]; then
            tmpString+=" ${errCode} > ${debugString}"
        fi
    elif [[ -z ${debugString} ]]; then
        tmpString+="${BASH_SOURCE[1]} attempted to call ${FUNCNAME[1]} at line ${BASH_LINENO[0]}"
    fi
    if [[ $((${#tmpString}-${#formatString})) -gt 0 ]]; then
        if [[ $((${#tmpString}%$(tput cols))) -gt 0 ]]; then
            tput cup $(( $(tput lines)-(((${#tmpString}-${#formatString})/$(tput cols))+1)))
        elif [[ $(($(${#tmpString}-${#formatString})%$(tput cols))) -eq 0 ]]; then
            tput cup $(( ( $(${#tmpString}-${#formatString})/ $(tput cols) ) ))
        fi
        printf "%s" "${tmpString}"
        tput cup "$(tput lines)" "$(((${#tmpString}-${#formatString})%$(tput cols)))"

        #printf "%s%s" "${curDown}" "${curEnd}"
        if [[ ! $(getCursorCol) -gt $(tput cols) ]]; then
            printf "%s" "$(fillSpace $(($(tput cols)-$(getCursorCol))))"
        fi
        printf "%s%s" "${reset_mode}" "${curHome}"
    fi
    unset tmpString
}



#Format array structure:
#[0]: Format type; can be: "global", "line"
#[1]: color format; defined variable type, ignored if null ("")
#[2]: text format; defined variable type, ignored if null ("")

splash_shellGL_format[0]=global
splash_shellGL_format[1]="${bg_white}${fg_black}"

# Loading Screen
function splashScreen () {
    local -n alignment=$1 formatArr=$3 tmpString
    local bannerName=$2 bannerSize i=0
    if [[ $(tput cols) -gt 100 ]]; then
        bannerSize=_bg
    elif [[ $(tput cols) -gt 50 ]]; then
        bannerSize=_md
    elif [[ $(tput cols) -gt 30 ]]; then
        bannerSize=_sm
    fi
    bannerNameSize="$bannerName$bannerSize"
    getBoxPos ${#bannerNameSize[0]} ${#bannerNameSize[@]} centered
    until [[ ${i} -eq $(tput lines) ]]; do
        if [[ i -lt ${marginTop} ]]; then
            tmpString+="${formatArr[1]}$(fillSpace "$(tput cols)")"
        elif  [[ ! ${i} -lt ${marginTop} ]] && [[ ${i} -lt $((marginTop+${#bannerNameSize[@]})) ]]; then
            tmpString+="${formatArr[1]}"
            until [[ ! ${#tmpString} -lt $(tput cols) ]]; do
                if [[ ${#tmpString} -lt ${marginRight} ]]; then
                    tmpString+="$(fillSpace ${marginRight})"
                elif [[ ! ${#tmpString} -lt ${marginRight} ]] && [[ ${#tmpString} -lt $((marginRight+${#bannerNameSize[0]})) ]]; then
                    tmpString+="$(${bannerNameSize[$((i-marginRight))]})"
                elif [[ ! ${#tmpString} -lt $((marginRight+${#bannerNameSize[0]})) ]] && [[ ${#tmpString} -lt $(tput cols) ]]; then
                    tmpString+="$(fillSpace $(($(tput cols)-(marginRight+${#bannerNameSize[0]}))))"
                fi
            done
        elif [[ ! ${i} -lt $((marginTop+${#bannerNameSize[@]})) ]] && [[ ${i} -lt $(tput lines) ]]; then
            tmpString+="${formatArr[1]}$(fillSpace "$(tput cols)")"
        fi
        if [[ ${#tmpString} -eq $(tput cols) ]]; then
            mapState ${i} "${tmpString}"
            unset tmpString
        fi
        ((i++))
    done
    pushState
}



function cleanUp () {
    printf "%s%s" "${curVis}" "${reset_mode}"
    #tput cnrorm #set cursor to normal
    tput clear
    tput home
}

function initialize () {
    printf "cursor debugging mode"
    sleep 0.5
    tput clear
    tput home
    #printf "${curInv}"
    #tput civis #set cursor to invisible
}

function main () {
    debugLog "testing debugLog..."
    sleep 5
    #splashScreen "center" "banner_shellGL" "${splash_shellGL_format[@]}"
    #while true; do
    #    lastKey=$(navControl)
    #    printf "\nyou pressed: %s" "$lastKey"
    #done
    read -sr
}

trap cleanUp EXIT #bind EXIT event to cleanUp function
initialize
main
