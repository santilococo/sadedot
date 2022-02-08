 source scripts/common.sh
 
 displayDialogBox --yesno "\nWould you like to set up gitconfig?" || return
 displayDialogBox --msgbox "\nNow, I will ask you for data to set up gitconfig personal account."
 gitPersonalName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
 gitPersonalMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
     displayDialogBox --yesno "$msg" && break
     gitPersonalName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
     gitPersonalMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
 displayDialogBox --yesno "\nWould you like to set up a work account?"
 gitWorkPath=$(displayDialogBox --inputbox "$msg" VALUES 3>&1 1>&2 2>&3)
     gitWorkPath=$(displayDialogBox --inputbox "$msg" VALUES 3>&1 1>&2 2>&3)
 gitWorkName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
 gitWorkMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
     displayDialogBox --yesno "$msg" && break
     gitWorkName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
     gitWorkMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
 displayDialogBox --title "sadedot" --yesno "$msg" || return
 displayDialogBox --infobox "\nUpdating sadedot submodule."
 displayDialogBox --title "sadedot" --msgbox "\nAll done! Enjoy..."
displayDialogBox() {
    displayDialogBox --msgbox "$1" VALUES
displayDialogBox --infobox "\nUpdating sadedot submodule." VALUES
           selectedOption=$(displayDialogBox --menu "$msg" VALUES 0 "${options[@]}" 3>&1 1>&2 2>&3)
       displayDialogBox --yesno "$msg" || return
   password=$(displayDialogBox --passwordbox "\nEnter your password." VALUES 3>&1 1>&2 2>&3)
