#!/bin/bash


####### 参数解析
echo "参数>>${@}"
while getopts :i: opt
do
	case "$opt" in
		i) code_file_dir="$(pwd)/$OPTARG"
			echo "Found the -i option, with parameter value $OPTARG"
			;;
        o) static_file_dir="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done
# 静态文件目录
# static_file_dir="$(pwd)/Sup_SDK_ket.bundle"

# 修改对应代码目录
# code_file_dir="$(pwd)/Sup_SDK_ket"

# 记录修改的文件名
record_file="$(pwd)/configures/renameStaticFile.cfg"

# 导入工具脚本
. ./FileUtil.sh

# 检测 static_file_dir
checkDirCore $static_file_dir "指定静态文件目录不存在"
static_file_dir=${CheckInputDestDirRecursiveReturnValue}
# 检测 code_file_dir
checkDirCore $code_file_dir "指定对应代码目录不存在"
code_file_dir=${CheckInputDestDirRecursiveReturnValue}


# 递归处理
function renameStaticFileRecursively {
	
	local currentPath=$1
    # 处理目录下所有文件
	for path in $(ls $currentPath); do
        # echo "${currentPath}/$path"
        # 完整路径
        local localpath="${currentPath}/$path"
        # 如果是普通文件就处理
        if [[ -f $localpath ]];then
            # 不处理Root文件
            echo "found a file $localpath"
            if [[ $path =~ 'Root' ]]
            then 
                echo 'this is root'
            else
                echo $localpath >> $record_file
                local basePath=$(echo ${localpath} | sed -r -n 's/(.*)\/.*/\1/p')
                local originFullName=$(echo ${localpath} | sed -r -n 's/.*\/(.*)/\1/p')
                local ext=$(echo $originFullName |  sed -r -n 's/.*\.(.*)/\1/p')
                local originName=$(echo $originFullName |  sed -r -n 's/(.*)\..*/\1/p')
                # 修改文件文件
                local newName=file_$(sed -n "$(($RANDOM))p" ./words)_$(sed -n "$(($RANDOM))p" ./words)
                mv $basePath/$originFullName $basePath/$newName.$ext
		# echo "originName is "$originName
		# echo $(grep $originName -rl $code_file_dir)
                sed -i '{
                    s/\"'"${originName}"'\"/\"'"${newName}"'\"/g
                }' `grep "${originName}" -rl ${code_file_dir}`
            fi
        # 如果是文件夹就递归
        elif [[ -d $localpath ]]
        then
            renameStaticFileRecursively $localpath
        fi

	done
}
# run
echo '# renameStaticFile' >  $record_file
renameStaticFileRecursively $static_file_dir

