#!/bin/bash

####### 参数解析
echo "参数>>${@}"
while getopts :i: opt
do
	case "$opt" in
		i) workDir="$(pwd)/$OPTARG"
			echo "Found the -i option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done

####### 配置
# 工作目录
# workDir="$(pwd)/Sup_SDK_ket/Sup_SDK_ket"
# 替换的属性配置文件
cfg_file="$(pwd)/configures/addFunctions.cfg"

# 导入工具脚本
. ./FileUtil.sh
# 检测 workDir
checkDirCore $workDir "指定类的查找目录不存在"
workDir=${CheckInputDestDirRecursiveReturnValue} 


# 申明装函数的数组
declare -a functionArray;

# 添加随机5-10个方法到functionArray数组
function generateFunctions {
    # 5-10个
    local arrLength=$((${RANDOM}%5 + 6))
    for (( i = 0; i < arrLength; i++));do
        local prefix='-'
        if [[ $RANDOM -gt 23000 ]]
        then
            prefix='+'
        fi

        local functionNameHead=Yoyo_$(sed -n "$(($RANDOM*2 + 1))p" ./words)_$(sed -n "$(($RANDOM*2))p" ./words);
        local paramsName1=$(sed -n "$(($RANDOM + 10000))p" ./words);
        local returnData=$(sed -n "$(($RANDOM%26 + 1))P" ./type.txt);

        local paramData=$(sed -n "$(($RANDOM%26 + 1))p" ./type.txt);
        # 各个部分
        # echo "prefix:"${prefix}
        # echo "returnData:"${returnData}
        # echo "functionNameHead:"${functionNameHead}
        # echo "paramData:"${paramData}
        # echo "paramsName1:"${paramsName1}
        local oneline=""
        if [[ $RANDOM -gt 20000 ]]
        then
            local functionName2=$(sed -n "$(($RANDOM + 10000))p" ./words);
            local paramsName2=$(sed -n "$(($RANDOM + 10000))p" ./words);
            local paramData2=$(sed -n "$(($RANDOM%26 + 1))p" ./type.txt);
            oneline="${prefix} (${returnData})${functionNameHead}:(${paramData})${paramsName1} ${functionName2}:(${paramData2})${paramsName2};"
        else
            oneline="${prefix} (${returnData})${functionNameHead}:(${paramData})${paramsName1};"
        fi
        # 完整方法： - (NSArray*)Yoyo_Kierkegaard_countering:(NSURL*)imbeddedcookout;
        echo $oneline
        echo $oneline >> $cfg_file
        functionArray[$i]=$oneline;
    done
}

# 引入项
importItem="#import <UIKit/UIKit.h>";
# 添加方法到.h文件
function addFunctions {
    local find_result=$(find ${workDir} -name '*\.h')
    echo "# 添加的函数" >> $cfg_file
    for filePath in $find_result; do
        echo '********** 正在处理文件 ************'
        echo  $filePath
        # 生成随机函数添加入函数数组
        generateFunctions
        # 添加#import <UIKit/UIKit.h>到头部
        local grepResult=$(grep "${importItem}" ${filePath})
        if [[ -z $grepResult ]]
        then
            sed -i '1 i '"${importItem}"'' ${filePath}
        fi

        for (( i = 0; i < ${#functionArray[@]}; i++))
        do
            # 插入@end 之前
            sed -i '/@end/ i '"${functionArray[i]}"'' ${filePath}
        done

        # 清空函数数组
        functionArray=()
    done
}
addFunctions

