#!/usr/bin/env bash
VERSION="v1.0"
LINES=$(tput lines)
COLUMNS=$(tput cols)
SAFETY="-n"

#Global Variables
PATTERN="sp0"
#Psuedo K/V pairings because b3 doesn't have associative arrays :)
zeroes="/dev/zero"
random="/dev/urandom"

#need to get output from lsblk -pld -o NAME,SIZE -e7
#readarray -t ARR < <(lsblk -pld -o NAME,SIZE -e7 | grep "sd*")
#Raw grep output is /dev/sda xxG /dev/sdb xxG /dev/sdc xxG

#progress bar for dd can be created with:
#https://www.cyberciti.biz/faq/linux-unix-dd-command-show-progress-while-coping/
#pv -n /dev/urandom | dd of=$TARGET_DISK bs=$BS | whiptail \
#--title "Wiping "$TARGET_DISK --gauge "dd: Dunkin' hDds since 2020" 6 50 0
#display different phase messages
#https://stackoverflow.com/questions/40989842/how-to-display-different-messages-on-whiptail-progress-bar-along-with-progress-b/40995466#40995466

function wipe_menu {
  DRIVE_ARRAY=($(lsblk -pld -o NAME,SIZE -e7 | grep "sd*"))
  DRIVE=$(whiptail --title "Wiper "$VERSION --menu "Choose a drive to wipe:" \
  $LINES $COLUMNS $(expr $LINES - 8) "${DRIVE_ARRAY[@]/#/     }" 3>&1 1>&2 2>&1)
  #Parameter expansion here adds padding to make ui more friendly

  #Parameter expansion here removes the preceding whitespaces added in the ui
  wipe "${DRIVE:4}"
}

function wipe {
 case $PATTERN in
    "sp0")
      OP="-p fillzero"
    ;;
    "spff")
      OP="-p fillff"
    ;;
    "dod")
      OP="-p dod"
    ;;
    "nnsa")
      OP="-p nnsa"
    ;;
    "bsi")
      OP="-p bsi"
    ;;
  esac
  
  scrub $SAFETY $OP $0 && whiptail --msgbox $0" scrubbed" $LINES $COLUMNS && main_menu
}

#TODO: Implement homebrew wiping with dd
function experimental_wipe {
  #TODO: Add verification functionality
  #Match last word of OP to a table with key/val between string and fp?
  case $PATTERN in
    "sp0")
      OP="Writing zeroes"
    ;;
    "spff")
      OP="Writing 0xff"
    ;;
    "dod")
      OP=("Writing random" "Writing zeroes" "Writing 0xff")
    ;;
    "nnsa")
      OP=("Writing random" "Writing random" "Writing zeroes")
    ;;
    "bsi")
      OP=("Writing 0xff" "Writing 0xfe" "Writing 0xfd" "Writing 0xfb" \
      "Writing 0xf7" "Writing 0xef" "Writing 0xdf" "Writing 0xbf" \
      "Writing 0x7f")
    ;;
  esac

  for i in "${$OP[@]}"
    do
      #Read will chunk the OP string into two, with the second substring
      #being what we want, namely what is being written. disregard is disregarded
      read disregard WRITEFROM <<< "${OP[$i]}"#does this work?
      pv -n $WRITEFROM | dd of=$1 | whiptail --title "Wiping "$1 \
      --gauge "dd: Dunkin' Drives since 2020"'\n'$i 6 50 0
    done

    #TODO: Verify pass here

    whiptail --title "Wiper "$VERSION --msgbox "Erasure of "$1 \
    " complete! Hit okay to return to the main menu" $LINES $(($COLUMNS/4)) \
    && main_menu
}

function setting_menu {
  PATTERN=$(whiptail --title "Settings" --radiolist "Choose a wipe pattern (press space to select):" \
  $LINES $((COLUMNS-4)) $(($LINES - 8)) \
  "sp0" "2-pass 0/verify " OFF \
  "spff" "2-pass ff/verify " OFF \
  "dod" "[RECOMMENDED] 4-pass r/0/ff/verify " ON \
  "nnsa" "4-pass r/r/0/verify " OFF \
  "bsi" "9-pass ff/fe/fd/fb/f7/ef/df/bf/7f + verify " OFF \
  3>&1 1>&2 2>&3) && main_menu
}

function main_menu {
  TITLE="wiper "$VERSION

  MENOPT=$(whiptail --title "$TITLE" --menu "Choose an option:" \
  $LINES $COLUMNS $(($LINES - 8)) \
  "Wipe" "Select drive to wipe using specified pattern" \
  "Settings" "Modify wipe patterns" \
  "Exit" "Exit wiper" 3>&1 1>&2 2>&3)

  case $MENOPT in
    "Wipe")
      wipe_menu
      echo "Wiped"
    ;;
    "Settings")
      setting_menu
    ;;
    "Exit")
      echo "Wiper exited successfully! Thank you for using!"
  esac
}

main_menu
