#!/bin/bash

####### 参数解析
echo "参数>>${@}"
while getopts :i:o: opt
do
	case "$opt" in
		i) handleDir="$(pwd)/$OPTARG"
			echo "Found the -i option, with parameter value $OPTARG"
			;;
		o) to_process_file_dir="$(pwd)/$OPTARG"
			echo "Found the -o option, with parameter value $OPTARG"
			;;
		*) echo "Unknown option: $opt";;
	esac
done
############## 配置

# 垃圾代码目录
# to_process_file_dir="$(pwd)/Sup_SDK_ket/ImmediateRelations"
# SDK混淆前\麦驰SDK201812191049\Sup_SDK_ket\Sup_SDK_ket\Sup_Managers_ket
# 需处理文件目录
# handleDir="$(pwd)/Sup_SDK_ket/Sup_SDK_ket"

# 暂时保存方法调用的文件夹
funDir="$(pwd)/configures/functionsDir"

# 导入工具脚本
. ./FileUtil.sh

# 检测 property_name_replace_dir
checkDirCore $to_process_file_dir "指定类文件搜索目录不存在"
to_process_file_dir=${CheckInputDestDirRecursiveReturnValue}

# 检测 handleDir
checkDirCore $handleDir "指定类文件搜索目录不存在"
handleDir=${CheckInputDestDirRecursiveReturnValue}

# 检测 funDir
checkDirCore $funDir "目录不存在"
funDir=${CheckInputDestDirRecursiveReturnValue}

# 放垃圾类的数组
declare -a classArray
# 垃圾类数组的长度
countOfClassArray=0

# 扫描垃圾代码的文件夹， 由他的方法 写出方法调用代码 并写入到文件夹 对应以类名为文件名的文件下
function addFuncionCallToDir {
    # 遍历垃圾代码的.m文件
    local find_result=$(find ${to_process_file_dir} -name '*\.m')
    for filePath in $find_result; do
        # 获取文件名
        local fileName=$(echo "${filePath}" | sed -r 's/.*\/([a-zA-Z_]+)\.m/\1/')
        # 随机字符串 从单词库里拿
        local params1=$(sed -n "$(($RANDOM*2))p" ./words)
        local params2=$(sed -n "$(($RANDOM*2 + 1))p" ./words)
        local params3=$(sed -n "$(($RANDOM*2))p" ./words)
        # 存放临时文件
        local newPath="${funDir}/${fileName}.txt"
        # 把临时路径放在数组里， 待会给正式代码加垃圾的使用用
        classArray[$countOfClassArray]=${newPath}
        countOfClassArray=$(($countOfClassArray + 1))
        # 把如下这样的代码调用放大.txt临时文件里
        # [Sup_UserMangager_ket StageReportHardAliasesRecursiveDestructive:@"str" Likely:@"str2" Specific:@"str3"]
        cat $filePath | sed -r -n 's/^-\(void\)([a-zA-Z]+)\:\(id\)[a-zA-Z_]+ ([a-zA-Z]+)\:\(id\)[a-zA-Z_]+ ([a-zA-Z]+)\:\(id\)[a-zA-Z_]+/[['"${fileName}"' new] \1:@"'"${params1}"'" \2:@"'"${params2}"'" \3:@"'"${params3}"'"];/p' > $newPath 
    done
    echo "扫描垃圾代码完成"
}


# 遍历工程代码文件夹，添加垃圾代码的调用到.m文件夹中
function addJunkCode {
    # 遍历垃圾代码的.m文件
    local funDirResult=$(find ${handleDir} -name '*\.m')
    for filePath in $funDirResult; do
        # 随机拿一个垃圾类
        local randomClass=${classArray[$((${RANDOM}%${countOfClassArray}))]}
        echo "拿一个垃圾类：${randomClass}"
        # 被插入.m文件的行数
        local lineCount=$(sed -n '$=' ${filePath})
        # 垃圾类方法执行文件的行数
        local lineCount2=$(sed -n '$=' ${randomClass})
        echo "随机取一个垃圾方法:${injected_content}"
        local whileCount=$(($lineCount/30))

        # 获取文件名 插入.h头文件， 不存在才添加
        local fileName=$(echo "${randomClass}" | sed -r 's/.*\/([a-zA-Z_]+)\.txt/\1/')
        local importItem="#import \"${fileName}.h\""
        local grepResult=$(grep "${importItem}" ${filePath})
        if [[ -z $grepResult ]]
        then
            sed -i '1 i '"${importItem}"'' ${filePath}
        fi

        for (( i = 0; i < $whileCount; i++));
        do
            # 随机取一个垃圾方法
            local randomLine=$((${RANDOM}%${lineCount2}+1))
            local injected_content=$(sed -n ''"${randomLine}p"'' ${randomClass})
            local start=$(($i*30+1))
            local end=$((($i+1)*30))
            sed -i ''"${start}"', '"$end"' {
                    /^[-+] \(.*\)/{
                    :tag1;
                    N;
                    /{$/!b tag1;
                    a '"$injected_content"'
                    }
            }' ${filePath}
            #sed -i ''"${start}"', '"${end}"' {
            #    /^- ?\(.*\)/{
            #    :tag1;
            #    N;
            #    /{$/!b tag1;
            #    a '"$injected_content"'
            #    }
            #}' ${filePath}
        done
    done
}
addFuncionCallToDir
addJunkCode
#Example\injectContentShell\injectFunctions.sh
