#!/bin/bash
# shell script creating a plane full of randomly coloured capsule-shaped pills
# to be rendered using povray
# Author: m0°ntan

if [ -z $1 ]; then
FILENAME="pills"
else
FILENAME=$1
fi

POV="$FILENAME.pov"
IMAGE="$FILENAME.png"

if [ -z $2 ]; then
NUM=6
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

for i in {1..7};
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
RED[$i]=$(echo "scale=2; $((RANDOM % 1000))/8000+.875" | bc -l)
GRN[$i]=$(echo "scale=2; $((RANDOM % 1000))/4000+.25" | bc -l)
BLU[$i]=$(echo "scale=2; $((RANDOM % 1000))/4000+.25" | bc -l)
COL[$i]=""
done
CENX=$(echo "scale=1; $CENX/10" | bc -l)
CENZ=$(echo "scale=1; $CENZ/10" | bc -l)
echo $CENX, $CENZ

echo -e \/\/ plane of pills generated on $(date) > $POV
echo -e \#include \"colors.inc\" >> $POV
echo -e \#include \"stones.inc\" >> $POV
echo -e "\ncamera {\n\tlocation <$CAMPOSX, $CAMPOSY, $CAMPOSZ>\n\tlook_at <$CENX, 0, $CENZ>\n}" >> $POV
for LIGHTZ in {-75..75..150}; do
	for LIGHTX in {-75..75..150}; do
		echo -e "\nlight_source {\n\t<$LIGHTX, 75, $LIGHTZ>\n\tcolor Gray80\n\tfade_distance 11\n\tfade_power .1\n}" >> $POV
	done
done

echo -e "\nplane {\n\t<0, 1, 0>, -1\n\t texture { T_Stone28 scale 6 }\n}" >> $POV

for i in {1..7};
do
echo -e "\n\t// Pill #$i" >> $POV
echo -en "\nsphere {\n\t<${POSXC[i]}, 0, ${POSZC[i]}>, 1\n\tpigment { color rgb <${RED[i]}, ${GRN[i]}, ${BLU[i]}> }\n}" >> $POV
echo -en "\ncylinder {\n\t<${POSXC[i]}, 0, ${POSZC[i]}>, <${POSX[i]}, 0, ${POSZ[i]}>, 1\n\tpigment { color rgb <${RED[i]}, ${GRN[i]}, ${BLU[i]}> }\n}" >> $POV
echo -en "\ncylinder {\n\t<${POSX[i]}, 0, ${POSZ[i]}>, <${POSXW[i]}, 0, ${POSZW[i]}>, 1\n\tpigment { color White }\n}" >> $POV
echo -e "\nsphere {\n\t<${POSXW[i]}, 0, ${POSZW[i]}>, 1\n\tpigment { color White }\n}" >> $POV
done

povray +O$IMAGE $POV