#ifndef __ASSETS_MANAGER_H__
#define __ASSETS_MANAGER_H__

#include "ShareDefine.h"
#include <list>
#include <thread>
#include <atomic>
#include <functional>

class DownloadJob
{
public:
	DownloadJob(std::string _from, std::string _to, std::function<void(uint32, uint32)> __onProgress, std::function<void(DownloadJob*)> __onFinished) : 
		DownloadedSize(0), 
		From(_from), 
		To(_to), 
		OnProgress(__onProgress),
		OnFinished(__onFinished)
	{

	}

	~DownloadJob()
	{

	}
	//Where To Get File
	std::string From;
	//The Current Directory For Download Path
	std::string To;
	uint32 DownloadedSize;
	std::function<void(uint32, uint32)> OnProgress;
	std::function<void(DownloadJob*)> OnFinished;
};

class AssetsManager
{
public:
	static AssetsManager* GetInstance()
	{
		static AssetsManager mgr;
		return &mgr;
	}
	void PushDownloadJob(std::string& Form, std::string& To, std::function<void(uint32, uint32)> OnProgressCallBack, std::function<void(DownloadJob*)> OnFinishedCallBack);
	void Start();
	void SetPaused(bool Paused);
	void* GetDownloadHandler() const;

	uint32 GetFileHash(const char* FileData) const;

private:
	AssetsManager();
	~AssetsManager();
	void Run();
	// For Download Issus
	DownloadJob* GetFirstJob() const;
	void TerminateAllTasks();
	void CleanUpAfterTerminated();
	// End Of Download
	uint32 GetDownloadTaskNum() const;

private:
	std::atomic<bool> m_Stopped;
	std::atomic<bool> m_Paused;
	std::list<DownloadJob*> m_DownloadJobList;
	std::thread* m_DownloadThread;

	void* m_Handler;
};

#define sAssetsMgr AssetsManager::GetInstance()

#endif
