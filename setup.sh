#!/bin/bash
echo "Enter the file name of your HTML page."
read INPUT
ls $INPUT
if [[ $? != 0 ]]; then
	exit 1
fi
echo "Enter the name of your header file"
read HEADER
mkdir $(grep Directory: $INPUT | head -1 | cut -d \> -f3 | cut -d \< -f1)
cp $INPUT $(grep Directory: $INPUT | head -1 | cut -d \> -f3 | cut -d \< -f1)
cd $(grep Directory: $INPUT | head -1 | cut -d \> -f3 | cut -d \< -f1)
ln -s ~/Betty/betty-doc.pl _betty-s
ln -s ~/Betty/betty-style.pl _betty-d
cp ../.gitignore .
cp ../_putchar.c .
#Create the files
touch $(grep File: $INPUT | cut -d \> -f3 | cut -d \< -f1)
find . -type f -name "*.c" -empty -exec cp ../template '{}' \;
#Create the header
grep Prototype: $INPUT | cut -d \> -f3 | cut -d \< -f1 >> $HEADER.h
find . -type f -name "*.c" -exec sed -i "s/dog/$HEADER/g" '{}' \;
I=0
while read c; do
	I=$(($I+1))	
	PROTO=$(echo $c | rev | cut -c 2- | rev)
	NAME=$(echo $c | cut -d '(' -f 1 | rev | cut -d ' ' -f1 | rev)
	sed -i "s/int main(void)/$PROTO/g" $(ls -1 | grep "[0-9]-" | sort -h | grep -n "" | grep "$I:" | cut -d : -f2)
	sed -i "s/main - /$NAME - /g" $(ls -1 | grep "[0-9]-" | sort -h | grep -n "" | grep "$I:" | cut -d : -f2)
done<$HEADER.h
echo "#define HEADER_H" | cat - $HEADER.h > $HEADER.h.tmp
echo "#ifndef HEADER_H" | cat - $HEADER.h.tmp > $HEADER.h
echo "#endif" >> $HEADER.h
rm $HEADER.h.tmp
#README.md
echo "#Holberton School - "$(grep Directory: $INPUT | head -1 | cut -d \> -f3 | cut -d \< -f1) > README.md
echo "Description" >> README.md
echo "## New commands / functions used:" >> README.md
echo "\`\`gcc\`\`" >> README.md
echo "## Helpful Links" >> README.md
echo -e "*\n" >> README.md
echo "## Description of Files" >> README.md
head -8 README.md > README.md.tmp
ls -1 | grep "[0-9]-" | sort -h | sed 's/^/<h6>/g;s/$/<\/h6>\n/g' >> README.md.tmp
mv README.md.tmp README.md
#MAINS
mkdir mains
cd mains/
mv ../$INPUT .
export TOTAL=$(grep -c "<pre><code>" $INPUT)
for ((i = 1; i <= $TOTAL; i++ ))
do
	ITER=$(($i*2))
	START=$( grep -m$ITER -n -e "<pre><code>" -e "</code></pre>" $INPUT | tail -2 | cut -d : -f 1 | grep -n "" | grep "[1,3,5,7,9]:" | cut -d : -f2 )
	END=$( grep -m$ITER -n -e "<pre><code>" -e "</code></pre>" $INPUT | tail -2 | cut -d : -f 1 | grep -n "" | grep -v "[1,3,5,7,9]:" | cut -d : -f2 )
	tail -n +$START $INPUT | head -n $(($END-$START)) | grep -v "@ubuntu" | sed 's/\&amp;/\&/g;s/&lt;/</g;s/&gt;/>/g;s/&quot;/"/g' | tac | sed '1,/}/d' | tac | sed '$s/$/\n}/' > main.$(($i-1)).c
done
mv $INPUT ../
cd ..
rm ../$INPUT
