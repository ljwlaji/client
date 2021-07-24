#!/bin/bash
project_path=$(cd `dirname $0`; pwd)
echo $project_path
$project_path/runtime/mac/framework-desktop.app/Contents/MacOS/framework-desktop -workdir $project_path/MapEditor
