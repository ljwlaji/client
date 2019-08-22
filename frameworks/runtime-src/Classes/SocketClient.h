#ifndef __SOCKET_CLIENT_H__
#define __SOCKET_CLIENT_H__

#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <WinSock2.h>
#pragma comment(lib, "ws2_32.lib")
#else
#include <unistd.h> //uni std
#include <arpa/inet.h>
#include <string.h>
#include <sys/socket.h>
#endif

#include "ShareDefine.h"
#include <thread>
#include <atomic>

class SocketClient
{
public:
	static SocketClient* GetInstance()
	{
		static SocketClient Client;
		return &Client;
	}

	bool Connect(const char* IP, uint16 Port);
	void Close();
private:
	SocketClient();
	~SocketClient();

	void CleanUpBeforeClose();
	bool Init();
	void Run();
	void CloseSocket();

private:
	std::thread* m_SessionThread;
	uint32 m_Socket;
	std::atomic<bool> m_Stopped;
};


#define sSocket SocketClient::GetInstance()

#endif
