#!/bin/sh

project_path=$(cd `dirname $0`; pwd)
cd $project_path
mv src src_back
cocos luacompile -s src_back -d src -e -k 19900530Aa -b firecore --disable-compile
cd frameworks/runtime-src/proj.android 
./gradlew assembledebug
cd ../../../
rm -rf src
mv src_back src