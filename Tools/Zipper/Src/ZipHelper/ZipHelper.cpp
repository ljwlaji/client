#include "ZipHelper.h"
#include "Core/zlib.h"
#include <string>

bool ZipHelper::Compress(const char * InBuffer, std::string& OutBuffer)
{
	uLong tlen = strlen(InBuffer) + 1;
	uLong blen;
	char* TempBuffer = new(std::nothrow) char();
	if (!TempBuffer)
		/*Not Enough Memery*/
		return false;

	blen = compressBound(tlen);

	if (compress((Bytef *)TempBuffer, &blen, (Bytef *)InBuffer, tlen) != Z_OK)
	{
		printf("compress failed!\n");
		delete[] TempBuffer;
		return false;
	}
	OutBuffer = TempBuffer;
	delete [] TempBuffer;
	return true;
}

bool ZipHelper::UnCompress(const char * InBuffer, std::string& OutBuffer)
{
	char* TempOut = new (std::nothrow) char();
	if (!TempOut)
		/*Not Enough Memery*/
		return false;


	uLong SourceLen = strlen(InBuffer) + 1 ;
	uLong LengOut = 0;
	if (uncompress((Bytef *)TempOut, &LengOut, (Bytef *)InBuffer, SourceLen) != Z_OK)
	{
		printf("compress failed!\n");
		delete[] TempOut;
		return false;
	}
	OutBuffer = TempOut;
	delete[] TempOut;
	return true;
}
