#include "UnitTest.h"
#include "AssetsManager.h"
#include "Zipper.h"
#include "cocos2d.h"


static void onProgress(uint32 a, uint32 b)
{
	CCLOG("%d || %d", a, b);
}

static void onFinished(DownloadJob* ptr)
{
	CCLOG("%s Finished", ptr->From.c_str());
}

void UnitTest::TestAssetsManger()
{
	std::string a = sAssetsMgr->GetFileHash("asdfasdfasdf");
	std::string b = sAssetsMgr->GetFileHash("asdfasdfasdf");
	std::string c = sAssetsMgr->GetFileHash("asdfasdfasdfaaa");
	std::string d = sAssetsMgr->GetFileHash("asdfasdfasdfbbb");

	/*
		std::string s = "http://speedtest.fremont.linode.com/100MB-fremont.bin";
		sAssetsMgr->PushDownloadJob(s, cocos2d::FileUtils::getInstance()->getWritablePath() + "test.exe", &onProgress, &onFinished);
		sAssetsMgr->PushDownloadJob(s, cocos2d::FileUtils::getInstance()->getWritablePath() + "teaast.exe", &onProgress, &onFinished);
		sAssetsMgr->Start();
	*/
}

void UnitTest::TestHash()
{
	std::string str1 = "Meet the new boss...";
	std::string str2 = "Meet the new boass...";
	std::hash<std::string> hash_fn;
	size_t str_hash1 = hash_fn(str1);
	size_t str_hash2 = hash_fn(str2);
}

void UnitTest::TestZip()
{
	std::string root = cocos2d::FileUtils::getInstance()->getWritablePath() + "Files";
	std::string ZipExecute = root + "//Test";
	std::string ZipExecut2 = root + "//Output";
	ZipReader Reader(ZipExecute + "//Test.FCZip");
	Reader.ExecuteAll(ZipExecut2);
}