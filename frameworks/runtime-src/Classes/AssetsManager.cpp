#include "AssetsManager.h"
#include "curl/curl.h"
#include "cocos2d.h"

static size_t write_func(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	FILE *fp = (FILE*)userdata;
	size_t written = fwrite(ptr, size, nmemb, fp);
	return written;
}

static size_t getcontentlengthfunc(void *ptr, size_t size, size_t nmemb, void *data)
{
	return (size_t)(size * nmemb);
}


static int progress_func(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	DownloadJob* Job = (DownloadJob*)ptr;
	double speed = 0;
	curl_easy_getinfo((CURL*)sAssetsMgr->GetDownloadHandler(), CURLINFO_CONTENT_LENGTH_DOWNLOAD, &speed);
	uint32 TotalToDownload = Job->DownloadedSize + totalToDownload;
	Job->OnProgress(TotalToDownload, Job->DownloadedSize + nowDownloaded);
	return CURLE_OK;
}

uint32 AssetsManager::GetDownloadTaskNum() const
{
	return m_DownloadJobList.size();
}



void AssetsManager::SetPaused(bool Paused)
{
	m_Paused = Paused;
}

void AssetsManager::PushDownloadJob(std::string& Form, std::string& To, std::function<void(uint32, uint32)> OnProgressCallBack, std::function<void(DownloadJob*)> OnFinishedCallBack)
{
	if (FILE* file = fopen(To.c_str(), "r"))
	{
		fclose(file);
		remove(To.c_str());
	}

	DownloadJob* job = new DownloadJob(Form, To, OnProgressCallBack, OnFinishedCallBack);
	m_DownloadJobList.push_back(job);
}

void AssetsManager::Start()
{
	if (m_DownloadThread)
	{
		CCLOG("Download Task Already Started...");
		return;
	}
	m_Stopped = false;
	m_DownloadThread = new std::thread(&AssetsManager::Run, this);
}

void AssetsManager::Run()
{
	while (1)
	{
		if (m_Stopped)
		{
			CleanUpAfterTerminated();
			break;
		}

		while (m_Paused)
			std::this_thread::sleep_for(std::chrono::milliseconds(500));

		//Download
		if (DownloadJob* job = GetFirstJob())
		{
			FILE* FileToSave = nullptr;
			job->DownloadedSize = 0;
			if (FileToSave = fopen(job->To.c_str(), "r"))
			{
				fseek(FileToSave, 0, SEEK_END);
				job->DownloadedSize = ftell(FileToSave);
				fclose(FileToSave);
				FileToSave = nullptr;
			}
			FileToSave = fopen(job->To.c_str(), job->DownloadedSize > 0 ? "ab+" : "wb");
			if (FileToSave == NULL)
			{
				//Report Error
				m_Stopped = true;
				break;
			}
			m_Handler = curl_easy_init();
			curl_easy_setopt(m_Handler, CURLOPT_URL, job->From.c_str());
			curl_easy_setopt(m_Handler, CURLOPT_TIMEOUT, 10);
			curl_easy_setopt(m_Handler, CURLOPT_HEADERFUNCTION, getcontentlengthfunc);
			curl_easy_setopt(m_Handler, CURLOPT_WRITEFUNCTION, write_func);
			curl_easy_setopt(m_Handler, CURLOPT_WRITEDATA, FileToSave);
			curl_easy_setopt(m_Handler, CURLOPT_RESUME_FROM, 0);
			curl_easy_setopt(m_Handler, CURLOPT_RESUME_FROM_LARGE, (long long)(job->DownloadedSize));
			curl_easy_setopt(m_Handler, CURLOPT_NOPROGRESS, 0L);
			curl_easy_setopt(m_Handler, CURLOPT_PROGRESSFUNCTION, progress_func);
			curl_easy_setopt(m_Handler, CURLOPT_PROGRESSDATA, job);
			CURLcode res = curl_easy_perform(m_Handler);
			if (res != CURLE_ABORTED_BY_CALLBACK)
			{
				curl_easy_cleanup(m_Handler);
				m_Handler = nullptr;
				if (res == CURLE_OK)
				{
					job->OnFinished(job);
					m_DownloadJobList.pop_front();
					delete job;
				}
			}
			fclose(FileToSave);

			//All Done
			if (!m_DownloadJobList.size())
			{
				m_Stopped = true;
				m_DownloadThread = nullptr;
				break;
			}
		}
		else break;
	}
	CCLOG("All Task Finished");
}

DownloadJob * AssetsManager::GetFirstJob() const
{
	return m_DownloadJobList.size() ? *m_DownloadJobList.begin() : nullptr;
}

void AssetsManager::TerminateAllTasks()
{
	m_Stopped = true;
	if (m_DownloadThread)
	{
		m_DownloadThread->join();
		delete m_DownloadThread;
		m_DownloadThread = nullptr;
	}
	CleanUpAfterTerminated();
}

void AssetsManager::CleanUpAfterTerminated()
{
	if (m_Handler)
	{
		curl_easy_cleanup(m_Handler);
		m_Handler = nullptr;
	}
	while (m_DownloadJobList.size())
	{
		DownloadJob* job = *m_DownloadJobList.begin();
		m_DownloadJobList.pop_front();
		delete job;
	}

}

void* AssetsManager::GetDownloadHandler() const
{
	return (CURL*)m_Handler;
}

uint32 AssetsManager::GetFileHash(const char * FileData) const
{
	return std::hash<const char*>()(FileData);
}

AssetsManager::AssetsManager() : m_Stopped(true), m_DownloadThread(nullptr), m_Handler(nullptr)
{
}

AssetsManager::~AssetsManager()
{
}
