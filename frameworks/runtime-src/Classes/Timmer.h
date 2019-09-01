#ifndef __TIMMER_H__
#define __TIMMER_H__

#include "ShareDefine.h"
#include "cocos2d.h"
#include <chrono>

class Timmer : cocos2d::Node
{
public:
	static Timmer* create();
	uint32 GetMSDiff();
	uint32 GetSecondDiff();
	void ResetTimmer();
private:
	Timmer();
	~Timmer();
private:
	std::chrono::time_point<std::chrono::high_resolution_clock> m_Begin;

};

#endif