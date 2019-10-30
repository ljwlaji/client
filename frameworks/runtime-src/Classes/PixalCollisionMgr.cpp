#include "PixalCollisionMgr.h"

#define SINGLE_STEP 8.f
PixalCollisionMgr::PixalCollisionMgr()
{
}

PixalCollisionMgr::~PixalCollisionMgr()
{
	while (m_PixalTemplate.size())
	{
		PixalData* data = m_PixalTemplate.begin()->second;
		m_PixalTemplate.begin()->second = nullptr;
		delete data;
		m_PixalTemplate.erase(m_PixalTemplate.begin());
	}
}

bool PixalCollisionMgr::GetAlpha(const char * url, uint32 x, uint32 y)
{
	if (m_PixalTemplate.find(url) == m_PixalTemplate.end())
		return false;

	PixalData* data = m_PixalTemplate.find(url)->second;
	if (x >= data->GetWidth() || y >= data->GetHeight())
		return false;

	uint32 pos = data->getCurrentOffset(x, y);
	uint32 currPos = floor(pos / SINGLE_STEP);
	uint32 offset = pos % (uint32)SINGLE_STEP;
	return GetByteValue(data->getData()[currPos], offset);
}

void PixalCollisionMgr::link(const char* url)
{
	if (PixalData* data = GetData(url))
		data->m_RefrenceCount++;
}

void PixalCollisionMgr::unLink(const char* url)
{
	if (PixalData* data = GetData(url))
	{
		if (--data->m_RefrenceCount <= 0)
		{
			delete data;
			data = nullptr;
			m_PixalTemplate.erase(m_PixalTemplate.find(url));
#if COCOS2D_DEBUG >= 1
			CCLOG("Pixal Collision Data Removed : %s", url);
#endif
		}
	}
}

PixalData * PixalCollisionMgr::GetData(const char * url)
{
	m_Itr = m_PixalTemplate.find(url);
	return m_Itr != m_PixalTemplate.end() ? m_Itr->second : nullptr;
}

void PixalCollisionMgr::SetByteValue(uint8& src, uint8 pos, bool value)
{
	uint8 p = 0x01;
	if (value)
		src |= p << (pos);
	else src &= ~p << (pos);
}

bool PixalCollisionMgr::GetByteValue(uint8& src, uint8 pos)
{
	return src & 0x01 << pos;
}

bool PixalCollisionMgr::loadPNGData(const char * url)
{
	if (m_PixalTemplate.find(url) != m_PixalTemplate.end())
	{
		m_PixalTemplate.find(url)->second->m_RefrenceCount++;
		return true;
	}
	cocos2d::Image* image = nullptr;
	bool ret = false;
	do
	{
		image = new cocos2d::Image();
		CC_BREAK_IF(!image);
		CC_BREAK_IF(!image->initWithImageFile(url));
		CC_BREAK_IF(!(image->getRenderFormat() != cocos2d::Texture2D::PixelFormat::BGRA8888 && image->getRenderFormat() != cocos2d::Texture2D::PixelFormat::RGBA4444));

		uint32 totalWidth = image->getWidth();
		uint32 totalHeight = image->getHeight();
		uint32 requireSize = ceil(totalWidth * totalHeight / SINGLE_STEP);
		uint8* buffer = new (std::nothrow)uint8[requireSize]();
		CC_BREAK_IF(!buffer);

		PixalData* data = new PixalData(buffer, totalWidth, totalHeight);
		uint8* imgData = image->getData();
		uint32 step = 0;
		uint32 currPos = 0;
		uint8 offset = 0;
		for (int x = 0; x < totalWidth; x++)
			for (int y = 0; y < totalHeight; y++)
			{
				step = (y * totalWidth + x);
				currPos = floor(step / SINGLE_STEP);
				offset = step % (uint32)SINGLE_STEP;
				auto pixel = ((unsigned int *)imgData) + ((totalHeight - y - 1) * totalWidth + x);
				bool isVisible = (*pixel >> 24) & 0xff == 255;
				SetByteValue(buffer[currPos], offset, isVisible);
			}
		data->m_RefrenceCount++;
		m_PixalTemplate[url] = data;
		ret = true;
	} while (0);

	delete image;
	return ret;
}

void PixalCollisionMgr::UnitTest()
{

	uint8 testA = 0;
	for (int i = 1; i <= 8; i++)
	{
		SetByteValue(testA, i, true);
		CCLOG("%d", testA);
	}

	CCLOG("==========================");

	uint8 testB = 255;
	for (int i = 1; i <= 8; i++)
	{
		SetByteValue(testB, i, false);
		CCLOG("%d", testB);
	}

	CCLOG("==========================");

	uint8 testC = 255;
	for (int i = 1; i <= 8; i++)
		CCLOG("%d", GetByteValue(testC, i));


	testC = 0;
	for (int i = 1; i <= 8; i++)
		CCLOG("%d", GetByteValue(testC, i));

}
