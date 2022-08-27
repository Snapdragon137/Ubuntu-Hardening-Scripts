echo "Created by Jacob Strelnikov"
echo "For solving forensics problems"


# Checking If Root
if [[ $EUID -ne 0 ]]
then
  echo "This script must be run as root."
  exit
fi


echo "Updating packages and Repositories"

apt update -y
apt-get upgrade -y
clear
echo "Setting password policies. if something goes wrong, copy the contents of /etc/pam.d/common-password-backup  to /etc/pam.d/common-password"

# This creates a backup of the file in case anything goes wrong.
cp /etc/pam.d/common-password /etc/pam.d/common-password-backup

sed -i 's/minlen=[0-9]\+/minlen=14' /etc/pam.d/common-password
# Changes the minlen option to 14
sed -i 's/remember=[0-9]\+/remember=5' /etc/pam.d/common-password
# Changes the remember option to 5
sed -i 's/retry=[0-9]\+/retry=3' /etc/pam.d/common-password
# Changes the retry option to 3

clear

echo "removing unwanted packages"



while read package; do apt show "$package" 2>/dev/null | grep -qvz 'State:.*(virtual)' && echo "$package" >>packages-valid && echo -ne "\r\033[K$package"; done <packages.txt
sudo apt purge $(tr '\n' ' ' <packages-valid) -y

clear

echo "removing prohiited files"

find /home -regextype posix-extended -regex '.*.(midi|mid|mod|mp3|mp2|mpa|abs|mpega|au|snd|wav|aiff|aif|sid|flac|ogg|mpeg|mpg|mpe|dl|movie|movi|mv|iff|anim5|anim3|anim7|avi|vfw|avx|fli|flc|mov|qt|spl|swf|dcr|dir|dxr|rpm|rm|smi|ra|ram|rv|wmv|asf|asx|wma|wax|wmv|wmx|3gp|mov|mp4|flv|m4v|xlsx|pptx|docx|csv
tiff|tif|rs|iml|gif|jpeg|jpg|jpe|png|rgb|xwd|xpm|ppm|pbm|pgm|pcx|ico|svg|svgz|pot|xml|pl)$' -delete
clear

echo "enabling Firewall"
echo "checking if ufw is installed"
if ufw | grep -q 'ufw: command not found > /dev/null'; then
    echo "ufw is not installed"
    apt install ufw -y
    ufw enable > /dev/null
else
    echo "ufw is installed"
    ufw enable > /dev/null
fi


#Removed due to not working

# echo "Removing Unauthorised Users"

# #read users.txt and return each line as an array



# while read line; do array+="$line"; done < users.txt




# # get a list of the users on the system

# users=$(cut -d: -f1 < /etc/passwd)

# for user in "${array[@]}"; do
#   if ["$users" in "$user"]; then
#     echo "user $user found"
#   else
#     echo "user $user not found"
#     #delete the user
#     deluser $user
  
#   fi
# done
clear
echo "Checking maleware with ClamAV"

apt-get install clamav clamav-daemon -y
systemctl stop clamav-freshclam 
freshclam
systemctl start clamav-freshclam
systemctl enable clamav-freshclam
clamscan -r /home
clamscan --infected --remove --recursive /home
clamscan --infected --recursive --exclude-dir="^/sys" /
clear

echo "Updating operating system"

sudo apt install unattended-upgrades -y
systemctl status unattended-upgrades

echo "Changing password of user"

read -p "How many users passwords do you want to change?" num

