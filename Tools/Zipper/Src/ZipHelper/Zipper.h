#pragma once

#include <list>
#include <string>
#include <map>
#include "Core/zlib.h"

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

	bool FillData(char* buff, int& ReadPos)
	{
		bool ret = false;
		int* Buffer = (int*)&buff[ReadPos];
		int HeadLen = Buffer[0];
		int DataLen = Buffer[2];
		int TotalFileLen = HeadLen + DataLen;

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
	void Serialize(char* buff, int& Pos)
	{
		if (FileData)
		{
			char* start = &buff[Pos];
			memcpy(start, &FileData[0], GetFileSize());
			Pos += GetFileSize();
		}
		for (std::map<int, FCFile*>::iterator i = DirInfo.begin(); i != DirInfo.end(); i++)
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

	void GetTotalSize(int& TotalSize)
	{
		for (std::map<int, FCFile*>::iterator i = DirInfo.begin(); i != DirInfo.end(); i++)
			i->second->GetTotalSize(TotalSize);
		if (FileData)
			TotalSize += GetFileSize();
	}

	char* GetDataPointer()
	{
		if (FileData)
			return &FileData[GetHeadLen()];
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
			int NameLen = GetHeadLen() - sizeof(int) * 5;
			char* pointer = &FileData[sizeof(int) * 5];
			for (int i = 0; i < NameLen; i++)
				ret += pointer[i];
		}
		return ret;
	}

	int GetHeadLen()
	{
		return ((int*)FileData)[0];
	}

	int GetCompressLen()
	{
		return ((int*)FileData)[2];
	}

	int GetOriginFileLen()
	{
		return ((int*)FileData)[1];
	}

	int GetParentIndex()
	{
		return ((int*)FileData)[4];
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
		for (std::map<int, FCFile*>::iterator i = DirInfo.begin(); i != DirInfo.end(); i++)
			delete i->second;
		DirInfo.clear();
	}

	std::string FileDir = "";
	std::string FileName = "";
	int Index = 0;
	int ParentIndex = 0;
	char* FileData = nullptr;
	std::map<int, FCFile*> DirInfo;
};

class ZipHandler
{
public:
	ZipHandler(std::string RootPath) : RootPath(RootPath)
	{
		GeneratePath();
	}
	~ZipHandler() {}

	bool ExecuteZip(std::string Path = "", std::string FileName = "");
private:
	bool GeneratePath();
	bool FillFileData(const char* path, FCFile* CurrFile);
	void _GeneratePath(const std::string& Path, FCFile* RootFile, int& Index, int ParentIndex);
	FCFile RootFile;
	std::string RootPath;
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
	bool ReadSingleFile(char* Buffer, int& RedPos, int TotalLen, FCFile* rootFile);
	void ShowUp(FCFile* root = nullptr, int Pos = 0);
	static std::string GetSpace(std::string printString, int Pos);
	void ExecuteAll(std::string Path);
	void ExecuteFile(int Index);
	void _executeFile(FCFile* file, std::string RootPath);
	FCFile* FindFile(int Index, FCFile * file = nullptr);
private:
	FCFile RootFile;
	std::string RootPath;
};