#!/bin/bash

echo "Script By VaiS" 

df -Th >> output.txt

rows=$(awk 'END {print NR}' output.txt)
cols=$(awk 'NR == 2 {print NF}' output.txt)

touch Report.html

{
echo "<html>"
echo "<head>"
echo "<style type=\"text/css\">"
echo "table{background-color:#DCDCDC}"
echo "thead {color:#708090}"
echo "tbody {color:#191970}"
echo "</style>"
echo "</head>"
echo "<body>"
}>> Report.html 


#looping through each rows and column to fill html table
{
echo "<table>"
for (( row=1; row<=rows; row++ )); do
        echo "<tr>"
        for (( col=1; col<=cols; col++ )); do
            value=$(awk -v r="$row" -v c="$col" 'NR == r {print $c}' output.txt)
            echo "<td>$value</td>"
        done
        echo "</tr>"
    done
echo "/table"
}>>Report.html

{
echo "</body>"
echo "</html>"
}>>Report.html

rm output.txt

echo "Report file generated named Report.html"
