#include "GausBlurSprite.h"

GausBlurSprite * GausBlurSprite::createWithImage(const char* path)
{
    GausBlurSprite* sp = new (std::nothrow)GausBlurSprite();
    if (sp && sp->initWithImage(path))
    {
        sp->autorelease();
        return sp;
    }
    CC_SAFE_DELETE(sp);
    return nullptr;
}

GausBlurSprite * GausBlurSprite::createWithImage(CCImage* image)
{
    GausBlurSprite* sp = new (std::nothrow)GausBlurSprite();
    if (sp && sp->initWithImage(image))
    {
        sp->autorelease();
        return sp;
    }
    CC_SAFE_DELETE(sp);
    return nullptr;
}


bool GausBlurSprite::initWithImage(CCImage* img)
{
    bool ret = false;
    do
    {
        m_PixalFormat = img->getRenderFormat();
        m_dataLen = img->getDataLen();
        m_TextureDatas = new uint8[m_dataLen]();
        memcpy(m_TextureDatas, img->getData(), m_dataLen);
        m_MaxHeight = img->getHeight();
        m_MaxWidth = img->getWidth();
        CC_BREAK_IF(!m_Texture2D->initWithData(m_TextureDatas, img->getDataLen(),
            img->getRenderFormat(),
            img->getWidth(), img->getHeight(),
            Size(img->getWidth(), img->getHeight())));

        CC_BREAK_IF(!initWithTexture(m_Texture2D));
        setContentSize(Size(m_MaxWidth, m_MaxHeight));
        m_SingleStep = img->hasAlpha() ? 4 : 3;
        ret = true;
    } while (0);

    CC_SAFE_DELETE(img);
    return ret;
}

bool GausBlurSprite::initWithImage(const char* path)
{
	bool ret = false;
	CCImage* img = new(std::nothrow) CCImage();
	do
	{
		CC_BREAK_IF(!img || !img->initWithImageFile(path));
		m_PixalFormat = img->getRenderFormat();
		m_dataLen = img->getDataLen();
		m_TextureDatas = new uint8[m_dataLen]();
		memcpy(m_TextureDatas, img->getData(), m_dataLen);
		m_MaxHeight = img->getHeight();
		m_MaxWidth = img->getWidth();
		CC_BREAK_IF(!m_Texture2D->initWithData(m_TextureDatas, img->getDataLen(),
			img->getRenderFormat(),
			img->getWidth(), img->getHeight(),
			Size(img->getWidth(), img->getHeight())));

		CC_BREAK_IF(!initWithTexture(m_Texture2D));
		setContentSize(Size(m_MaxWidth, m_MaxHeight));
        m_SingleStep = img->hasAlpha() ? 4 : 3;
		ret = true;
	} while (0);

	CC_SAFE_DELETE(img);
	return ret;
}

GausBlurSprite::GausBlurSprite() : 
	m_Texture2D(new Texture2D()),
	m_TextureDatas(nullptr),
	m_MaxHeight(0),
	m_MaxWidth(0),
	m_GausRadio(2),
	m_dataLen(0),
    m_SingleStep(4),
    m_Inited(false)
{
    m_Texture2D->autorelease();
    CCLOG("GausBlurSprite Created");
}

GausBlurSprite::~GausBlurSprite()
{
    CC_SAFE_DELETE_ARRAY(m_TextureDatas);
}

void GausBlurSprite::override()
{
	if (m_MaxWidth <= 2)
		return;

	int TotalR = 0;
	int TotalG = 0;
	int TotalB = 0;				
	int currPos = 1;
	for (int height = 0; height < m_MaxHeight; height++)
		for (int width = 0; width < m_MaxWidth; width++)
		{
			bool isEdge = width == m_MaxWidth - 1;
			if (isEdge)
			{
				currPos = (height * m_MaxWidth + width) * m_SingleStep;
				memcpy(&m_TextureDatas[currPos], &m_TextureDatas[currPos - m_SingleStep], m_SingleStep);
			}
			else
			{
				TotalR = 0;
				TotalG = 0;
				TotalB = 0;
				int limitW = width + m_GausRadio;
				int limitH = height + m_GausRadio;
				for (int singleW = width - (m_GausRadio - 1); singleW < limitW; singleW++)
					for (int singleH = height - (m_GausRadio - 1); singleH < limitH; singleH++)
					{
						currPos = (singleH < 0 ? abs(singleH) : singleH) * m_MaxWidth * m_SingleStep + (singleW < 0 ? abs(singleW) : singleW) * m_SingleStep;
						TotalR += m_TextureDatas[currPos];
						TotalG += m_TextureDatas[currPos + 1];
						TotalB += m_TextureDatas[currPos + 2];
					}
				currPos = (height * m_MaxWidth + width) * m_SingleStep;
				m_TextureDatas[currPos] = TotalR * 0.11111111;
				m_TextureDatas[currPos + 1] = TotalG * 0.11111111;
				m_TextureDatas[currPos + 2] = TotalB * 0.11111111;
			}
		}
    if (!m_Inited)
    {
        m_Texture2D->initWithData(m_TextureDatas, m_dataLen, m_PixalFormat, m_MaxWidth, m_MaxHeight, Size());
        m_Inited = true;
    }
    else m_Texture2D->updateWithData(m_TextureDatas, 0, 0, m_MaxWidth, m_MaxHeight);
}
