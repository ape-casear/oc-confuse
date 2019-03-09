#!/bin/bash
########################
# 脚本功能：生成重命名的方法的配置脚本
# 输入参数 -i 输入的文件夹
# 输入参数 -o 保存的文件
########################

####### 参数定义
param_input_dir=""
param_output_file=""

####### 参数解析
echo "参数>>${@}"
while getopts :i:o: opt
do
	case "$opt" in
		i) param_input_dir=$OPTARG
			echo "Found the -i option, with parameter value $OPTARG"
			;;
		o) param_output_file=$OPTARG
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done
echo "param_input_dir = ${param_input_dir}"
echo "param_output_file = ${param_output_file}"

####### 配置

# 方法黑名单配置文件
blacklist_cfg_file="$(pwd)/configures/DefaultFunctionsBlackListConfig.cfg"

# 需要过滤的文件夹和文件
filterConfig="$(pwd)/configures/filterDirAndFileOfFunction.cfg"

####### 数据定义

# 定义保存源文件的数组
declare -a implement_source_file_array
implement_source_file_count=0
# 定义保存方法的数组
declare -a tmp_functions_array
functions_count=0


# mark: p384
# 递归函数读取目录下的所有.m文件
function read_source_file_recursively {
	echo "read_implement_file_recursively"
	if [[ -d $1 ]]; then
		for item in $(ls $1); do
			itemPath="$1/${item}"
			local isfilter=`grep -o ${item} ${filterConfig}`
			if [[ ${#isfilter} -eq 0 ]]; then
				if [[ -d $itemPath ]]; then
					# 目录
					echo "处理目录 ${itemPath}"
					read_source_file_recursively $itemPath
					echo "处理目录结束====="
				else 
					# 文件
					echo "处理文件 ${itemPath}"
					if [[ $(expr "$item" : '.*\.m') -gt 0 ]]; then
						echo ">>>>>>>>>>>>mmmmmmm"
						implement_source_file_array[$implement_source_file_count]=${itemPath}
						implement_source_file_count=$[ implement_source_file_count + 1 ];
					fi
					echo ""
				fi
			else
				echo 'filter: ==> '$isfilter
			fi
		done
	else
		echo "err:不是一个目录"
	fi
}

# 获取目录下的所有源文件，读取其中的方法
function get_functions_from_source_dir {

	local l_classed_folder=$1

	echo "获取需要处理的源文件... ${l_classed_folder}"
	# 读取需要处理目标文件
	read_source_file_recursively ${l_classed_folder}
    get_functions_from_source_file
}

# 读取源码中的方法，保存到数组中
# 参数一: 源码文件路径
function get_functions_from_source_file {

	for (( i = 0; i < ${#implement_source_file_array[@]}; i++ )); do
        echo "DEBUG here"
        echo "${implement_source_file_array[i]}"
		local functionGroup=`cat "${implement_source_file_array[i]}" | sed -r -n '/^[-+] ?\(.*\) ?([0-9a-zA-Z_]*)([\:\{])?/p' | sed -r 's/^[-+] ?\(.*\) ?([0-9a-zA-Z_]*).*/\1/'`
        # local functionGroup=$(sed -r 's/^- ?\(.*\)(mc_[a-zA-Z_]*)(\:.*)?/\1/' "${implement_source_file_array[i]}")
        echo $functionGroup;

		IFS_OLD=$IFS
        IFS=$'\n'
        for prop_line in $functionGroup; do
            echo ">>>>>${prop_line}"
			local isfilter=`grep -o ${prop_line} ${blacklist_cfg_file}`
			# 名字长于10 并且不在黑名单里
			if [[ ${#prop_line} -gt 10 ]] && [[ ${#isfilter} -eq 0 ]]; then
				tmp_functions_array[$functions_count]=$prop_line;
				functions_count=$[ $functions_count + 1 ]
			fi
        done
		IFS=$IFS_OLD;
        # if [[ -n $functionGroup ]]; then
		# 	exit 0
		# fi
	done
}

# 把获取到的方法过滤之后写入文件中
# 如果在执行的过程中遇到特殊情况，添加到黑名单配置（DefaultPropertiesBlackListConfig.cfg文件中添加配置）
function post_get_functions_handle {
	echo "写入到cfg文件"
    local prop_config_file=$1
	# 写入文件中
	echo "# Functions Configs" > ${prop_config_file}
	for key in $(echo ${!tmp_functions_array[*]})
	do
	    # echo "$key : ${tmp_functions_array[$key]}"
	    echo ${tmp_functions_array[$key]} >> ${prop_config_file}
	done
    # 去重
	cfg_back_file="${prop_config_file}.bak"
	mv ${prop_config_file} ${cfg_back_file}
	sort ${cfg_back_file} | uniq > ${prop_config_file}

	# 上一行的内容
	lastLine="";
	mv ${prop_config_file} ${cfg_back_file}
	echo "# functions Configs Filtered" > ${prop_config_file}
	IFS_OLD=$IFS
	IFS=$'\n'
	for line in $(cat ${cfg_back_file} | sed 's/^[ \t]*//g')
	do
		if [[ -n ${lastLine} ]]; then
			# 上一行是非空白行
			# 比较上一行内容是否是当前行的一部分，不是添加上一行
			if [[ ${line} =~ ${lastLine} ]]; then
				echo "${line} 和 ${lastLine} 有交集"
			else
				echo ${lastLine} >> ${prop_config_file}
			fi
		fi
		lastLine=${line}
	done
	IFS=${IFS_OLD}
	# 更新上一行
    # 删除临时文件
	rm -f ${cfg_back_file}

}

get_functions_from_source_dir ${param_input_dir}
post_get_functions_handle ${param_output_file}

# ./GetAndStoreFunctions.sh -i ./Sup_SDK_ket/Sup_SDK_ket -o ./configures/RenameFunctions.cfg
