#!/bin/bash
#Μετρητής χρόνου
start=$SECONDS
#αν δεν υπάρχουν δυο ορίσματα διακόπτεται η εκτέλεση
if [ $# != 2 ];then
echo "Only works with 2 arguments"
exit
fi

cd /Users/MYUSERNAME

#λήψη στοιχείων από github
wget -r -np -l 1 -A zip https://github.com/$1/$2/tags
#Τα στοιχεία αυτόματα αποθηκεύονται σε φάκελο github.com κατά την λήψη
cd /Users/MYUSERNAME/github.com/$1/$2/archive
#αποσυμπίεση αρχείων και μετακίνηση στον φάκελο εργασίας
unzip -q "*.zip" -d /Users/MYUSERNAME/diplomatiki_files/$2
cd /Users/Users/MYUSERNAME/diplomatiki_files/$2

#διαγραφή των αρχείων που δεν είναι package.json και των κενών καταλόγων
find . -not -name "package.json"  -type f -delete
find . -type d -empty -delete

#μεταφορά όλων των αρχείων package.json στον κεντρικό κατάλογο μετά από μετονομασία
for f in *; do [[ -d "$f" ]] && {
dir=$f
echo $dir
cd $dir
s=1
find .  -name "package*.json"  -type f | while read f
do
newname="package$s.json"
mv -n "$f" "$newname"
s=$((s+1))
done
cd ..
}; done

#αφαίρεση ειδικών χαρακτήρων από το package.json
#η διαδικασία γίνεται με χρήση ενδιάμεσου αρχείου που στο τέλος διαγράφεται
find . -name "package*.json"  -type f  | while read f
do
touch $f.txt
sed -i .bak 's|[",{, ]||g' $f >>$f.txt
sed -i .bak '/^[[:space:]]*$/d' $f >> $f.txt
sed -i .bak 's/[[:blank:]]//g' $f >> $f.txt
sed -i .bak 's|[    ]||g'  $f >> $f.txt
sed -i .bak 's|[            ]||g'  $f >> $f.txt
sed -i .bak 's|[ ]||g'  $f >> $f.txt
sed -i .bak 's/\"/\\\"/g' $f >> $f.txt
sed -i .bak 's/[][]//g' $f >> $f.txt
awk '{$1=$1};1'  $f >> $f.txt
tr "\011" "*"< $f > $f.txt
tr -d "     " < $f > $f.txt
tr -d "[]" < $f > $f.txt
tr '\n' '\r' < $f > $f.txt

while IFS=$\n read -r line;do
echo "$line" >> $f
done< $f.txt
done
find . -name "*.bak" -type f -delete
find . -name "*.txt" -type f -delete
find . -type d -empty -delete

#δημιουργία csv
for f in *; do [[ -d "$f" ]] && {
cd $f
anasterzia="pack|"$f"|.csv"
touch $anasterzia
#για κάθε package*.json
find .  -name "package*.json"  -type f | while read packe
do
# η : είναι ο διαχωριστικός χαρακτήρας
#η πρώτη σειρά του αρχείου περιέχει το όνομα του πακέτου και το θέλουμε
a=$(sed -n 1p $packe | cut -d ":" -f2)
touch $packe.txt
#μας ενδιαφέρουν τα πεδία που αναφέρονται σε εξαρτήσεις
#πρώτα διαχωρίζουμε τα dev Dependencies
#χρήση ενδιάμεσου temp αρχείου
awk '/devDependencies/{flag=1; next;} /}/{flag=0} flag' $packe |tr ':' ','>> $packe.txt
while IFS=$\r read -r line2 ;do
echo "$a,$line2,devDependencies">>$anasterzia
done < $packe.txt
rm $packe.txt

touch $packe.txt
#διαχωρίζουμε τα Dependencies
#χρήση ενδιάμεσου temp αρχείου
awk '/dependencies/{flag=1; next;} /}/{flag=0} flag' $packe |tr ':' ','>> $packe.txt
while IFS=$\r read -r line3 ;do
echo "$a,$line3,dependencies">>$anasterzia
done < $packe.txt
rm $packe.txt
done

#μετακινούμε όλα τα csv στον αρχικό κατάλογο
find . -maxdepth 1 -name "*.csv" -exec mv {} .. \;
#διαγράφουμε όλα τα json
rm "*.json"
cd ..

};done

#δημιουργούμε 1 συνολικό csv για το έργο
touch final_package$1.csv
#software->the library or the external soft the project uses
echo "project,version,name,software,software_version,type_of_reuse" >>final_package$1.csv
find .  -name "pack*.csv"  -type f | while read pack
do
vers=$(echo $pack| cut -d "|" -f2)
while IFS=$\r read -r line1 ;do
echo "$1,$vers,$line1">>final_package$1.csv
done < $pack
done

#διαγράφουμε όλα τα υπόλοιπα csv και τους κενούς καταλόγους
find . -not -name "final*"  -type f -delete
find . -type d -empty -delete

#σταματάει η χρονομέτρηση
if (( $SECONDS > 3600 )) ; then
    let "hours=SECONDS/3600"
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)"
elif (( $SECONDS > 60 )) ; then
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $minutes minute(s) and $seconds second(s)"
else
    echo "Completed in $SECONDS seconds"
fi




