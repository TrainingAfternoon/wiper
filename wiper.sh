#!/usr/bin/env bash
VERSION="v1.0"
LINES=$(tput lines)
COLUMNS=$(tput cols)
#need to get output from lsblk -pld -o NAME,SIZE -e7
#progress bar for dd can be created with:
#https://www.cyberciti.biz/faq/linux-unix-dd-command-show-progress-while-coping/

function main_menu {
  TITLE="wiper "$VERSION

  MENOPT=$(whiptail --title "$TITLE" --menu "Choose an option:" \
  $LINES $COLUMNS $(($LINES - 8)) \
  "Wipe" "Select drive to wipe using specified pattern" \
  "Settings" "Modify wipe patterns" 3>&1 1>&2 2>&3)

  case $MENOPT in
    "Wipe")
      echo "Wiped"
    ;;
    "Settings")
      echo "Set"
    ;;
  esac
}

main_menu
