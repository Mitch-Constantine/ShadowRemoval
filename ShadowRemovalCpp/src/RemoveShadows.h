#ifndef REMOVE_SHADOWS_H_
#define REMOVE_SHADOWS_H_

enum Algorithms
{
	Alg_ChromacityShadRem = 1,
	Alg_PhysicalShadRem = 2,
	Alg_GeometryShadRem = 3,
	Alg_SrTextureShadRem = 4,
	Alg_LrTextureShadRem = 5
};

void removeShadows(cv::Mat frame, cv::Mat foreground, cv::Mat background, cv::Mat &foregroundMask, Algorithms algorithm);

#endif