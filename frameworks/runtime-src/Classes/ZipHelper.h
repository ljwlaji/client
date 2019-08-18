#pragma once

#include <string>

namespace ZipHelper
{
	static bool Compress(const char* InBuffer, std::string& OutBuffer);
	static bool UnCompress(const char* InBuffer, std::string& OutBuffer);
}