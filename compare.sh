#!/bin/bash

ls -l
read -p "Enter the names of the files you want to compare, separated by spaces: " file_names
clear

compared_files=()

# check the lines of code of each file
for file_name in $file_names
do
    for file_name2 in $file_names
    do
        if [ $file_name != $file_name2 ]
        then
            comparison="$file_name and $file_name2"
            reverse_comparison="$file_name2 and $file_name"
            
            # check if the comparison has already been made
            if [[ ! " ${compared_files[@]} " =~ " ${comparison} " ]] && [[ ! " ${compared_files[@]} " =~ " ${reverse_comparison} " ]]
            then
                # compare the files
                diff $file_name $file_name2 > /dev/null
                if [ $? -eq 0 ]
                then
                    similarity="100.0000%"
                else
                    lines_of_code=`wc -l $file_name | awk '{print $1}'`
                    lines_of_code2=`wc -l $file_name2 | awk '{print $1}'`
                    same_lines_of_code=0
                    while read line
                    do
                        if [ "$line" != "{" ] && [ "$line" != "}" ] && [ "$line" != ":" ] && [ "$line" != ";" ] && [ "$line" != "[" ] && [ "$line" != "]" ]
                        then
                            grep -q "$line" $file_name2
                            if [ $? -eq 0 ]
                            then
                                same_lines_of_code=`expr $same_lines_of_code + 1`
                            fi
                        fi
                    done < $file_name
                    similarity=`echo "scale=4; $same_lines_of_code / $lines_of_code * 100" | bc`
                fi
                # print the similarity percentage for each file comparison
                echo "$comparison are $similarity% similar"
                compared_files+=($comparison)
            fi
        fi
    done
done
