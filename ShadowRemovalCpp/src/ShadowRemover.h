#ifndef SHADOW_REMOVER_H
#define SHADOW_REMOVER_H

#include <cxcore.h>

class ShadowRemover {

	public:
		virtual void removeShadows(const cv::Mat& frame, const cv::Mat& fg, const cv::Mat& bg, cv::Mat& srMask) = 0;
};

#endif