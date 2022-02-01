source sadedot/scripts/common.sh
setDialogBox "dialog"
            msg="\nFile already exists: $(basename "$1"), what would you like to do?"
            options=(1 "Skip" 2 "Skip ALL" 3 "Overwrite" 4 "Overwrite all" 5 "Backup" 6 "Backup all")
            selectedOption=$(displayDialogBox --menu "$msg" VALUES 0 "${options[@]}" 3>&1 1>&2 2>&3)