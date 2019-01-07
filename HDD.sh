#_!/bin/bash
echo "++++ Cloud disk creation script script version 0.2 ++++"
echo ____ Lets create a new disk____
echo
echo See what disk is newly added and unassigned to a lv
# Review avalible disks 
fdisk -l | grep dev
# Prompt for an avalible disk path
read -p 'What is the new disk?:(/dev/sdx) ' nwdsk 
# Ask to extend disk already in place
read -r -p "Do you need to extend a volume group? [y/n]" response
  response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
# input exisiting volume group name
 read -p 'What is the exisiting volume group name: ' voldsk
#Add volume group name and disk path to the vgextend cmd ex vgextend vg01 /dev/sdc
vgextend $voldsk $nwdsk
# Verify the disks
vgs
df -h
# prompt  for the lv full path name 
read -p 'What is the lv full path name: (ex /dev/mapper/app) ' lvpname
# prompt  for the size of the disk 
read -p 'How large is the drive (ex For 10 type 9.9): ' lvnum
# Extend the disk with lvextend ex lvextend -r -L+10G /dev/mapper/app
lvextend -r -L +"$lvnum"G $lvpname
# verify the disk was created 
df -h $lvpname
exit 1
 fi
# Prompt for the new volume group name 
read -p 'What is the new volume group name:(ex please follow the next number in sequence vg01, vg02…  vgXX) ' voldsk
# Create the new volume vgcreate vg01 /dev/sdc
vgcreate $voldsk $nwdsk
# Verify the new volumes creation 
vgs
# prompt for new lv name
read -p 'What is the lv name: (ex app) ' lvname
# prompt for new LogVol name
read -p 'What is the LogVol name: (ex VG01 = LogVol01) ' logvolname
# Prompt for the size of the new disk
read -p 'How large is the drive (ex "for 10 add 9.9"): ' num
# Show the provided information 
echo "$num"G -n "$logvolname"_"$lvname" $voldsk
# Create the new disk 
lvcreate -L "$num"G -n "$logvolname"_"$lvname" $voldsk
# Prompt if disk is xfs 
read -r -p "is the file system xfs?[y/n]" response
  response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
# If disk is xfs run  the below cmd to make the file system xfs
mkfs.xfs /dev/"$voldsk"/"$logvolname"_"$lvname"
 else
# If it is not run the below command  to make the file system ext4
mke2fs -t ext4 /dev/"$voldsk"/"$logvolname"_"$lvname"
fi
# prompt for file system name  
read -p 'What is the filesystem name? (ex /var): ' fsname 
# Show the provided information 
echo  " "/"dev"/mapper/"$voldsk"-"$logvolname"_"$lvname" $fsname                   
# Verify the above information is correct 
read -r -p "Is the above correct? [Y/n]" response
   response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
# Copy the results of line 58 to the /etc/fstab file
 echo  " "/"dev"/"$voldsk""/""$logvolname"_"$lvname" $fsname                 xfs     defaults        0 0 >> /etc/fstab
# Make the file sytem name directory 
mkdir $fsname
# Mount the newly added information on line 64 from /etc/fstab as a disk 
mount -a 
# Verify  that the changes properly took effect 
df -h
echo
fi
# Prompt to add more disk 
read -r -p 'Do you need to add another disk? [y/n]' response
  response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
# Run disk add script again 
./HDDaddtest.0.2.sh
fi

