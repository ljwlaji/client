#ifndef __TIMMER_H__
#define __TIMMER_H__

#include "ShareDefine.h"
#include <chrono>

class Timmer
{
public:
	Timmer();
	~Timmer();

	uint32 GetMSDiff();
	uint32 GetSecondDiff();
	void ResetTimmer();
private:
	std::chrono::time_point<std::chrono::high_resolution_clock> m_Begin;

};

#endif