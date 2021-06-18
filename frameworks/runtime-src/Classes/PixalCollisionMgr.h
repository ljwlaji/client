#ifndef __Pixal_Collision_Mgr_H__
#define __Pixal_Collision_Mgr_H__

#include <cocos2d.h>
#include "ShareDefine.h"

struct PixalData
{
public:
	PixalData(uint8* data, uint32 width, uint32 height) : 
		m_Data(data),
		m_Height(height),
		m_Width(width),
		m_RefrenceCount(0)
	{
	}
	~PixalData() 
	{
		delete m_Data;
		m_Data = nullptr;
	}

	uint32 getCurrentOffset(uint32 x, uint32 y)
	{
		return y * m_Width + x;
	}

	uint32 GetWidth()
	{
		return m_Width;
	}

	uint32 GetHeight()
	{
		return m_Height;
	}

	uint8* getData()
	{
		return m_Data;
	}
	uint32 getRefrenceCount() 	{ return m_RefrenceCount; }
	void retain() 				{ --m_RefrenceCount; }
	void release()				{ --m_RefrenceCount; }
private:
	uint32 m_RefrenceCount;
	uint32 m_Height;
	uint32 m_Width;
	uint8* m_Data;
};

class PixalCollisionMgr
{
public:
	static PixalCollisionMgr* GetInstance()
	{
		static PixalCollisionMgr _PixalCollisionMgr;
		return &_PixalCollisionMgr;
	}

	bool loadPNGData(const char* url);
	void UnitTest();
	bool GetAlpha(const char* url, uint32 x, uint32 y);

	void link(const char* url);
	void unLink(const char* url);

	PixalData* GetData(const char* url);

private:
	PixalCollisionMgr();
	~PixalCollisionMgr();

	void SetByteValue(uint8& src, uint8 pos, bool value);
	bool GetByteValue(uint8& src, uint8 pos);


private:
	std::map<std::string, PixalData*> m_PixalTemplate;
	std::map<std::string, PixalData*>::iterator m_Itr;
};


#endif