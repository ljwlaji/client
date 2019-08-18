#include "SocketClient.h"

SocketClient::SocketClient() :
	m_SessionThread(nullptr),
	m_Socket(NULL),
	m_Stopped(true)
{
}

SocketClient::~SocketClient()
{
	Close();
}

bool SocketClient::Init()
{
	if (m_Socket)
		return true;
#ifdef WIN32
	WSADATA data;
	if (WSAStartup(MAKEWORD(2, 2), &data) != 0)
		return false;
#endif
	m_Socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	return m_Socket != INVALID_SOCKET;
}

void SocketClient::Run()
{
	char m_RecvBuffer[1024];
	while (1)
	{
		if (m_Stopped)
			break;
		int nLen = recv(m_Socket, m_RecvBuffer, sizeof(m_RecvBuffer), 0);
		if (nLen < -1)
			break;
		//Push Buffer To MainThread Queue

		std::this_thread::sleep_for(std::chrono::milliseconds(5));
	}

	//CleanUp Before Exit This Thread
	CloseSocket();
	m_Stopped = true;
	m_SessionThread = nullptr;
}


bool SocketClient::Connect(const char * IP, uint16 Port)
{
	if (m_Stopped)
		return true;

	bool Ret = false;
	if (Init())
	{
		sockaddr_in _sin = {};
		_sin.sin_family = AF_INET;
		_sin.sin_port = htons(Port);
#ifdef _WIN32
		_sin.sin_addr.S_un.S_addr = inet_addr(IP);
#else
		_sin.sin_addr.s_addr = inet_addr(IP);
#endif
		//sLog->OutLog(___F("SocketClientInited With PageFile <%d> \nServerIp <%s>\nPort<%d>", m_Socket, Ip, Port));
		if (connect(m_Socket, (sockaddr*)&_sin, sizeof(sockaddr_in)) != SOCKET_ERROR)
		{
			m_Stopped = false;
			m_SessionThread = new std::thread(&SocketClient::Run, this);
			return true;
		}
	}
	return false;
}

void SocketClient::CleanUpBeforeClose()
{
	//CleanThread
	if (m_SessionThread)
	{
		m_Stopped = true;
		m_SessionThread->join();
		delete m_SessionThread;
		m_SessionThread = nullptr;
	}
}

void SocketClient::Close()
{
	CleanUpBeforeClose();
	CloseSocket();
}

void SocketClient::CloseSocket()
{
	if (m_Socket)
	{
#ifdef WIN32
		closesocket(m_Socket);
#else
		close(m_Socket);
#endif
		m_Socket = NULL;
}
}