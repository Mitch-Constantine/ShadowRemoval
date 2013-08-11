// Copyright (C) 2011 NICTA (www.nicta.com.au)
// Copyright (C) 2011 Andres Sanin
//
// This file is provided without any warranty of fitness for any purpose.
// You can redistribute this file and/or modify it under the terms of
// the GNU General Public License (GPL) as published by the
// Free Software Foundation, either version 3 of the License
// or (at your option) any later version.
// (see http://www.opensource.org/licenses for more info)

#include <highgui.h>
#include <iostream>
#include "ChromacityShadRem.h"
#include "GeometryShadRem.h"
#include "LrTextureShadRem.h"
#include "PhysicalShadRem.h"
#include "SrTextureShadRem.h"

using namespace std;

int main() {
	// load frame, background and foreground
	cv::Mat frame = cv::imread("samples/frame.bmp");
	cv::Mat bg = cv::imread("samples/bg.bmp");
	cv::Mat fg = cv::imread("samples/fg.bmp", CV_LOAD_IMAGE_GRAYSCALE);

	// create shadow removers
	ChromacityShadRem chr;
	PhysicalShadRem phy;
	GeometryShadRem geo;
	SrTextureShadRem srTex;
	LrTextureShadRem lrTex;

	// matrices to store the masks after shadow removal
	cv::Mat chrMask, phyMask, geoMask, srTexMask, lrTexMask;

	// remove shadows
	chr.removeShadows(frame, fg, bg, chrMask);
	phy.removeShadows(frame, fg, bg, phyMask);
	geo.removeShadows(frame, fg, bg, geoMask);
	srTex.removeShadows(frame, fg, bg, srTexMask);
	lrTex.removeShadows(frame, fg, bg, lrTexMask);

	unsigned char min=255, max =0;
	for (int i = 0; i < fg.rows; i++)
	{
		for (int j = 0; j < fg.cols; j++)
		{
			unsigned char val = fg.at<unsigned char>(i,j);
			min = (min < val) ? min : val;
			max = (max > val) ? max : val;
		}
	}

	cout << (int)min << endl << (int)max << endl;
	/*cout << "Fg" << endl;
	cout << fg.type() << endl << fg.depth() << endl << fg.channels() << endl << fg.elemSize() << endl << fg.elemSize1() << endl;

	cout << "Frame" << endl;
	cout << frame.type() << endl << frame.depth() << endl << frame.channels() << endl << fg.elemSize() << endl << fg.elemSize1() << endl;	// show results
	*/
	/*cv::imshow("frame", frame);
	cv::imshow("bg", bg);
	cv::imshow("fg", fg);
	cv::imshow("chr", chrMask);
	cv::imshow("phy", phyMask);
	cv::imshow("geo", geoMask);
	cv::imshow("srTex", srTexMask);
	cv::imshow("lrTex", lrTexMask);

	cv::waitKey();
	*/
	return 0;
}
