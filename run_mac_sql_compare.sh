#数据库自动打包脚本
#!/bin/bash
project_path=$(cd `dirname $0`; pwd)
# echo "当前路径: $project_path"

function clear_dir()
{
	if [ -d "$1" ];then rm -r "$1"; fi
	mkdir "$1"
	return 0;
}

switch_to_commit()
{
	result=$(git checkout $1)
	result=$(git rev-parse --short HEAD | grep "$1")
	if [ "${result}" == "" ];then
		echo "期缴切换失败, 请检查版本号[$1]是否正确!"
		exit 0;
	else
		echo "已切换到提交[$1]"
	fi
}

check_file_exist()
{
	if [ ! -f "$1" ]; then
		echo "文件[$1]不存在." 
		exit 0;
	fi
}

get_input_val()
{
	value=""
	while [ "${value}" == "" -o "${#value}" != 7 ]; do
		read -p "${1} " value;
	done
	echo "${value}";
}

read -p "自动打包即将开始, 请确认已经提交所有修改项, 输入任意键开始脚本! "
echo "$(git pull)"
firstCommit="$(get_input_val '请输入初始commit(7位以上) : ' )"
lastCommit="$(get_input_val '请输入目标commit(7位以上) : ' )" 
# echo "$firstCommit"
# read -p "请输入目标commit: " lastCommit
read -p "初始commit是 : [${firstCommit}] 初始commit是 : [${lastCommit}] 确认无误后输入Y继续: " comfirm

if [ "$comfirm" != "Y" -a "$comfirm" != "y" ]; then
	exit
fi


echo "正在拷贝数据库文件到工作目录"
# 清理工作目录
compareDir="${project_path}/sqlcompare"
clear_dir "${compareDir}"


# 切换到老分支
switch_to_commit "${firstCommit}"

dbfile="${project_path}/res/datas.db"
check_file_exist "${dbfile}"
cp "${dbfile}" "${compareDir}/"
mv "${compareDir}/datas.db" "${compareDir}/data_old.db"
check_file_exist "${compareDir}/data_old.db"


# 切换到新分支
switch_to_commit "${lastCommit}"
check_file_exist "${dbfile}"
cp "${dbfile}" "${compareDir}/"
mv "${compareDir}/datas.db" "${compareDir}/data_new.db"
check_file_exist "${compareDir}/data_new.db"

# 初始工作完成 执行对比脚本
check_file_exist "${project_path}/Tools/src/main_sql_compare.lua"
if [ -f "${project_path}/Tools/src/main.lua" ]; then
	rm "${project_path}/Tools/src/main.lua"
fi
cp "${project_path}/Tools/src/main_sql_compare.lua" "${project_path}/Tools/src/main.lua"

$project_path/runtime/mac/framework-desktop.app/Contents/MacOS/framework-desktop -workdir $project_path/Tools
