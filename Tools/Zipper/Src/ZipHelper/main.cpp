#include <iostream>
#include "ZipHelper.h"
#include "Zipper.h"

using namespace std;

void main(int argc, char *argv[])
{
	system("pause");
	std::string inputDir = argv[1];
	std::string ouputDir = argv[2];
	ouputDir += "\\";
	std::string mode = "compress";
	if (argc == 4)
		mode = argv[3];


	cout << "From : " << inputDir.c_str() << endl;
	cout << "To : " << ouputDir.c_str() << endl;
	cout << "Mode : " << mode.c_str() << endl;

	if (mode == "compress")
		ZipHandler(inputDir.c_str()).ExecuteZip(ouputDir.c_str());
	else
	{
		ZipReader reader(inputDir.c_str());
		reader.ShowUp();
		reader.ExecuteAll(ouputDir.c_str());
	}

	system("pause");
}