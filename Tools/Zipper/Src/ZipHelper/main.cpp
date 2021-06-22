#include <iostream>
#include "ZipHelper.h"
#include "Zipper.h"

using namespace std;

int main(int argc, char *argv[])
{
    if (argc < 4)
    {
        printf("usage : [inputDir] [outputDir] [mode (compress/uncompress)]");
        return -1;
    }
	std::string inputDir = argv[1];
	std::string ouputDir = argv[2];
	std::string mode = argv[3];

	cout << "From : " 	<< inputDir.c_str() << endl;
	cout << "To : " 	<< ouputDir.c_str() << endl;
	cout << "Mode : " 	<< mode.c_str() << endl;

	if (mode == "compress")
		ZipHandler(inputDir.c_str()).ExecuteZip(ouputDir.c_str());
	else
	{
		ZipReader reader(inputDir.c_str());
		reader.ShowUp();
		reader.ExecuteAll(ouputDir.c_str());
	}
	cout << "successed" << endl;
	return 0;
}
