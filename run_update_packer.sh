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

run_map_extractor()
{
	check_file_exist "${project_path}/Tools/src/main_map_exec.lua"
	if [ -f "${project_path}/Tools/src/main.lua" ]; then
		rm "${project_path}/Tools/src/main.lua"
	fi
	cp "${project_path}/Tools/src/main_map_exec.lua" "${project_path}/Tools/src/main.lua"
	$project_path/runtime/mac/framework-desktop.app/Contents/MacOS/framework-desktop -workdir $project_path/Tools
}

run_packer()
{
	clear
	read -p "自动打包即将开始, 请确认已经提交所有修改项, 输入任意键开始脚本! "
	firstCommit="$(get_input_val '请输入初始commit(7位以上) : ' )"
	lastCommit="$(get_input_val '请输入目标commit(7位以上) : ' )" 
	if [ -d "${project_path}/Update" ]; then
		rm -r "${project_path}/Update"
	fi
	mkdir ${project_path}/Update
	read -p "初始commit是 : [${firstCommit}] 初始commit是 : [${lastCommit}] 确认无误后输入Y继续: " comfirm
	run_sql_compare $firstCommit $lastCommit
	run_source_packer $firstCommit $lastCommit
	read -p "按任意键返回 :"
}

run_sql_compare()
{
	firstCommit=$1
	lastCommit=$2

	if [ "$comfirm" != "Y" -a "$comfirm" != "y" ]; then
		exit
	fi


	echo "正在拷贝数据库文件到工作目录"
	# 清理工作目录
	compareDir="${project_path}/sqlcompare"
	clear_dir "${compareDir}"


	# 切换到老分支
	git reset $firstCommit res/datas.db
	echo git reset $firstCommit res/datas.db
	git checkout res/datas.db
	dbfile="${project_path}/res/datas.db"
	check_file_exist "${dbfile}"
	cp "${dbfile}" "${compareDir}/"
	mv "${compareDir}/datas.db" "${compareDir}/data_old.db"
	check_file_exist "${compareDir}/data_old.db"

	# 切换到新分支
	git reset $lastCommit res/datas.db
	git checkout res/datas.db
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

	cat $project_path/Update/Log/sql_compare_log.txt
	echo ""
}

run_source_packer()
{
	firstCommit=$1
	lastCommit=$2

	fileData="require 'functions'\nimport('AutoUpdater').run('${firstCommit}', '${lastCommit}' )"
	# 初始工作完成 执行对比脚本

	if [ -f "${project_path}/Tools/src/main.lua" ]; then
		rm "${project_path}/Tools/src/main.lua"
	fi

	touch "${project_path}/Tools/src/main.lua"
	cat "${project_path}/Tools/src/main.lua"

	echo "${fileData}" >> "${project_path}/Tools/src/main.lua"

	$project_path/runtime/mac/framework-desktop.app/Contents/MacOS/framework-desktop -workdir $project_path/Tools

	echo "${project_path}/Update/Log/log.txt"

	if [ -f "${project_path}/Update/Log/log.txt" ]; then
		cat "${project_path}/Update/Log/log.txt"
	else
		echo "打包脚本出现了未知问题...."
	fi
	echo "正在提交更新记录到git..."
	git add res/version AllUpdates
	git commit -m "auto commit by update_packer"
	echo '打包脚本运行完成, 打包日志查询: ${project_path}/Update/Logs'
	read -p "按任意键返回 :"
}

autoUpload()
{
	scp ${project_path}/Update/*.FCZip "root@vv2.azerothcn.com:/home/wwwroot/3DCEList/update/downloads/"
	scp ${project_path}/AllUpdates "root@vv2.azerothcn.com:/home/wwwroot/3DCEList/update/"
	read -p "按任意键返回 :"
}

buildZipper()
{
	SelectPlatform "请选择对应平台:"
	read -p "请输入对应平台 :" value;
	if [ $value == "1" ]; then
		read -p "进入[构建Zipper工具]按任意键继续:"
		rm -rf ${project_path}/Tools/Zipper/Buildings
		mkdir ${project_path}/Tools/Zipper/Buildings
		cd ${project_path}/Tools/Zipper/Buildings
		cmake .. -G Xcode
		xcodebuild -project Zipper.xcodeproj -scheme Zipper -configuration Release
		rm -rf ${project_path}/Tools/bin
		mkdir ${project_path}/Tools/bin
		cp ${project_path}/Tools/Zipper/Buildings/bin/Release/Zipper ${project_path}/Tools/bin/
		read -p "构建完成 按任意键返回:"
	fi
}

buildMacOS()
{
	read -p "输入项目.xcodeproj名, 默认为(framework.xcodeproj) :" proj;
	if [ "${proj}" == "" ]; then
		proj="framework.xcodeproj"
	fi
	echo "proj: $proj"

	read -p "输入目标scheme, 默认为(framework-desktop) :" scheme;
	if [ "${scheme}" == "" ]; then
		scheme="framework-desktop"
	fi
	echo "scheme: $scheme"

	read -p "输入目标dest, 默认为(platform=macOS,arch=x86_64,id=00008103-0002291122F2001E) :" dest;
	if [ "${dest}" == "" ]; then
		dest="platform=macOS,arch=x86_64,id=00008103-0002291122F2001E"
	fi
	echo "dest: $dest"

	read -p "输入目标版本, 默认为(Debug) :" mode;
	if [ "${mode}" == "" ]; then
		mode="Debug"
	fi
	echo "mode: $mode"

	read -p "是否将lua文件编译为字节码(Y) :" codec;
	if [ "${codec}" == "Y" ]; then
		clear_dir $project_path/src_c
		mkdir $project_path/src_c/src
		compileLua $project_path/src $project_path/src_c
		mv $project_path/src $project_path/src_back
		mv $project_path/src_c/src $project_path/src
		cd ${project_path}/frameworks/runtime-src/proj.ios_mac
	fi

	echo "xcodebuild MACOSX_DEPLOYMENT_TARGET=11.2 -project $proj -scheme $scheme -destination '$dest' -configuration $mode"
	xcodebuild MACOSX_DEPLOYMENT_TARGET=11.2 -project $proj -scheme $scheme -destination "$dest" -configuration $mode

	if [ "${codec}" == "Y" ]; then
		rm -rf $project_path/src
		mv $project_path/src_back $project_path/src
	fi
	read -p "执行完成, 按任意键继续 :" value;
}

SelectPlatform()
{
	clear
	echo "====================================="
	echo $1
	echo "1. MacOS."
	echo "2. iOS."
	echo "3. Windows."
	echo "4. Linux."
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo "0, 返回"
	echo ""
	echo ""
	echo ""
	echo ""
	echo "====================================="
	echo ""
	echo ""
}

buildProject()
{
	while [ 1 == 1 ]; do
		SelectPlatform "请选择目标平台:"
		read -p "请输入当前环境 :" value;
		if [ "${value}" == "1" ]; then
			buildMacOS
		fi
		if [ "${value}" == "0" ]; then
			return
		fi
	done
}

compileLua()
{
	for file in $1/*
	do
	    if test -f $file 
	    then
	    	echo "正在编译" $file
			luajit -b $file $2${file#*${project_path}}c
	    else 
	    	if test -d $file 
	    	then
		        mkdir $2${file#*${project_path}}
		        compileLua $file $2
		    fi
	    fi
	done
}

makeLink()
{
	cd $project_path/MapEditor/src/app
	ln -s $project_path/src/app/components components
	read -p "执行完成, 按任意键继续 :" value;
}

start()
{
	clear
	echo "====================================="
	echo "半自动打包脚本运行中..."
	echo "1. 打包更新数据."
	echo "2. "
	echo "3. 自动上传资源"
	echo "4. 单独编译Lua文件"
	echo "5. 创建软连接"
	echo ""
	echo "7. 自动打包工程."
	echo "8. 构建Zipper工具"
	echo "9. 导出地图数据."
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo "====================================="
	echo ""
	echo ""
	read -p "请输入你的选择 :" value;
	if [ "${value}" == "9" ]; then
		run_map_extractor
	fi
	if [ "${value}" == "1" ]; then
		run_packer
	fi
	if [ "${value}" == "3" ]; then
		autoUpload
	fi
	if [ "${value}" == "4" ]; then
		clear_dir $project_path/src_c
		mkdir $project_path/src_c/src
		compileLua $project_path/src $project_path/src_c
		read -p "完成 :" value;
	fi
	if [ "${value}" == "5" ]; then
		makeLink
	fi
	if [ "${value}" == "7" ]; then
		buildProject
	fi
	if [ "${value}" == "8" ]; then
		buildZipper
	fi
}

while [ 1 == 1 ]; do
	start
done