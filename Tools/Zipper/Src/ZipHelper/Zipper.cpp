#include "Zipper.h"
#include <stdio.h>
#include <fstream>
#include <iostream>
#include <algorithm>

#ifdef WIN32
#include <Windows.h>
#include <direct.h> 
#include <io.h>
#else
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <dirent.h>
#endif

static bool BuildFileHead(char* Src, FCFile* File, int CompressLen, int OriginDataLen)
{
	int NameLen = strlen(File->FileName.c_str()) + 1;
	int HeadLen = NameLen + sizeof(int) * 5;
	char* Head = new char[HeadLen]();

	int* start = (int*)Head;
	//Insert HeadLen
	memcpy(start, &HeadLen, sizeof(int));
	start++;

	//Insert OriginLen
	memcpy(start, &OriginDataLen, sizeof(int));
	start++;

	//Insert CompressLen
	memcpy(start, &CompressLen, sizeof(int));
	start++;

	//Insert Index
	memcpy(start, &File->Index, sizeof(int));
	start++;

	//Insert ParentIndex
	memcpy(start, &File->ParentIndex, sizeof(int));
	start++;

	//Insert FileName
	memcpy(&Head[sizeof(int) * 5], File->FileName.c_str(), NameLen);

	char* FileData = new (std::nothrow) char[HeadLen + CompressLen]();
	File->FileData = FileData;

	memcpy(File->FileData, &Head[0], HeadLen);
	memcpy(&File->FileData[HeadLen], Src, CompressLen);

	delete[] Head;
	return true;
}
#ifdef WIN32
bool IsDir(WIN32_FIND_DATA& FileData)
{
	int i = FileData.dwFileAttributes;
	int isDir = i & FILE_ATTRIBUTE_DIRECTORY;
	return isDir != 0;
}

bool IsUper(WIN32_FIND_DATA& FileData)
{
	return FileData.cFileName[0] == '.';
}
#endif
bool isVaildDir(const char* fileName)
{
	return fileName[0] == '.';
}

bool ZipHandler::GeneratePath()
{
	RootFile.DirInfo.clear();
	std::string TempPath = RootPath;
	TempPath += "*.*";
	int index = 0;
#ifdef WIN32
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind = ::FindFirstFile(TempPath.c_str(), &FindFileData);
	if (INVALID_HANDLE_VALUE == hFind)
		return false;
#endif
	_GeneratePath(RootPath, &RootFile, index, 0);
	return true;
}

bool ZipHandler::FillFileData(const char* path, FCFile * CurrFile)
{
	bool Ret = true;
	
	ifstream FileOrigin(path, ios::binary);
	if (!FileOrigin)
	{
		FileOrigin.close();
		return false;
	}
	if (FileOrigin.bad())
	{
		printf("Bad File %s", path);
		return false;
	}
	int length = 0;
	FileOrigin.seekg(0, std::ios::end);
	length = FileOrigin.tellg();
	FileOrigin.seekg(0, std::ios::beg);
	char* buffer = new (std::nothrow)char[length]();
	if (!buffer)
	{
		FileOrigin.close();
		return false;
	}

	FileOrigin.read(buffer, length);
	FileOrigin.close();

	uLong tlen = length;
	uLong blen;


	blen = compressBound(tlen); 
	char* Compressed = new (std::nothrow) char[blen]();
	if (!Compressed)
	{
		delete[] buffer;
		return false;
	}

	if (compress((Bytef *)Compressed, &blen, (Bytef *)buffer, tlen) != Z_OK)
	{
		delete[] buffer;
		delete[] Compressed;
		return false;
	}

	if (!BuildFileHead(Compressed, CurrFile, blen, tlen))
	{
		delete[] Compressed;
		delete[] buffer;
		delete[] CurrFile->FileData;
		return false;
	}
	delete[] Compressed;
	delete[] buffer;
	return true;
}

std::string GetLastStr(std::string comp, std::string Compare)
{
	int i = 0;
	while (true)
	{
		i = comp.find(Compare);
		if (i == -1)
			break;
		comp = comp.substr(i + 1);
	}
	return comp;
}

bool ZipHandler::ExecuteZip(std::string Path, std::string FileName)
{
	if (Path.empty())
		Path = RootPath;
	if (FileName.empty())
	{
		FileName = GetLastStr(Path, "/");
		FileName = GetLastStr(FileName, "\\");
	}

	int TotalSize = 0;

	RootFile.GetTotalSize(TotalSize);

	if (!TotalSize)
		return false;

	char* ExecuteFileData = new (std::nothrow)char[TotalSize]();
	if (!ExecuteFileData)
		return false;

	int Pos = 0;
	RootFile.Serialize(ExecuteFileData, Pos);

	if (Pos != TotalSize)
	{
		delete[] ExecuteFileData;
		return false;
	}

    std::string CurrPath = Path + "/";// + FileName + ".FCZip";
#ifdef WIN32
#else
    mkdir(Path.c_str(), 0777);
#endif
    CurrPath = Path + "/" + FileName + ".FCZip";
    ofstream cppFile(CurrPath.c_str(), ios::binary);
	if (!cppFile)
	{
		delete[] ExecuteFileData;
		return false;
	}

	for (int i = 0; i < TotalSize; i++)
		cppFile << ExecuteFileData[i];
	cppFile.close();
	delete[] ExecuteFileData;
	return true;
}

#ifdef WIN32
void ZipHandler::_GeneratePath(const std::string& Path, FCFile* rootFile, int& Index, int ParentIndex)
{
	if (RootPath == "")
	{
		cout << "NO RootPath Seted" << endl;
		return;
	}
	std::string TempPath = Path + "//";
	TempPath += "*.*";
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind = ::FindFirstFile(TempPath.c_str(), &FindFileData);
	if (INVALID_HANDLE_VALUE == hFind)    
		return;

	while (true)
	{
		if (IsUper(FindFileData))
		{
			if (!FindNextFile(hFind, &FindFileData))
				break;
			continue;
		}

		FCFile * _FCFile = (std::nothrow)new FCFile();
		if (!_FCFile)
			return;
		Index++;
		_FCFile->Index = Index;
		_FCFile->ParentIndex = ParentIndex;
		_FCFile->FileDir = Path + "//";
		_FCFile->FileName = FindFileData.cFileName;
		std::string CurrFullPath = Path + "//" + _FCFile->FileName;
		if (IsDir(FindFileData))
		{
			_GeneratePath(CurrFullPath, _FCFile, Index, Index);
			BuildFileHead(nullptr, _FCFile, 0, 0);
		}
		else
			FillFileData(CurrFullPath.c_str(), _FCFile);

		rootFile->DirInfo[Index] = _FCFile;
		if (!FindNextFile(hFind, &FindFileData))
			break;
	}
	FindClose(hFind);
}
#else
bool isVailedFile(const char* pDirName)
{	
	return pDirName[0] != '.';
}

void ZipHandler::_GeneratePath(const std::string& Path, FCFile* rootFile, int& Index, int ParentIndex)
{
	DIR * dir = opendir(Path.c_str());
	while( dirent* dirp = readdir(dir) )
	{
		if (!isVailedFile(dirp->d_name))
			continue;
		FCFile * _FCFile = new FCFile();
		if (!_FCFile)
			return;
		Index++;
		_FCFile->Index = Index;
		_FCFile->ParentIndex = ParentIndex;
		_FCFile->FileDir = Path + "/";
		_FCFile->FileName = dirp->d_name;
		std::string CurrFullPath = Path + "/" + _FCFile->FileName;
		if (dirp->d_type == DT_DIR)
		{
			_GeneratePath(CurrFullPath, _FCFile, Index, Index);
			BuildFileHead(nullptr, _FCFile, 0, 0);
		}
		else
			FillFileData(CurrFullPath.c_str(), _FCFile);
        rootFile->DirInfo[Index] = _FCFile;
	}
}
#endif
bool ZipReader::ReadFiles()
{
	ifstream FileOrigin(RootPath, ios::binary);
	if (!FileOrigin)
		return false;
	
	int length = 0;
	FileOrigin.seekg(0, std::ios::end);
	length = FileOrigin.tellg();
	FileOrigin.seekg(0, std::ios::beg);
	char* buffer = new (std::nothrow)char[length]();
	if (!buffer)
	{
		FileOrigin.close();
		return false;
	}
	
	FileOrigin.read(buffer, length);
	FileOrigin.close();

	int ReadPos = 0;
	while (ReadSingleFile((char*)buffer, ReadPos, length, &RootFile));
	return true;
}

bool ZipReader::ReadSingleFile(char * Buffer, int& ReadPos, int FileTotalLen, FCFile* rootFile)
{
	if (ReadPos + sizeof(int) * 4 >= FileTotalLen)
		return false;

	int ParentIndex = ((int*)&Buffer[ReadPos])[4];
	if (ParentIndex != rootFile->Index)
		return false;

	FCFile* _FCFile = new FCFile();
	if (!_FCFile->FillData(Buffer, ReadPos) || !_FCFile->IsDataVaild())
	{
		for (int i = 0; i < ReadPos; i++)
			cout << _FCFile->FileData[i] << "|";
		delete _FCFile;
		return false;
	}

	rootFile->DirInfo[_FCFile->GetIndex()] = _FCFile;

	if (_FCFile->IsDir())
		while (ReadSingleFile(Buffer, ReadPos, FileTotalLen, _FCFile));
	return ReadPos < FileTotalLen;
}

void ZipReader::ShowUp(FCFile * root, int Pos)
{
	root = root ? root : &RootFile;
	std::string t = "";
	for (int i = 0; i < Pos; i++)
		t += "    ";
	if (!root->GetFileName().empty())
	{
		printf("%s==<Dir>==  %s Idx: %d  ==<Dir>==", t.c_str(), root->GetFileName().c_str(), root->GetIndex());
		printf("\n");
	}
	printf("%s{", t.c_str());
	printf("\n");

	for (std::map<int, FCFile*>::iterator i = root->DirInfo.begin(); i != root->DirInfo.end(); i++)
	{
		if (!i->second->IsDir())
		{
			char msg[100];
			snprintf(msg, 100, "%d", i->second->GetOriginFileLen());
			char CompressLen[100];
			snprintf(CompressLen, 100, "%d", i->second->GetCompressLen());
			char Index[100];
			snprintf(Index, 100, "%d", i->second->GetIndex());
			std::cout << t.c_str() << "    "
				<< i->second->GetFileName().c_str() << GetSpace(i->second->GetFileName(), 25)
				<< "Idx:" << Index << GetSpace(Index, 6)
				<< "OrigLen: "
				<< msg << GetSpace(msg, 12)
				<< "CompressLen: " << CompressLen << GetSpace(CompressLen, 12)
				<< "<File>" << std::endl;
		}
		else
			ShowUp(i->second, Pos + 1);
	}
	printf("%s}", t.c_str());
	printf("\n");
	return;
}

std::string ZipReader::GetSpace(std::string printString, int Pos)
{
	std::string space = "";
	int spaceCount = Pos;
	spaceCount -= printString.size();
	for (int i = 0; i < spaceCount; i++)
		space += " ";
	return space;
}

void ZipReader::ExecuteAll(std::string Path)
{
#ifndef WIN32
    mkdir(Path.c_str(), 0777);
#endif
	for (std::map<int, FCFile*>::iterator i = RootFile.DirInfo.begin(); i != RootFile.DirInfo.end(); i++)
		_executeFile(i->second, Path);
}

void ZipReader::ExecuteFile(int Index)
{
	FCFile* CurrFile = FindFile(Index);
	if (!CurrFile)
	{
		printf("No Such Index => %d", Index);
		return;
	}

	std::string Temp2 = RootPath;
	std::string TempPath = GetLastStr(RootPath, "/");
	TempPath = GetLastStr(TempPath, "\\");
	int pos = RootPath.find(TempPath);
	while (Temp2.size() != pos)
	{
		Temp2.erase(Temp2.size() - 1);
	}
	_executeFile(CurrFile, Temp2);
}

void ZipReader::_executeFile(FCFile * file, std::string RootPath)
{
	std::string CurrDir = RootPath + "/";
	if (file->IsDir())
	{
		CurrDir += file->GetFileName().c_str();
		#ifdef WIN32
		_mkdir(CurrDir.c_str());
		#else
		mkdir(CurrDir.c_str(), 0777);
		#endif
		for (std::map<int, FCFile*>::iterator i = file->DirInfo.begin(); i != file->DirInfo.end(); i++)
			_executeFile(i->second, CurrDir);
	}
	else
	{
		int OriginLen = file->GetOriginFileLen();
		int HeadLen = file->GetHeadLen();

		char* OriginFileData = new (std::nothrow)char[OriginLen]();
		if (!OriginFileData)
			return;

		uLong origin = OriginLen;
		if (uncompress((Bytef*)OriginFileData, &origin, (Bytef*)file->GetDataPointer(), file->GetCompressLen()) == Z_OK)
		{
			std::string CurrPath = RootPath + "/" + file->GetFileName();

			ofstream cppFile(CurrPath.c_str(), ios::binary);
			if (!cppFile)
				return;

			int count = 0;
			for (int i = 0; i < OriginLen; i++)
				cppFile << OriginFileData[i];
			cppFile.close();
		}
		delete[] OriginFileData;
	}
}

FCFile * ZipReader::FindFile(int Index, FCFile * file)
{
	if (!file)
		file = &RootFile;

	FCFile* CurrFile = nullptr;

	if (file->DirInfo.find(Index) != file->DirInfo.end())
		return file->DirInfo[Index];

	for (std::map<int, FCFile*>::iterator i = file->DirInfo.begin(); i != file->DirInfo.end(); i++)
	{
		if (i->second->IsDir())
		{
			CurrFile = FindFile(Index, i->second);
			if (CurrFile)
				break;
		}
	}
	return CurrFile;
}
