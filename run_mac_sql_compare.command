#!/bin/bash
project_path=$(cd `dirname $0`; pwd)
# echo "当前路径: $project_path"

read -p "自动打包即将开始, 请确认已经提交所有修改项, 输入任意键开始脚本"


# result=$(git status | grep "nothing to commit, working tree clean")
# if ["$result" == ""]
# then
# 	echo "git工作目录有未处理的文件, 请处理完毕再运行本脚本!"
# 	exit
# fi
# echo "$result"

# 清理工作目录
# echo "${project_path}/sqlcompare"

compareDir="${project_path}/sqlcompare"
if [ -d "$compareDir" ];then
rm -r "$compareDir"
fi
mkdir "$compareDir"

cp "${project_path}/res/datas.db" "${compareDir}/"
mv "${compareDir}/datas.db" "${compareDir}/data_new.db"






# read -p "input the based commit :" baseCommit
# echo "baesCommit : $baseCommit"


# $project_path/runtime/mac/framework-desktop.app/Contents/MacOS/framework-desktop -workdir $project_path/Tools
