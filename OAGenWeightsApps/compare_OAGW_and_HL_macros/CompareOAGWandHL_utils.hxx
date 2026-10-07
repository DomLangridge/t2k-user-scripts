#include <iostream>
#include <sstream>
#include <cmath>

#include "TFile.h"
#include "TH1.h"
#include "TH2.h"
#include "TAxis.h"
#include "TTree.h"
#include "TMath.h"



// ============================== Relative Error ==============================

// ===== Fill TH2D relative error from OAGW cov matrix file =====
void FillRelativeError2D_FromOAGWCov(TH2D* &hist, TFile* file, int covMatrixOffset);


// ===== Fill TH2D relative error from HL analysis file =====
void FillRelativeError2D_FromHLAnalysis(TH2D* &hist, std::string fileName, int sampleEnum, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges);


// ===== Get TH2D relative error =====
TH2D* GetRelativeError2D(std::vector<std::string> fileList, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int sampleEnum=168, int covMatrixOffset=0);


// ===== Get TH1D projection of TH2D relative error =====
TH1D* GetRelativeErrorProjection(TH2D* hist_2d, Int_t nBins1D, Double_t* binEdges1D, std::string axis, std::string title);


// ============================== Event Rates ==============================

// ===== Fill TH2D event rates from OAGW spline file =====
void FillEvents2D_FromOAGWSpline(TH2D* &hist, TFile* file, int sampleEnum);


// ===== Fill TH2D event rates from OAGW cov matrix =====
void FillEvents2D_FromOAGWCov(TH2D* &hist, TFile* file, int covMatrixOffset); 


// ===== Fill TH2D event rates from HL analysis file =====
void FillEvents2D_FromHLAnalysis(TH2D* &hist, TFile* file, int sampleEnum);


// ===== Get TH2D event rates =====
TH2D* GetSpectra2D(std::vector<std::string> fileList, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int sampleEnum=168, int covMatrixOffset=0);


// ============================== Misc ==============================

void CheckBinContents2D(TH2D* hist, bool checkIntegral=false);