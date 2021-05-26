#!/bin/zsh

### NOTE: This is a /bin/zsh to handle for loops better

items=(1, 2, 3, 4, 5 6 7 8 9 10 11 12)
counter=1

for item_a item_b in ${items[@]}
do
#    echo $item_a $item_b
    echo $counter: $item_a
    echo $[ $counter+1 ]: $item_b
    counter=$[ $counter+2 ]
    if [ $counter -gt 8 ]; then
        break
    fi

done