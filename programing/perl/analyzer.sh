#!/usr/bin/bash
##
# Color  Variables
##
green='\e[32m'
blue='\e[34m'
clear='\e[0m'
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

fname=$(find $HOME/Documents/programing/lua -not -path '*/\.'| grep '.lua$' | fzf)
menu(){
echo -ne "
Lua Code Analyzer (file: ${fname} )

$(ColorGreen '1)') Variable Explorer
$(ColorGreen '2)') Function Explorer
$(ColorGreen '3)') Table Explorer
$(ColorGreen '4)') File Load
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
  read a
  case $a in
    1) ./ve $fname ; menu ;;
    2) ./fe $fname ; menu ;;
    3) ./te $fname ; menu ;;
    4) fname=$(find $HOME/Documents/programing/lua -not -path '*/\.lua'| grep '.lua$' | fzf) ; menu ;;
  0) exit 0 ;;
  *) echo -e $red"Wrong option."$clear; menu;;
      esac
}

# Call the menu function
menu
