#!/usr/bin/env bash
VERSION="v1.0"
LINES=$(tput lines)
COLUMNS=$(tput cols)

#Global Variables
PATTERN="sp0"

#need to get output from lsblk -pld -o NAME,SIZE -e7
#DUMP=$(lsblk -pld -o NAME,SIZE -e7 | grep "sd*") works for variable-ifying

#progress bar for dd can be created with:
#https://www.cyberciti.biz/faq/linux-unix-dd-command-show-progress-while-coping/
#pv -n /dev/urandom | dd of=$TARGET_DISK bs=$BS | whiptail \
#--title "Wiping "$TARGET_DISK --gauge "dd: Dunkin' hDds" 6 50 0
#display different phase messages
#https://stackoverflow.com/questions/40989842/how-to-display-different-messages-on-whiptail-progress-bar-along-with-progress-b/40995466#40995466

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
