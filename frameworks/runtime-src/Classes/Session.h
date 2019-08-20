#ifndef __SESSION_H__
#define __SESSION_H__

#include "ShareDefine.h"
#include <mutex>


class Session
{
public:
	Session();
	~Session();


	void Update(uint32 diff);
	void PushBuffer(const char* buffer, uint32 length);

	void TestOutPut();
private:
	void* GetNextPacket();
private:
	std::mutex m_BufferLock;
	char* m_RecvedBuffer;
	uint32 m_BufferLenth;
};

#endif