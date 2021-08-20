#pragma once
#include <list>
#include <string>
#include <map>
#include "zlib.h"
#include "ShareDefine.h"

using namespace std;

struct FCFile
{
	FCFile(std::string fileName = "", char* FileData = nullptr) : FileName(fileName), FileData(FileData)
	{
		
	}
	~FCFile()
	{
		Desotry();
	}

	bool FillData(char* buff, uint32& ReadPos)
	{
		bool ret = false;
		uint32* Buffer = (uint32*)&buff[ReadPos];
		uint32 HeadLen = Buffer[0];
		uint32 DataLen = Buffer[2];
		uint32 TotalFileLen = HeadLen + DataLen;

		FileData = new (std::nothrow) char[TotalFileLen]();
		if (FileData)
		{
			memcpy(FileData, &buff[ReadPos], TotalFileLen);
			ReadPos += TotalFileLen;

			FileName = GetFileName();
			Index = GetIndex();
			ParentIndex = GetParentIndex();
			ret = true;
		}
		return ret;
	}
	void Serialize(char* buff, uint32& Pos)
	{
		if (FileData)
		{
			char* start = &buff[Pos];
			memcpy(start, &FileData[0], GetFileSize());
			Pos += GetFileSize();
		}
		for (std::map<uint32, FCFile*>::iterator i = DirInfo.begin(); i != DirInfo.end(); i++)
			i->second->Serialize(buff, Pos);
	}

	bool IsDataVaild()
	{
		if (IsDir())
			return true;

		uLong OriginLen = GetOriginFileLen();
		char* OriginFileData = new (std::nothrow)char[OriginLen]();
		if (!OriginFileData)
			return false;

		int stat = uncompress((Bytef*)OriginFileData, (uLong*)&OriginLen, (Bytef*)GetDataPointer(), GetCompressLen());
		delete[] OriginFileData;
		return stat == Z_OK;

	}

	int GetFileSize()
	{
		return GetHeadLen() + GetCompressLen();
	}

	void GetTotalSize(uint32& TotalSize)
	{
		for (std::map<uint32, FCFile*>::iterator i = DirInfo.begin(); i != DirInfo.end(); i++)
			i->second->GetTotalSize(TotalSize);
		if (FileData)
			TotalSize += GetFileSize();
	}

	char* GetDataPointer()
	{
		if (FileData)
			return &FileData[GetHeadLen()];
        return nullptr;
	}

	int GetIndex()
	{
		//Insert HeadLen
		//Insert OriginLen
		//Insert CompressLen
		//Insert Index
		//Insert ParentIndex
		return ((int*)FileData)[3];
	}

	std::string GetFileName()
	{
		std::string ret = "";
		if (FileData)
		{
			int NameLen = GetHeadLen() - sizeof(uint32) * 5;
			char* pointer = &FileData[sizeof(uint32) * 5];
			for (uint32 i = 0; i < NameLen; i++)
				ret += pointer[i];
		}
		return ret;
	}

	int GetHeadLen()
	{
		return ((uint32*)FileData)[0];
	}

	int GetCompressLen()
	{
		return ((uint32*)FileData)[2];
	}

	int GetOriginFileLen()
	{
		return ((uint32*)FileData)[1];
	}

	int GetParentIndex()
	{
		return ((uint32*)FileData)[4];
	}

	int IsDir()
	{
		if (!FileData)
			return true;
		return GetCompressLen() == 0;
	}

	void Desotry()
	{
		if (FileData)
		{
			delete[] FileData;
			FileData = nullptr;
		}
		for (std::map<uint32, FCFile*>::iterator i = DirInfo.begin(); i != DirInfo.end(); i++)
			delete i->second;
		DirInfo.clear();
	}

	std::string FileDir = "";
	std::string FileName = "";
	int Index = 0;
	int ParentIndex = 0;
	char* FileData = nullptr;
	std::map<uint32, FCFile*> DirInfo;
};

class ZipReader
{
public:
	ZipReader(std::string Path)
	{
		RootPath = Path;
		ReadFiles();
	}
	~ZipReader() {}

	bool ReadFiles();
	bool ReadSingleFile(char* Buffer, uint32& RedPos, uint32 TotalLen, FCFile* rootFile);
	void ShowUp(FCFile* root, uint32 Pos);
	static std::string GetSpace(std::string printString, uint32 Pos);
	void ExecuteAll(std::string Path);
	void ExecuteFile(uint32 Index);
	void _executeFile(FCFile* file, std::string RootPath);
	FCFile* FindFile(uint32 Index, FCFile * file = nullptr);
private:
	FCFile RootFile;
	std::string RootPath;
};
