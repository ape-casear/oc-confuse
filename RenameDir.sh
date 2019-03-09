#!/bin/bash

####### 参数解析
echo "参数>>${@}"
while getopts :i:o: opt
do
	case "$opt" in
		i) to_process_file_dir="$(pwd)/$OPTARG"
			echo "Found the -i option, with parameter value $OPTARG"
			;;
		o) pbxproj_dir="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done

############## 配置

# 需处理文件目录
# mark: TODO
# to_process_file_dir="$(pwd)"

# 暂时保存文件夹名的文件
funDir="$(pwd)/configures/RenameDir.cfg"

# pbxproj_dir="$(pwd)/Sup_SDK_ket/Sup_SDK_ket.xcodeproj"
# 导入工具脚本
. ./FileUtil.sh

# 检测 property_name_replace_dir
checkDirCore $to_process_file_dir "指定类文件搜索目录不存在"
to_process_file_dir=${CheckInputDestDirRecursiveReturnValue}

# 原工程名
originProjectName=`cat originProjectName.txt`
# 存储文件夹的路径
function checkInputDestDir {
	
	local currentPath=$1
	for path in $(ls $currentPath); do
        # echo "${currentPath}/$path"
        local localpath="${currentPath}/$path"
        if [[ -d $localpath ]];then
			if [[ $(expr ${path} : '.*configures') -gt 0 ]];then
				echo '不处理configures'
			else
				echo "found a dir $localpath"
				checkInputDestDir $localpath
				echo $localpath >> $funDir
			fi
        fi
	done
}

# 重命名
function ReNameDir {
	IFS_OLD=$IFS
	IFS=$'\n'
	for line in $(cat ${funDir} | sed 's/^[ \t]*//g')
	do
		if [[ ! $(expr "$line" : '^#.*') -gt 0 ]];then
			echo "处理文件"$line
			local basePath=$(echo ${line} | sed -r -n 's/(.*)\/.*/\1/p')
			local originName=$(echo ${line} | sed -r -n 's/.*\/(.*)/\1/p')
			# 修改工程文件
			local newName=Mose_$(sed -n "$(($RANDOM*2))p" ./words)_$(sed -n "$(($RANDOM*2))p" ./words)
			if [[ $(expr $originName : $originProjectName) -gt 0 ]]
			then
				newName=$(cat projectName.txt)
				if [[ -n $(echo ${originName} | sed -n '/\.xcodeproj/p') ]]
				then
					newName=$(echo $originName | sed -r -n 's/.*(\.xcodeproj)/'"$newName"'\1/p')
				elif [[ -n $(echo ${originName} | sed -n '/bundle/p') ]]
				then
					newName=$(echo $originName | sed -r -n 's/.*(\.bundle)/'"$newName"'\1/p')
				fi
			fi
			sed -i '{
				s/'"${originName}"'/'"${newName}"'/g
			}' `grep ${originName} -rl ${pbxproj_dir}`
			# 改文件名
			mv $basePath/$originName $basePath/$newName
		fi
		
	done
	IFS=${IFS_OLD}
}
echo "# RenameDirCfg" > $funDir
checkInputDestDir $to_process_file_dir

ReNameDir
