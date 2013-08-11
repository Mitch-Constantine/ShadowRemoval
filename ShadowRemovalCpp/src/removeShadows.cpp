#include "ShadowRemover.h"
#include "ChromacityShadRem.h"
#include "GeometryShadRem.h"
#include "LrTextureShadRem.h"
#include "PhysicalShadRem.h"
#include "SrTextureShadRem.h"

#include "RemoveShadows.h"

ShadowRemover *getShadowRemover(Algorithms algorithm);

void removeShadows(Algorithms algorithm, const cv::Mat &frame, const cv::Mat &foreground, const cv::Mat &background, cv::Mat &foregroundMask)
{
	ShadowRemover *remover = getShadowRemover(algorithm);
	remover->removeShadows(frame, foreground, background, foregroundMask);
}

ChromacityShadRem chromacityShadRem;
PhysicalShadRem physicalShadRem;
GeometryShadRem geometryShadRem;
SrTextureShadRem srTextureShadRem;
LrTextureShadRem lrTextureShadRem;

ShadowRemover *shadowRemovers[] = {
	&chromacityShadRem,
	&physicalShadRem,
	&geometryShadRem,
	&srTextureShadRem,
	&lrTextureShadRem	
};

ShadowRemover *getShadowRemover(Algorithms algorithm)
{
	return shadowRemovers[algorithm-Alg_First];
}