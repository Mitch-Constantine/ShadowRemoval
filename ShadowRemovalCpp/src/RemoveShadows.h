#ifndef REMOVE_SHADOWS_H_
#define REMOVE_SHADOWS_H_

#include <cxcore.h>

enum Algorithms
{
	Alg_ChromacityShadRem = 1,
	Alg_PhysicalShadRem = 2,
	Alg_GeometryShadRem = 3,
	Alg_SrTextureShadRem = 4,
	Alg_LrTextureShadRem = 5
};

#define Alg_First Alg_ChromacityShadRem
#define Alg_Last Alg_LrTextureShadRem

void removeShadows(
	Algorithms algorithm, const cv::Mat &frame, const cv::Mat &foreground, const cv::Mat &background, 
	cv::Mat &foregroundMask
);

#endif