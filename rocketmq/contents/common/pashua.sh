
# Tries to find the Pashua executable in one of a few default search locations or in
# a custom path passed as optional argument. When it can be found, the filesystem
# path will be in $pashuapath, otherwise $pashuapath will be empty. The return value
# is 0 if it can be found, 1 otherwise.
#
# Argument 1: Path to a folder containing Pashua.app (optional)

dialog_general(){
  #!/bin/bash

  # Define what the dialog should be like
  # Take a look at Pashua's Readme file for more info on the syntax
  conf_prefix="
  # Set window title
  *.title = 参数输入（参数不能有空格）"

  conf_suffix="db.type = defaultbutton
  cb.type = cancelbutton
  "

  conf_content=""

  param=$*
  arr=($param)

  # default_param_arr=($default_params)
  count=1
  for var in ${arr[@]}
  do
      name=`echo $var|awk -F"_" '{print $1}'`
      default_value=`echo $var|awk -F"_" '{print $2}'`

      conf_content=$conf_content"
  		tf$count.type=textfield
  		tf$count.label=$name
  		tf$count.width=600
      tf$count.default=$default_value
  		"
  		count=$(($count+1))
  done

  conf=$conf_prefix""$conf_content""$conf_suffix

  if [ -d '/Volumes/Pashua/Pashua.app' ]
  then
  	# Looks like the Pashua disk image is mounted. Run from there.
  	customLocation='/Volumes/Pashua'
  else
  	# Search for Pashua in the standard locations
  	customLocation=''
  fi
  pashua_run "$conf" "$customLocation"
  index=1
  while [ ${index} -lt ${count} ]
  do
  	paramName="\$tf"$index
  	eval "echo ${paramName}"
  	let index+=1
  done
}

locate_pashua() {

    local bundlepath="Pashua.app/Contents/MacOS/Pashua"
    local mypath=`dirname "$0"`

    pashuapath=""

    if [ ! "$1" = "" ]
    then
        searchpaths[0]="$1/$bundlepath"
    fi
    searchpaths[1]="$mypath/Pashua"
    searchpaths[2]="$mypath/$bundlepath"
    searchpaths[3]="./$bundlepath"
    searchpaths[4]="/Applications/$bundlepath"
    searchpaths[5]="$HOME/Applications/$bundlepath"

    for searchpath in "${searchpaths[@]}"
    do
        if [ -f "$searchpath" -a -x "$searchpath" ]
        then
            pashuapath=$searchpath
            return 0
        fi
    done

    return 1
}

# Function for communicating with Pashua
#
# Argument 1: Configuration string
# Argument 2: Path to a folder containing Pashua.app (optional)
pashua_run() {

    # Write config file
    local pashua_configfile=`/usr/bin/mktemp "${TMPDIR:-/tmp}"/pashua_XXXXXXXXX`
    echo "$1" > "$pashua_configfile"

    locate_pashua "$2"

    if [ "" = "$pashuapath" ]
    then
        >&2 echo "Error: Pashua could not be found"
        exit 1
    fi

    # Get result
    local result=$("$pashuapath" "$pashua_configfile")

    # Remove config file
    rm "$pashua_configfile"

    oldIFS="$IFS"
    IFS=$'\n'

    # Parse result
    for line in $result
    do
        local name=$(echo $line | sed 's/^\([^=]*\)=.*$/\1/')
        local value=$(echo $line | sed 's/^[^=]*=\(.*\)$/\1/')
        eval $name='$value'
    done

    IFS="$oldIFS"
}
string_param_fitter(){
  inputParams=$*
  count=1
  for paramline in `echo $inputParams`
  do
    echo $stringInput | awk -F'\\$p' '{print $'$count'"'$paramline'"}'
    count=$(($count+1))
  done
  echo $stringInput | awk -F'\\$p' '{print $'$count'}'
}

inputParams=`dialog_general $*`
temp_result=`string_param_fitter $inputParams`
echo $temp_result
