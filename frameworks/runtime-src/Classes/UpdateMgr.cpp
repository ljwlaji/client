#include "UpdateMgr.h"
#include "cocos2d.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "external/curl/include/android/curl/curl.h"
#else
#include <curl/curl.h>
#endif


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
	double speed = 0;
	curl_easy_getinfo((CURL*)sUpdateMgr->GetDownloadHandler(), CURLINFO_CONTENT_LENGTH_DOWNLOAD, &speed);
	sUpdateMgr->OnProgress(sUpdateMgr->GetDownloadedSize() + nowDownloaded, sUpdateMgr->GetDownloadedSize() + totalToDownload);
	return CURLE_OK;
}

void UpdateMgr::StartWithTask(std::string& Form, std::string& To)
{
	if (!m_Stopped || m_DownloadThread)
		return;
    m_Error = 0;
	m_Stopped = false;
	m_From = Form;
	m_To = To;
	m_DownloadThread = new std::thread(&UpdateMgr::Run, this);
}

void UpdateMgr::Run()
{
	while (1)
	{
        if (m_Paused)
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(500));
            continue;
        }
		if (m_Stopped)
		{
			CleanUpAfterTerminated();
			break;
		}

		//Download
		FILE* FileToSave = nullptr;
		m_Downloaded = 0;
		if (FileToSave = fopen(m_To.c_str(), "r"))
		{
			fseek(FileToSave, 0, SEEK_END);
			m_Downloaded = ftell(FileToSave);
			fclose(FileToSave);
			FileToSave = nullptr;
		}
		FileToSave = fopen(m_To.c_str(), m_Downloaded > 0 ? "ab+" : "wb");
		if (FileToSave == NULL)
		{
			//Report Error
			m_Stopped = true;
			break;
		}

		m_Handler = m_Handler ? m_Handler : curl_easy_init();
		curl_easy_setopt(m_Handler, CURLOPT_URL, m_From.c_str());
		curl_easy_setopt(m_Handler, CURLOPT_TIMEOUT, 10);
		curl_easy_setopt(m_Handler, CURLOPT_HEADERFUNCTION, getcontentlengthfunc);
		curl_easy_setopt(m_Handler, CURLOPT_WRITEFUNCTION, write_func);
		curl_easy_setopt(m_Handler, CURLOPT_WRITEDATA, FileToSave);
		curl_easy_setopt(m_Handler, CURLOPT_RESUME_FROM, 0);
		curl_easy_setopt(m_Handler, CURLOPT_RESUME_FROM_LARGE, (long long)(m_Downloaded));
		curl_easy_setopt(m_Handler, CURLOPT_NOPROGRESS, 0L);
		curl_easy_setopt(m_Handler, CURLOPT_PROGRESSFUNCTION, progress_func);
		curl_easy_setopt(m_Handler, CURLOPT_PROGRESSDATA, this);
		CURLcode res = curl_easy_perform(m_Handler);
		fclose(FileToSave);
		if (res != CURLE_ABORTED_BY_CALLBACK)
		{
			curl_easy_cleanup(m_Handler);
			m_Handler = nullptr;
			break;
		}
	}
	m_Stopped = true;
	m_DownloadThread = nullptr;
	CCLOG("All Task Finished");
}

void UpdateMgr::TerminateAllTasks()
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

void UpdateMgr::CleanUpAfterTerminated()
{
	if (m_Handler)
	{
		curl_easy_cleanup(m_Handler);
		m_Handler = nullptr;
	}
}

void* UpdateMgr::GetDownloadHandler() const
{
	return (CURL*)m_Handler;
}

void UpdateMgr::OnProgress(uint32 Now, uint32 Total)
{
	m_OutputTotalSize = Total;
	m_OutputDownLoadSize = Now;
}

UpdateMgr::UpdateMgr() :
    m_Stopped(true),
    m_DownloadThread(nullptr),
    m_Handler(nullptr),
    m_Paused(false)
{
}

UpdateMgr::~UpdateMgr()
{
    TerminateAllTasks();
}
