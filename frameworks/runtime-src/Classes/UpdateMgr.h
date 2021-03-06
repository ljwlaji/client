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

class UpdateMgr
{
public:
	static UpdateMgr* GetInstance()
	{
		static UpdateMgr mgr;
		return &mgr;
	}
	void StartWithTask(std::string& Form, std::string& To);
	void* GetDownloadHandler() const;
	uint32 GetDownloadedSize() const { return m_Downloaded; }
	void OnProgress(uint32 Now, uint32 Total);
	bool IsStopped() const { return m_Stopped; }
	uint32 GetErrorCode() const { return m_ErrorCode; }
	uint32 GetDownloadedSizeDisplay() const { return m_OutputDownLoadSize; }
	uint32 GetTotalSizeDisplay() const { return m_OutputTotalSize; }

private:
	UpdateMgr();
	~UpdateMgr();
	void Run();
	// For Download Issus
	void TerminateAllTasks();
	void CleanUpAfterTerminated();
	// End Of Download
	uint32 GetDownloadTaskNum() const;

private:
	uint32 m_OutputDownLoadSize;
	uint32 m_OutputTotalSize;
private:
	std::string m_From;
	std::string m_To;
	uint32 m_Downloaded;
	uint32 m_TotalToDownload;
	std::atomic<bool> m_Stopped;
	std::thread* m_DownloadThread;
	uint32 m_ErrorCode;

	void* m_Handler;
};

#define sUpdateMgr UpdateMgr::GetInstance()

#endif
