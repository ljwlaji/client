#include "UnitTest.h"
#include "AssetsManager.h"
#include "Zipper.h"
#include "SocketClient.h"
#include "Session.h"
#include "cocos2d.h"
#include "PixalCollisionMgr.h"
#include "SHA1.h"
#include "MD5.h"

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
	uint32 a = sAssetsMgr->GetFileHash("asdfasdfasdf");
	uint32 b = sAssetsMgr->GetFileHash("asdfasdfasdf");
	uint32 c = sAssetsMgr->GetFileHash("asdfasdfasdfaaa");
	uint32 d = sAssetsMgr->GetFileHash("asdfasdfasdfbbb");

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

void UnitTest::TestSocketClient()
{
}

void UnitTest::TestSessionBuffer()
{
	/*
		Session s;
	std::string input = "123";
	s.PushBuffer(input.c_str(), strlen(input.c_str()));
	s.TestOutPut();
	s.PushBuffer(input.c_str(), strlen(input.c_str()));
	s.TestOutPut();
	s.PushBuffer(input.c_str(), strlen(input.c_str()));
	s.TestOutPut();
	s.PushBuffer("\0", 1);
	s.TestOutPut();
	*/

	PixalCollisionMgr::GetInstance()->UnitTest();
}

void UnitTest::TestSHA1()
{
	std::string input = "123123123123123";
	CSHA1 sha1;
	sha1.Update((unsigned char*)input.c_str(), strlen(input.c_str()));
	//sha1.Update((unsigned char*)str2, strlen(str2);
	sha1.Final();
	uint8 cha[20];
	sha1.GetHash(cha);

	std::string copy = "";
	char msg[20];
	for (int i = 0; i < 20; i++)
	{
		snprintf(msg, 20, "%d", cha[i]);
		copy += msg;
	}

	CCLOG("%s", copy);
}

void PrintMD5(const string& str, MD5& md5) {
	CCLOG("%s", md5.toString().c_str());
}

void UnitTest::TestMD5()
{
	MD5 md5;
	md5.update("");
	PrintMD5("", md5);
	md5.update("a");
	PrintMD5("a", md5);

	md5.update("bc");
	PrintMD5("abc", md5);

	md5.update("defghijklmnopqrstuvwxyz");
	PrintMD5("abcdefghijklmnopqrstuvwxyz", md5);

	md5.reset();
	md5.update("message digest");
	PrintMD5("message digest", md5);
}

