#!/bin/bash
project_path=$(cd `dirname $0`; pwd)
echo $project_path
rm -rf /Users/ljw/Documents/Download
rm -rf /Users/ljw/Documents/res
rm -rf /Users/ljw/Documents/src
rm -rf $project_path/virtualDir
$project_path/runtime/mac/framework-desktop.app/Contents/MacOS/framework-desktop -workdir $project_path
