inputstring="$*"
inputstring=${inputstring//' '/blank_space}
let index=0
inputstring_length=${#inputstring}
let param_part_start=-1
output_string=""
param_string=""
while (( index <= 100 ))
do

  the_char=${inputstring: index: 1}
  ((index++))
  if [[ "@" != $the_char ]] && [[ $param_part_start = -1 ]]
  then
    output_string=$output_string$the_char
  fi

  if [[ "@" = $the_char ]] && [[ $param_part_start = -1 ]]
  then
    param_part_start=$index
    continue
  fi

  if [[ "@" = $the_char ]] && [[ $param_part_start != -1 ]]
  then
    the_length=$[index - param_part_start - 1]
    start=$param_part_start
    the_char=${inputstring: start: the_length}
    param_string=$param_string" "$the_char
    param_part_start=-1
    output_string=$output_string"@"
    continue
  fi

done

params_output=`sh ./pashua.sh $param_string`
params_result_arr=($params_output)

for param in ${params_result_arr[@]}
do
    output_string=${output_string/@/$param}
done

output_string=${output_string//blank_space/' '}
echo $output_string
