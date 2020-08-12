#!/usr/bin/env bash
VERSION="v1.0"
LINES=$(tput lines)
COLUMNS=$(tput cols)

#Global Variables
PATTERN="sp0"

#need to get output from lsblk -pld -o NAME,SIZE -e7
#readarray -t ARR < <(lsblk -pld -o NAME,SIZE -e7 | grep "sd*")
#Need a way to read an array dynamically into a whiptail menu
#Okay so the issue we're having with simply passing the array to whiptail
#is: tags. Whiptail menu is interpreting sda + sdb as an item/tag combo
#Raw grep output is /dev/sda xxG /dev/sdb xxG /dev/sdc xxG
#Need a way to delimit this output

#progress bar for dd can be created with:
#https://www.cyberciti.biz/faq/linux-unix-dd-command-show-progress-while-coping/
#pv -n /dev/urandom | dd of=$TARGET_DISK bs=$BS | whiptail \
#--title "Wiping "$TARGET_DISK --gauge "dd: Dunkin' hDds since 2020" 6 50 0
#display different phase messages
#https://stackoverflow.com/questions/40989842/how-to-display-different-messages-on-whiptail-progress-bar-along-with-progress-b/40995466#40995466

function wipe_menu {
  DRIVE_ARRAY=($(lsblk -pld -o NAME,SIZE -e7 | grep "sd*"))
  DRIVE=$(whiptail --title "Wiper "$VERSION --menu "Choose a drive to wipe:" \
  $LINES $COLUMNS $((LINES - 8)) "${ARR[@]/#/     }" 3>&1 1>&2 2>&1)
  #TODO: Might be able to merge the preceding whitespace trim into above?

  #Parameter expansion here removes the preceding whitespaces added in the ui
  wipe "${$DRIVE// /}"
}

function wipe {
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

    for i in "${$OP[@]}"
    do
      pv -n /dev/zero | dd of=$1 | whiptail --title "Wiping "$1 \
      --gauge "dd: Dunkin' Drives since 2020"'\n'$i 6 50 0
    done

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
