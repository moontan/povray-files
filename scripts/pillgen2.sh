#!/bin/bash
# shell script creating a plane full of randomly coloured capsule-shaped pills
# to be rendered using povray. pills in this version are more likely to have a bright colour.
# Author: m0°ntan

if [ -z $1 ]; then
FILENAME="pills"
else
FILENAME=$1
fi

POV="$FILENAME.pov"
IMAGE="$FILENAME.png"

if [ -z $2 ]; then
NUM=$((2+(RANDOM % 14)))
else
NUM=$2
fi

if [ -z $3 ]; then
CAMPOSX=$((-30 + (RANDOM % 60)))
else
CAMPOSX=$3
fi

if [ -z $5 ]; then
CAMPOSZ=$((-30+(RANDOM % 60)))
else
CAMPOSZ=$5
fi

if [ -z $4 ]; then
CAMPOSY=$((10 + (RANDOM % 30)))
else
CAMPOSY=$4
fi

for i in $(eval echo {1..$NUM});
do
POSX[$i]=$((-18 + (RANDOM % 36)))
POSZ[$i]=$((-16 + (RANDOM % 66)))
ROTA[$i]=$((RANDOM % 359))
POSXC[$i]=$(echo "scale=6; ${POSX[i]}-2*c(${ROTA[i]})" | bc -l)
POSZC[$i]=$(echo "scale=6; ${POSZ[i]}-2*s(${ROTA[i]})" | bc -l)
POSXW[$i]=$(echo "scale=6; ${POSX[i]}+2*c(${ROTA[i]})" | bc -l)
POSZW[$i]=$(echo "scale=6; ${POSZ[i]}+2*s(${ROTA[i]})" | bc -l)
CENX=$((CENX + POSX[i]))
CENZ=$((CENZ + POSZ[i]))
let "REDBASE[$i] = $((RANDOM % 100)) - 50"
case ${REDBASE[i]} in
	0) 	RED[$i]=1
		;;
	*) 	RED[$i]=$(echo "scale=2; (-(2*sqrt(${REDBASE[i]}^2)+.5*${REDBASE[i]}/sqrt(${REDBASE[i]}^2)+.5)+101)/100" | bc -l)
		;;
	esac
let "GRNBASE[$i] = $((RANDOM % 100)) - 50"
case ${GRNBASE[i]} in
	0) 	GRN[$i]=1
		;;
	*) 	GRN[$i]=$(echo "scale=2; (-(2*sqrt(${GRNBASE[i]}^2)+.5*${GRNBASE[i]}/sqrt(${GRNBASE[i]}^2)+.5)+101)/100" | bc -l)
		;;
	esac
let "BLUBASE[$i] = $((RANDOM % 100)) - 50"
case ${BLUBASE[i]} in
	0) 	BLU[$i]=1
		;;
	*) 	BLU[$i]=$(echo "scale=2; (-(2*sqrt(${BLUBASE[i]}^2)+.5*${BLUBASE[i]}/sqrt(${BLUBASE[i]}^2)+.5)+101)/100" | bc -l)
		;;
	esac
echo $i: R=${REDBASE[i]}=${RED[i]}, G=${GRNBASE[i]}=${GRN[i]}, B=${BLUBASE[i]}=${BLU[i]}
done
CENX=$(echo "scale=1; $CENX/$NUM" | bc -l)
CENZ=$(echo "scale=1; $CENZ/$NUM" | bc -l)
echo $CENX, $CENZ

echo -e \/\/ plane of pills generated on $(date) > $POV
echo -e \#include \"colors.inc\" >> $POV
echo -e \#include \"stones.inc\" >> $POV
echo -e \#include \"textures.inc\" >> $POV
echo -e \#include \"glass.inc\" >> $POV
echo -e "\ncamera {\n\tlocation <$CAMPOSX, $CAMPOSY, $CAMPOSZ>\n\tlook_at <$CENX, 0, $CENZ>\n}" >> $POV
for LIGHTZ in {-75..75..150}; do
	for LIGHTX in {-75..75..150}; do
		echo -e "\nlight_source {\n\t<$LIGHTX, 75, $LIGHTZ>\n\tcolor Gray80\n\tfade_distance 11\n\tfade_power .1\n}" >> $POV
	done
done

echo -e "\nplane {\n\t<0, 1, 0>, -1.5\n\ttexture { DMFWood3 scale 6 }\n}" >> $POV
echo -e "\nplane {\n\t<0, 1, 0>, -1\n\ttexture { T_Glass3 scale 6 }\n\tfinish { Shiny }\n}" >> $POV

for i in $(eval echo {1..$NUM});
do
echo -e "\n\t// Pill #$i" >> $POV
echo -en "\nmerge {\n" >> $POV
echo -en "\n\tsphere {\n\t\t<${POSXC[i]}, 0, ${POSZC[i]}>, 1\n\t\tpigment { color rgb <${RED[i]}, ${GRN[i]}, ${BLU[i]}, .45> }\n}" >> $POV
echo -en "\n\tcylinder {\n\t\t<${POSXC[i]}, 0, ${POSZC[i]}>, <${POSX[i]}, 0, ${POSZ[i]}>, 1\n\t\tpigment { color rgb <${RED[i]}, ${GRN[i]}, ${BLU[i]}, .45> }\n\t}\n" >> $POV
echo -en "\n\t}" >> $POV
echo -en "\nmerge {\n" >> $POV
echo -en "\ncylinder {\n\t<${POSX[i]}, 0, ${POSZ[i]}>, <${POSXW[i]}, 0, ${POSZW[i]}>, 1\n\tpigment { color White }\n}" >> $POV
echo -en "\nsphere {\n\t<${POSXW[i]}, 0, ${POSZW[i]}>, 1\n\tpigment { color White }\n}" >> $POV
echo -e "\n\t}\n" >> $POV
done

povray +O$IMAGE +H480 +W640 $POV