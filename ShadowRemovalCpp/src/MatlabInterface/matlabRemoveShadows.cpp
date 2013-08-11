#include "math.h"
#include "matrix.h"
#include "mex.h"

#include "../removeShadows.h"

void extractInputParameters(
    int nrhs, const mxArray *prhs[], 
    Algorithms &algorithm, cv::Mat &frame, cv::Mat &fg, cv::Mat &bg
);
void setOutputParameter(const cv::Mat &fgMask, int nlhs, mxArray *plhs[]);

void extractEnumAlgorithm(const mxArray *matlabData, Algorithms &algorithm);
void extractColorImage(const mxArray *matlabData, cv::Mat &frame);
void extractImageMask(const mxArray *matlabData, cv::Mat &fg);
void returnImageMask(mxArray **matlabData, const cv::Mat &mask);

void check(bool condition, const char *errorMessage);
int linearIndex(int rows, int row, int column);
int linearIndex(int rows, int columns, int row, int column, int colorIndex);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    Algorithms algorithm;
    cv::Mat frame;
    cv::Mat fg;
    cv::Mat bg;

    extractInputParameters(nrhs, prhs, algorithm, frame, fg, bg);

    cv::Mat fgMask;
    removeShadows(algorithm, frame, fg, bg, fgMask);

    setOutputParameter(fgMask, nlhs, plhs);
}

void extractInputParameters(
    int nrhs, const mxArray *prhs[], 
    Algorithms &algorithm, cv::Mat &frame, cv::Mat &fg, cv::Mat &bg
)
{
    check(nrhs==4, "4 arguments required");

    extractEnumAlgorithm(prhs[0], algorithm);
    extractColorImage(prhs[1], frame);
    extractImageMask(prhs[2], fg);
    extractColorImage(prhs[3], bg);
}

void setOutputParameter(const cv::Mat &fgMask, int nlhs, mxArray *plhs[])
{
    check(nlhs==1 || nlhs ==0, "0 or 1 output arguments required");
    if (nlhs == 0)
        return;    
    returnImageMask(plhs, fgMask);
}

void extractEnumAlgorithm(const mxArray *matlabData, Algorithms &algorithm)
{
    check(mxIsNumeric(matlabData), "Numeric value expected for algorithm");
    double value = mxGetScalar(matlabData);
    value = round(value);
    check(value >= Alg_First && value <= Alg_Last, "Invalid algorithm selection");
    algorithm = (Algorithms)(int)value;
}

void extractColorImage(const mxArray *matlabData, cv::Mat &mat)
{
    const mwSize *sizes = mxGetDimensions(matlabData);
    mat = cv::Mat(sizes[0], sizes[1], CV_8UC3);

    unsigned char *pMatlabData = (unsigned char *)mxGetData(matlabData);

    for (int row = 0; row < mat.rows; row++)
    {
        unsigned char *pOpenCvRow = mat.ptr(row);
        for (int column = 0; column < mat.cols; column++)
        {
            for (int color = 0; color < 3; color ++)
            {
                int matlabLinearIndex = linearIndex(mat.rows, mat.cols, row, column, color);
                int openCvColorIndex = 3-color; // BGR vs RGB
                int openCvLinearIndex = 3 * column + openCvColorIndex;
                pOpenCvRow[openCvLinearIndex] = pMatlabData[matlabLinearIndex];
            }
        }
    }
}

void extractImageMask(const mxArray *matlabData, cv::Mat &mat)
{
    const mwSize *sizes = mxGetDimensions(matlabData);
    mat = cv::Mat(sizes[0], sizes[1], CV_8UC1);

    unsigned char *pData = (unsigned char *)mxGetData(matlabData);

    for (int row = 0; row < mat.rows; row++)
    {
        for (int column = 0; column < mat.cols; column++)
        {
            mat.at<unsigned char>(row, column) = pData[linearIndex(mat.rows, row, column)];
        }
    }
}

void returnImageMask(mxArray **matlabData, const cv::Mat &mat)
{
    *matlabData = mxCreateNumericMatrix(mat.rows, mat.cols, mxUINT8_CLASS, mxREAL);
    unsigned char *pData = (unsigned char *)mxGetData(*matlabData);

    for (int row = 0; row < mat.rows; row++)
    {
        for (int column = 0; column < mat.cols; column++)
        {
            pData[linearIndex(mat.rows, row, column)] = mat.at<unsigned char>(row, column);
        }
    }
}

int linearIndex(int rows, int row, int column)
{
	return column * rows + row;
}

int linearIndex(int rows, int columns, int row, int column, int colorIndex)
{
    return (column * rows + row) + rows*columns*colorIndex;
}

void check(bool condition, const char *errorMessage)
{
	if (!condition)
		mexErrMsgTxt(errorMessage);
}