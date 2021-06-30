#include "Zipper.h"
#include <fstream>
#include <iostream>
#include <algorithm>
#include "cocos2d.h"

FCFile* FCFile::CreateFromFile(std::string &path)
{
    FCFile* file = new (std::nothrow)FCFile();
    
    if (!file)
        return nullptr;
    
    if (!cocos2d::FileUtils::getInstance()->isFileExist(path.c_str()))
    {
        /* Report Error */
        return nullptr;
    }
    ifstream FileHolder(path.c_str(), ios::out | ios::binary);
    if (!FileHolder)
        return nullptr;
    
    FileHolder.seekg(0, std::ios::end);
    uint32 totalFileLength = FileHolder.tellg();
    
    uint32 ReadPos = 0;
    uint32 headerLen = 0;
    uint32 bodyLen = 0;
    
    while (ReadPos < totalFileLength)
    {
        FCFile* file = new (std::nothrow) FCFile;
        if (!file)
            break;
        
        if (ReadPos + 5 * sizeof(uint32) > totalFileLength)
            break;
        
        // read the header length of the single file buffer
        FileHolder.seekg(ReadPos, std::ios::beg);
        FileHolder.readsome((char*)&headerLen, sizeof(uint32));
        
        // length of the file body
        FileHolder.seekg(ReadPos + 2, std::ios::beg);
        FileHolder.readsome((char*)&bodyLen, sizeof(uint32));
        
        // now we got the start pos and the total size of the file,
        file->BufferSize = headerLen + bodyLen;
        file->StartPos = ReadPos;
        
    }
    
    return file;
}


bool FCFile::CreateFromData(ifstream fileHolder, uint32 ReadPos, uint32 length, FCFile* rootFile)
{
//    uint32 nameOffset = sizeof(uint32) * 5;
//    if (ReadPos + sizeof(uint32) * 4 >= length)
//        return false;
//
//    fileHolder.seekg(0, std::ios::end);
////    fileHolder.seekg(0, std::ios::beg);
//    // just read a headlen of next buffer
//    uint32 headerLen = 0;
//    fileHolder->readsome(&headerLen, sizeof(uint32));
//    uint32 ParentIndex = ((uint32*)&buffer[ReadPos])[4];
//    if (ParentIndex != rootFile->Index)
//        return false;
//
//    FCFile* _FCFile = new FCFile();
//    if (!_FCFile->FillData(buffer, ReadPos) || !_FCFile->IsDataVaild())
//    {
//        for (uint32 i = 0; i < ReadPos; i++)
//            cout << _FCFile->FileData[i] << "|";
//        delete _FCFile;
//        return false;
//    }
//
//    rootFile->DirInfo[_FCFile->GetIndex()] = _FCFile;
//
//    if (_FCFile->IsDir())
//        while (CreateFromData(buffer, ReadPos, length, rootFile));
//    return ReadPos < length;
    return true;
}

std::string GetLastStr(std::string comp, std::string Compare)
{
	uint32 i = 0;
	while (true)
	{
		i = comp.find(Compare);
		if (i == -1)
			break;
		comp = comp.substr(i + 1);
	}
	return comp;
}

bool ZipReader::ReadFiles()
{
	if (!cocos2d::FileUtils::getInstance()->isFileExist(RootPath))
	{
		/* Report Error */
		return false;
	}
	ifstream FileOrigin(RootPath, ios::out | ios::binary);
	if (!FileOrigin)
		return false;
	
	uint32 length = 0;
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

	uint32 ReadPos = 0;
	while (ReadSingleFile((char*)buffer, ReadPos, length, &RootFile));
	/*
		printf("Files:");
		printf("\n");
		ShowUp(&RootFile, 1);
		printf("{");
		printf("\n");
	*/
	delete buffer;
	return true;
}

bool ZipReader::ReadSingleFile(char * Buffer, uint32& ReadPos, uint32 FileTotalLen, FCFile* rootFile)
{
	if (ReadPos + sizeof(uint32) * 4 >= FileTotalLen)
		return false;

	uint32 ParentIndex = ((uint32*)&Buffer[ReadPos])[4];
	if (ParentIndex != rootFile->Index)
		return false;

	FCFile* _FCFile = new FCFile();
	if (!_FCFile->FillData(Buffer, ReadPos) || !_FCFile->IsDataVaild())
	{
		for (uint32 i = 0; i < ReadPos; i++)
			cout << _FCFile->FileData[i] << "|";
		delete _FCFile;
		return false;
	}

	rootFile->DirInfo[_FCFile->GetIndex()] = _FCFile;

	if (_FCFile->IsDir())
		while (ReadSingleFile(Buffer, ReadPos, FileTotalLen, _FCFile));
	return ReadPos < FileTotalLen;
}

void ZipReader::ShowUp(FCFile * root, uint32 Pos)
{
	
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

	for (std::map<uint32, FCFile*>::iterator i = root->DirInfo.begin(); i != root->DirInfo.end(); i++)
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

}

std::string ZipReader::GetSpace(std::string printString, uint32 Pos)
{
	std::string space = "";
	uint32 spaceCount = Pos;
	spaceCount -= printString.size();
	for (uint32 i = 0; i < spaceCount; i++)
		space += " ";
	return space;
}

void ZipReader::ExecuteAll(std::string Path)
{
	for (std::map<uint32, FCFile*>::iterator i = RootFile.DirInfo.begin(); i != RootFile.DirInfo.end(); i++)
		_executeFile(i->second, Path);
}

void ZipReader::_executeFile(FCFile * file, std::string RootPath)
{
	std::string CurrDir = RootPath + "/";
	if (file->IsDir())
	{
		CurrDir += file->GetFileName().c_str();
		cocos2d::FileUtils::getInstance()->createDirectory(CurrDir);
		for (std::map<uint32, FCFile*>::iterator i = file->DirInfo.begin(); i != file->DirInfo.end(); i++)
			_executeFile(i->second, CurrDir);
	}
	else
	{
		uint32 OriginLen = file->GetOriginFileLen();
		uint32 HeadLen = file->GetHeadLen();

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

			uint32 count = 0;
			for (uint32 i = 0; i < OriginLen; i++)
				cppFile << OriginFileData[i];
			cppFile.close();
		}
		delete[] OriginFileData;
	}
}

FCFile * ZipReader::FindFile(uint32 Index, FCFile * file)
{
	if (!file)
		file = &RootFile;

	FCFile* CurrFile = nullptr;

	if (file->DirInfo.find(Index) != file->DirInfo.end())
		return file->DirInfo[Index];

	for (std::map<uint32, FCFile*>::iterator i = file->DirInfo.begin(); i != file->DirInfo.end(); i++)
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
