#!/bin/bash

COLORS=( \
    "#6f6776" \
    "#9a9a97" \
    "#c5ccb8" \
    "#8b5580" \
    "#c38890" \
    "#a593a5" \
    "#666092" \
    "#9a4f50" \
    "#c28d75" \
    "#7ca1c0" \
    "#416aa3" \
    "#8d6268" \
    "#be955c" \
    "#68aca9" \
    "#387080" \
    "#6e6962" \
    "#93a167" \
    "#6eaa78" \
    "#557064" \
    "#9d9f7f" \
    "#7e9e99" \
    "#5d6872" \
)
LIST_FILE=whitelist.csv
OUT_FILE=assets.json
TEMPLATE_FILE=template.json

rm $OUT_FILE

i=0
n=${#COLORS[@]}
while IFS=, read -r ticker addr decimals precision id name
do
    color=${COLORS[$i]}

    file="${TEMPLATE_FILE}.tmp"
    cp "$TEMPLATE_FILE" "$file"

    sed -i "s/ADDR/${addr}/g" "$file"
    sed -i "s/TICKER/${ticker}/g" "$file"
    sed -i "s/DECIMALS/${decimals}/g" "$file"
    sed -i "s/PRECISION/${precision}/g" "$file"
    sed -i "s/ID/${id}/g" "$file"
    sed -i "s/NAME/${name}/g" "$file"
    sed -i "s/COLOR/${color}/g" "$file"

    cat "$file" >> "$OUT_FILE"

    i=$(( i + 1 ))
    if (( i >= n ))
    then
        i=0
    fi
done < $LIST_FILE
