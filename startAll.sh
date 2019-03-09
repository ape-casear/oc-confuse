#!/bin/bash

####### 参数解析
echo "参数>>${@}"
while getopts :i:o:p:s:j:d: opt
do
	case "$opt" in
		i) projectDir="$(pwd)/$OPTARG"
			echo "Found the -i option, with parameter value $OPTARG"
			;;
		o) pbxproj_dir="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		p) project_name="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		s) staticDir="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		j) junkDIr="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		d) addDir="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done


./RenameClasses.sh  -i $projectDir -o $pbxproj_dir -p $project_name

./RenameFunction.sh  -i $projectDir

./addFunctions.sh  -i $addDir

./RenameClasses.sh  -i $addDir -o $junkDIr

./RenameStatic.sh  -i $projectDir -o $staticDir

./RenameDir.sh  -i  -o $pbxproj_dir