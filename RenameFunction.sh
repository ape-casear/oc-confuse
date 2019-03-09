#!/bin/bash
# 方法重命名脚本

####### 参数解析
echo "参数>>${@}"
while getopts :i: opt
do
	case "$opt" in
		i) function_name_replace_dir="$(pwd)/$OPTARG"
			echo "Found the -i option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done
####### 配置
# classes类目录
# function_name_replace_dir="$(pwd)/Sup_SDK_ket"

# 配置文件
cfg_file="$(pwd)/configures/RenameFunctions.cfg"

# 方法黑名单配置文件
custom_blacklist_cfg_file="$(pwd)/configures/DefaultFuntionsBlackListConfig.cfg"

####### 配置检查处理

# 导入工具脚本
. ./FileUtil.sh
. ./EnvCheckUtil.sh
. ./StringUtil.sh

# 检测或者创建配置文件
checkOrCreateFile $cfg_file

# 检测 function_name_replace_dir
checkDirCore $function_name_replace_dir "指定的目录不存在"
function_name_replace_dir=${CheckInputDestDirRecursiveReturnValue}

# 定义属性保存数组
declare -a rename_function_config_content_array
cfg_line_count=0

# 读取属性配置文件
function read_rename_funtions_configs {
	IFS_OLD=$IFS
	IFS=$'\n'
	# 删除文件行首的空白字符 http://www.jb51.net/article/57972.htm
	for line in $(cat $cfg_file | sed 's/^[ \t]*//g')
	do
		is_comment=$(expr "$line" : '^#.*')
		echo "line=${line} is_common=${is_comment}"
		if [[ ${#line} -eq 0 ]] || [[ $(expr "$line" : '^#.*') -gt 0 ]]; then
			echo "blank line or comment line"
		else
			rename_function_config_content_array[$cfg_line_count]=$line
			cfg_line_count=$[ $cfg_line_count + 1 ]
			# echo "line>>>>${line}"
		fi	
	done
	IFS=${IFS_OLD}
}

# 重命名所有的方法
function rename_functions {

	# 读取属性配置文件
	read_rename_funtions_configs

	# 执行替换操作
	for (( i = 0; i < ${#rename_function_config_content_array[@]}; i++ )); do
		original_function_name=${rename_function_config_content_array[i]};
		# result_prop_name="${prop_prefix}${original_function_name}${prop_suffix}"
		result_function_name=yoyo_$(sed -n "$(($RANDOM*2))p" ./words)_$(sed -n "$(($RANDOM*2))p" ./words);
		sed -i '{
			s/'"${original_function_name}"'/'"${result_function_name}"'/g
		}' `grep ${original_function_name} -rl ${function_name_replace_dir}`
		echo "正在处理方法 ${original_function_name}....."
	done
}

# 获取和保存方法到方法配置文件
./GetAndStoreFunctions.sh \
	-i ${function_name_replace_dir}\
	-o ${cfg_file}\


# 执行属性重命名
rename_functions

echo "重命名方法完成."
