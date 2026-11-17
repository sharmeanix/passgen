#!/bin/sh

usage() {
	echo "usage: passgen [-p path] [-w count] [-c max] [-n max]"
	exit 1;
}

rand() {

	# Use jot(1) if available

	if command -v jot >/dev/null 2>&1; then
		exec jot -r 1 $1 $2
	fi

	seed="$(od -An -N4 -tu4 /dev/urandom | tr -d " ")$$"
	awk -v seed=$seed -v min=$1 -v max=$2 'BEGIN {srand(seed);
	    print (int(min + rand() * (max - min + 1)))}'
}

wrdcount=5
capcount=2
numcount=2
smartc=1
smartn=1
path="/usr/local/share/dict/wordlist"

while getopts w:c:n:p: flag; do
	case "$flag" in
	"w")
		wrdcount="$OPTARG" ;;
	"c")
		capcount="$OPTARG"
		smartc=0 ;;
	"n")
		numcount="$OPTARG"
		smartn=0 ;;
	"p")
		path="$OPTARG" ;;
	"?")
		usage ;;
	esac
done

[ ! -f "$path" ] && usage
[ "$wrdcount" -lt 3 ] && usage

pass=$(sort -R "$path" 2>/dev/null | head -n "$wrdcount" |
	awk '{print $2}' | paste -s -d - -)

[ "$smartc" -eq 1 ] && capcount=$(("$wrdcount" / 2))
[ "$smartn" -eq 1 ] && numcount=$(("$wrdcount" / 2))

escval=$(("$wrdcount" + 1))

while [ "$capcount" -gt 0 ]; do 

	index="$(rand 1 $escval)"

	word=$(echo $pass | cut -d - -f $index)
	wordfirst=$(echo $word | cut -c1 | tr a-z A-Z)
	wordsecond=$(echo $word | cut -c2-)
	newword=${wordfirst}${wordsecond}

	[ $index -ne $escval ] && [ "$newword" != "$word" ] && \
	    pass=$(echo $pass | sed -e "s/-${word}-/-${newword}-/" \
	    -e "s/-${word}\$/-${newword}/" -e "s/^${word}-/${newword}-/")

	capcount=$(("$capcount" - 1))
done

while [ "$numcount" -gt 0 ]; do

	index="$(rand 1 $escval)"
	num="$(rand 0 9)"

	word=$(echo $pass | cut -d - -f $index)
	[ $index -ne $escval ] && [ ! -z $(echo $word | grep -v "[0-9]") ] \
	    && pass=$(echo $pass | sed -e "s/-${word}-/-${word}${num}-/" \
	    -e "s/^${word}-/${word}${num}-/" -e "s/-${word}\$/-${word}${num}/")

	numcount=$(("$numcount" - 1))
done

echo $pass
