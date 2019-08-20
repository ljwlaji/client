#include "Session.h"
#include "cocos2d.h"

Session::Session() :
	m_BufferLenth(0)
{
	m_RecvedBuffer = (char*)malloc(sizeof(char));
}

Session::~Session()
{
	free(m_RecvedBuffer);
}

void Session::Update(uint32 diff)
{
	if (GetNextPacket())
	{

	}
}

void Session::PushBuffer(const char * buffer, uint32 length)
{
	m_BufferLock.lock();
	uint32 TempLength = m_BufferLenth;
	m_BufferLenth += length;
	char* reAlloced = (char*)realloc(m_RecvedBuffer, m_BufferLenth);
	m_RecvedBuffer = reAlloced ? reAlloced : m_RecvedBuffer;
	memcpy(&m_RecvedBuffer[TempLength], buffer, length);
	m_BufferLock.unlock();
}

void Session::TestOutPut()
{
	CCLOG("%s", m_RecvedBuffer);
}

void * Session::GetNextPacket()
{
	void* ret = nullptr;
	m_BufferLock.lock();

	//  |uint32|uint32|uint16|xxxxxxx|
	//	  size   time  opcode   body
	//Check Length At Least 4 + 4 + 2
	if (m_BufferLenth >= 10)
	{
		// Check Packet Complete
		uint32 PacketSize = *((uint32*)m_RecvedBuffer);
		if (m_BufferLenth >= PacketSize)
		{
			uint32 PacketTime = *((uint32*)m_RecvedBuffer[1]);
			uint16 PacketOpcode = *((uint16*)m_RecvedBuffer[4]);
			char* Body = new char();

		}
	}
	m_BufferLock.unlock();
	return ret;
}
