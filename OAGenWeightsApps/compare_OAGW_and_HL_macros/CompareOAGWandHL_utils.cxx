// c++ includes
#include <iostream>
#include <sstream>
#include <cmath>

// ROOT includes
#include "TFile.h"
#include "TH1.h"
#include "TH2.h"
#include "TAxis.h"
#include "TTree.h"
#include "TMath.h"


// ============================== Misc ==============================

void CheckBinContents2D(TH2D* hist, bool checkIntegral=false) {
  std::cout << ">>>>> Bin Check <<<<<" << std::endl;

  for (int biny = hist->GetNbinsY(); biny > 0; biny--) {
    std::cout << biny << " {";

    for (int binx = 1; binx < hist->GetNbinsX()+1; binx++) {
      double contents;
      if (checkIntegral) { contents = hist->Integral(binx, binx, biny, biny); }
      else { contents = hist->GetBinContent(binx, biny); }
      std::cout << contents << ", ";
    } 

    std::cout << "}" << std::endl;
  }
}


// ============================== Event Rates ==============================

// ===== Fill TH2D event rates from OAGW spline file =====
void FillEvents2D_FromOAGWSpline(TH2D* &hist, TFile* file, int sampleEnum) {
  std::cout << ">>> Filling with events from sample_sum..." << std::endl;

  TTree* tree = (TTree*)file->Get("sample_sum");
  TTree* flattree = (TTree*)file->Get("flattree");

  Double_t mom, theta;
  Int_t sampleID, bunch;
  Char_t isCIE;

  tree->SetBranchStatus("*", false);
  tree->SetBranchStatus("Pmu", true);
  tree->SetBranchAddress("Pmu", &mom);
  tree->SetBranchStatus("CosThetamu", true);
  tree->SetBranchAddress("CosThetamu", &theta);
  tree->SetBranchStatus("SelectedSample", true);
  tree->SetBranchAddress("SelectedSample", &sampleID);
  tree->SetBranchStatus("isConsecutiveIdenticalEvent", true);
  tree->SetBranchAddress("isConsecutiveIdenticalEvent", &isCIE);

  flattree = (TTree*)file->Get("flattree");
  flattree->SetBranchStatus("*", false);
  flattree->SetBranchStatus("Bunch", true);
  flattree->SetBranchAddress("Bunch", &bunch);

  Long64_t nEntries = tree->GetEntries();
  for (Long64_t i = 0; i < nEntries; i++) {
     if ( i % (nEntries/10) == 0) std::cout << ">>> " << (i*100)/nEntries << "% (" << i << "/" << nEntries << ")" << std::endl;

    tree->GetEntry(i);
    flattree->GetEntry(i);

    if ( (sampleID == sampleEnum) && (bunch >= 0) && (isCIE==0) ) {
      hist->Fill(mom, theta);
    }
  }
}


// ===== Fill TH2D event rates from OAGW cov matrix =====
void FillEvents2D_FromOAGWCov(TH2D* &hist, TFile* file, int covMatrixOffset) {
  std::cout << ">>> Filling with events from number_events..." << std::endl;

  TH1D* nEvents = (TH1D*)file->Get("number_events");

  int binNumber = covMatrixOffset + 1; // For some reason event bins start from 2 :(

  for (int biny = 1; biny < hist->GetNbinsY()+1; biny++) {
    for (int binx = 1; binx < hist->GetNbinsX()+1; binx++) { 

      double events = nEvents->GetBinContent(binNumber);
      hist->SetBinContent(binx, biny, events);

      if (std::isnan(events)) {
        std::cout << "WARNING: bin (" << binx << ", " << biny << ") is undefined - setting to 0" << std::endl;
        hist->SetBinContent(binx, biny, 0);
      }

      binNumber++;

    }
  }
}


// ===== Fill TH2D event rates from HL analysis file =====
void FillEvents2D_FromHLAnalysis(TH2D* &hist, TFile* file, int sampleEnum) {
  std::cout << ">>> Filling with events from ana..." << std::endl;

  TTree* tree = (TTree*)file->Get("ana");

  Float_t mom, theta;
  Int_t sampleID, accum_level;

  tree->SetBranchStatus("*", false);
  tree->SetBranchStatus("selmu_mom", true);
  tree->SetBranchAddress("selmu_mom", &mom);
  tree->SetBranchStatus("selmu_direction2", true);
  tree->SetBranchAddress("selmu_direction2", &theta);
  tree->SetBranchStatus("sample", true);
  tree->SetBranchAddress("sample", &sampleID);
  tree->SetBranchStatus("accum_level", true);
  tree->SetBranchAddress("accum_level", &accum_level);

  Long64_t nEntries = tree->GetEntries();
  for (Long64_t i = 0; i < nEntries; i++) {
    if ( i % (nEntries/10) == 0) std::cout << ">>> " << (i*100)/nEntries << "% (" << i << "/" << nEntries << ")" << std::endl;

    tree->GetEntry(i);

    if (sampleID == sampleEnum) { // DL: accum_level is accounted for in selected sample
      hist->Fill(mom, theta);
    }
  }
}


// ===== Get TH2D event rates (multiple files) =====
TH2D* GetSpectra2D(std::vector<std::string> fileList, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int sampleEnum=168, int covMatrixOffset=0) {

  // Create Histogram
  TH2D* hist = new TH2D("","", momNBins, momBinEdges, thetaNBins, thetaBinEdges);

  bool printBinCheck = false;

  // Loop over files
  for (std::string fileName : fileList) {
    std::string fileType = "";

    std::cout << ">> Opening file: " << fileName.c_str() << std::endl;
    TFile* file = TFile::Open(fileName.c_str());

    // Check if OAGW spline file
    if ((TTree*)file->Get("sample_sum")) {
      std::cout << ">> TTree 'sample_sum' exists: this must be an OAGenWeightsApps spline file!" << std::endl;
      FillEvents2D_FromOAGWSpline(hist, file, sampleEnum);

    // Check if OAGW cov matrix file
    } else if ((TH1D*)file->Get("number_events")) {
      std::cout << ">> TH1D 'number_events' exists: this must be an OAGenWeightsApps cov matrix file!" << std::endl;
      FillEvents2D_FromOAGWCov(hist, file, covMatrixOffset);

    // Check if HL file
    } else if ((TTree*)file->Get("ana")) {
      std::cout << ">> TTree 'ana' exists: this must be a HighLAND file!" << std::endl;
      FillEvents2D_FromHLAnalysis(hist, file, sampleEnum);

    } else {
      std::cout << "ERROR: neither 'sample_sum' or 'ana' were found - are you sure this is the right file?" << std::endl;
      std::cout << ">> Exiting..." << std::endl;
      throw;
    }
  }

  // Check for empty bins
  if (printBinCheck) CheckBinContents2D(hist, true);

  return hist;

}

// ===== Get TH2D event rates (single file) =====
TH2D* GetSpectra2D(std::string fileName, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int sampleEnum=168, int covMatrixOffset=0) {
 
  // Standard GetSpectra2D expects a list of files, so lets make one
  std::vector<std::string> fileList = {fileName};

  return GetSpectra2D(fileList, momNBins, momBinEdges, thetaNBins, thetaBinEdges, sampleEnum, covMatrixOffset);

}


// ============================== Relative Error ==============================

// ===== Fill TH2D relative error from OAGW cov matrix file =====
TH2D* GetRelativeError2D_FromOAGWCov(TFile* file, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int covMatrixOffset) {
  std::cout << ">>> Getting relative error from Covariance_Matrix_NoMCStats..." << std::endl;

  TH2D* hist = new TH2D("","", momNBins, momBinEdges, thetaNBins, thetaBinEdges);

  // Get cov matrix
  TH2D* covMatrix = (TH2D*)file->Get("Covariance_Matrix_NoMCStats");

  // Get event distribution
  // TH2D* nEvents = new TH2D("","", momNBins, momBinEdges, thetaNBins, thetaBinEdges);
  // FillEvents2D_FromOAGWCov(nEvents, file, covMatrixOffset);

  int binNumber = covMatrixOffset;

  for (int biny = 1; biny < hist->GetNbinsY()+1; biny++) {
    for (int binx = 1; binx < hist->GetNbinsX()+1; binx++) {
      
      // check if cov matrix bin exists
      if (binNumber > covMatrix->GetNbinsX()) {
        std::cout << "ERROR: binNumber " << binNumber << " is greater than maximum bins in cov matrix axis (" << covMatrix->GetNbinsX() << ")" << std::endl;
        std::cout << "Exiting..." << std::endl;
        throw;
      }

      double relativeError = covMatrix->GetBinContent(binNumber, binNumber);
      hist->SetBinContent(binx, biny, relativeError);
      
      if (std::isnan(relativeError)) {
        std::cout << "WARNING: bin (" << binx << ", " << biny << ") is undefined - setting to 0" << std::endl;
        hist->SetBinContent(binx, biny, 0);
      }

      binNumber++;

    }
  }

  return hist;
}


// ===== Fill TH2D relative error from HL analysis file =====
TH2D* GetRelativeError2D_FromHLAnalysis(std::string fileName, int sampleEnum, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges) {
  std::cout << ">>> Getting relative error with HighLAND DrawingTools..." << std::endl;

  TH2D* hist = new TH2D("","", momNBins, momBinEdges, thetaNBins, thetaBinEdges);

  // Initialise DrawingTools and Experiment
  DrawingTools* draw = new DrawingTools(fileName.c_str());
  DataSample* mc = new DataSample(fileName.c_str());

  Experiment exper("nd280");
  SampleGroup run13("run13");
  run13.AddMCSample("magnet", mc);
  run13.AddDataSample(mc);
  exper.AddSampleGroup("run13", run13);

  // DL: this is hacky, but for SFG CC inclusive sample 168 is branch 0, 169 is 1, 170 is 2, so this works
  int accumBranchIndex = sampleEnum - 168;

  // ----- Method 1: loop over costheta slices -----
  std::cout << "Relative Error (HL): " << std::endl;
  for (int slice = 1; slice < thetaNBins+1; slice++) {

    // define accum_level and theta cuts
    std::ostringstream ss_accum, ss_thetaMin, ss_thetaMax;
    ss_accum << accumBranchIndex;
    ss_thetaMin << thetaBinEdges[slice-1];
    ss_thetaMax << thetaBinEdges[slice];
    
    std::string accumLevelCut = "accum_level[][" + ss_accum.str() + "]>=7";

    std::string thetaCut = "selmu_direction2>=" + ss_thetaMin.str() + " && selmu_direction2<" + ss_thetaMax.str();

    // draw 1D relative errors in that bin
    std::cout << "> Getting mom bin relative errors for theta slice (" << ss_thetaMin.str() << ", " << ss_thetaMax.str() << ")" << std::endl;
    draw->DrawRelativeErrors(exper, "selmu_mom", momNBins, momBinEdges, accumLevelCut+"&&"+thetaCut);

    // get 1D histogram
    TH1D* histSlice = (TH1D*)draw->GetLastHisto();

    // add to 2D hist
    std::cout << "  {";
    for (int bin = 1; bin < histSlice->GetNbinsX()+1; bin++) {
      hist->SetBinContent(bin, slice, histSlice->GetBinContent(bin));
      std::cout << histSlice->GetBinContent(bin) << ", ";
    }
    std::cout << "}" << std::endl;

  }

  return hist;
}


// ===== Get TH2D relative error =====
TH2D* GetRelativeError2D(std::string fileName, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int sampleEnum=168, int covMatrixOffset=0) {

  // Create Histogram
  TH2D* hist;
  std::string fileType = "";

  std::cout << ">> Opening file: " << fileName.c_str() << std::endl;
  TFile* file = TFile::Open(fileName.c_str());

  // Check file type
  if ((TH2D*)file->Get("Covariance_Matrix_NoMCStats")) {
    std::cout << ">> TH2D 'Covariance_Matrix_NoMCStats' exists: this must be an OAGenWeightsApps file!" << std::endl;
    hist = GetRelativeError2D_FromOAGWCov(file, momNBins, momBinEdges, thetaNBins, thetaBinEdges, covMatrixOffset);

  } else if ((TTree*)file->Get("all_syst")) {
    std::cout << ">> TTree 'all_syst' exists: this must be a HighLAND file!" << std::endl;
    hist = GetRelativeError2D_FromHLAnalysis(fileName, sampleEnum, momNBins, momBinEdges, thetaNBins, thetaBinEdges);

  } else {
    std::cout << "ERROR: neither 'MC_Sys_Error' or 'all_syst' were found - are you sure this is the right file?" << std::endl;
    std::cout << ">> Exiting..." << std::endl;
    throw;
  }

  return hist;
}


// ===== Get TH1D projection of TH2D relative error =====
TH1D* GetRelativeErrorProjection(TH2D* hist_2d, TH2D* hist_2dEvents, Int_t nBins1D, Double_t* binEdges1D, std::string axis, std::string title="") {
  std::cout << ">> Getting " << axis << " projection..." << std::endl;

  // Check chosen axis of projection isn't nonsense
  if (axis != "x" && axis != "y") {
    std::cout << "ERROR: You have selected a 2D to 1D projection axis that isn't x or y - I can't believe you've done this" << std::endl;
    throw;
  }

  // Create Histogram
  TH1D* hist_1d = new TH1D(title.c_str(), title.c_str(), nBins1D, binEdges1D);

  // Fill 1D projection
  for (int binProj = 1; binProj < hist_1d->GetNbinsX()+1; binProj++) {
    double absVarTotal = 0;
    double nEventsTotal = 0;

    if (axis == "x") {
      for (int binSlice = 1; binSlice < hist_2d->GetNbinsY()+1; binSlice++) {
        double absError = hist_2d->GetBinContent(binProj, binSlice) * hist_2dEvents->Integral(binProj, binProj, binSlice, binSlice); // absError = relError x nEvents
        absVarTotal += TMath::Power(absError, 2); // absVar = (absError)^2
      }
      nEventsTotal = hist_2dEvents->Integral(binProj, binProj, 1, hist_2dEvents->GetNbinsY()); // Get total events in slice

    } else if (axis == "y") {
      for (int binSlice = 1; binSlice < hist_2d->GetNbinsX()+1; binSlice++) {
        double absError = hist_2d->GetBinContent(binSlice, binProj) * hist_2dEvents->Integral(binSlice, binSlice, binProj, binProj); // absError = relError x nEvents
        absVarTotal += TMath::Power(absError, 2); // absVar = (absError)^2
      }
      nEventsTotal = hist_2dEvents->Integral(1, hist_2dEvents->GetNbinsX(), binProj, binProj); // Get total events in slice

    }

    hist_1d->SetBinContent(binProj, TMath::Sqrt(absVarTotal) / nEventsTotal); // Convert back to relative error
  }

  return hist_1d;
}


// ===== Fill TH1D relative error from HL analysis file =====
TH1D* GetRelativeError1D_FromHLAnalysis(std::string fileName, int sampleEnum, std::string var, Int_t nBins, Double_t* binEdges) {
  std::cout << ">>> Getting relative error with HighLAND DrawingTools..." << std::endl;

  // Initialise DrawingTools and Experiment
  DrawingTools* draw = new DrawingTools(fileName.c_str());
  DataSample* mc = new DataSample(fileName.c_str());

  Experiment exper("nd280");
  SampleGroup run13("run13");
  run13.AddMCSample("magnet", mc);
  run13.AddDataSample(mc);
  exper.AddSampleGroup("run13", run13);

  // DL: this is hacky, but for SFG CC inclusive sample 168 is branch 0, 169 is 1, 170 is 2, so this works
  int accumBranchIndex = sampleEnum - 168;

  // define accum_level and theta cuts
  std::ostringstream ss_accum;
  ss_accum << accumBranchIndex;

  std::string accumLevelCut = "accum_level[][" + ss_accum.str() + "]>=7";

  // draw 1D relative errors
  std::cout << ">>> Getting relative errors in " << var << std::endl;
  draw->DrawRelativeErrors(exper, var, nBins, binEdges, accumLevelCut);

  // get 1D histogram
  TH1D* hist = (TH1D*)draw->GetLastHisto();

  return hist;

}


// ===== Get TH1D relative error (only works for HL analysis files) =====
// DL: Since we only do it for one file now this is kinda redundant
//     Guess it's still a good idea to check the file is the right type
TH1D* GetRelativeError1D(std::string fileName, Int_t nBins, Double_t* binEdges, std::string var, int sampleEnum=168) {

  // Create Histogram
  TH1D* hist;
  std::string fileType = "";

  std::cout << ">> Opening file: " << fileName.c_str() << std::endl;
  TFile* file = TFile::Open(fileName.c_str());

  TH1D* tempHist;

  // Get relative error for a file
  if ((TTree*)file->Get("all_syst")) {
    std::cout << ">> TTree 'all_syst' exists: this must be a HighLAND file!" << std::endl;
    if (var == "x") var = "selmu_mom";
    else if (var == "y") var = "selmu_direction2";
    hist = GetRelativeError1D_FromHLAnalysis(fileName, sampleEnum, var, nBins, binEdges);

  } else {
    std::cout << "ERROR: 'all_syst' was not found - this method only works on HL analysis files" << std::endl;
    std::cout << ">> Exiting..." << std::endl;
    throw;
  }

  return hist;

}