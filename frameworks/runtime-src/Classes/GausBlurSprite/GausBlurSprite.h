#ifndef __GSUS_BLUR_SPRITE_H__
#define __GSUS_BLUR_SPRITE_H__

#include "cocos2d.h"
#include "ShareDefine.h"
USING_NS_CC;

static uint8 GAUS_BLUR_RADIO = 3;

enum GAUSBLURTYPE
{
	GAUSBLURTYPE_COLOR		= 0,
	GAUSBLURTYPE_TEXTURE	= 1,
	GAUSBLURTYPE_SCENE		= 2,
	GAUSBLURTYPE_RECT		= 3,
};

class GausBlurSprite : public Sprite
{
public:
	static GausBlurSprite* createWithImage(const char* path);
    static GausBlurSprite* createWithImage(CCImage* image);
	void override();
private:
	GausBlurSprite();
	~GausBlurSprite();
	bool initWithImage(const char* path);
    bool initWithImage(CCImage* path);
    bool initWithData(unsigned char* data, uint32 width, uint32 height, bool hasAlpha);


	Texture2D* m_Texture2D;
	uint8* m_TextureDatas;
	Texture2D::PixelFormat m_PixalFormat;
	uint16 m_MaxHeight;
	uint16 m_MaxWidth;
	uint8 m_GausRadio;
	uint32 m_dataLen;
    uint8 m_SingleStep;
    bool m_Inited;
};


#endif // !__GSUS_BLUR_SPRITE_H__
