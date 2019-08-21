#include "Timmer.h"

Timmer::Timmer()
{
	m_Begin = std::chrono::high_resolution_clock::now();
}

Timmer::~Timmer()
{
}

uint32 Timmer::GetMSDiff()
{
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::high_resolution_clock::now() - m_Begin).count();
}

uint32 Timmer::GetSecondDiff()
{
	return std::chrono::duration_cast<std::chrono::seconds>(std::chrono::high_resolution_clock::now() - m_Begin).count();
}

void Timmer::ResetTimmer()
{
	m_Begin = std::chrono::high_resolution_clock::now();
}
