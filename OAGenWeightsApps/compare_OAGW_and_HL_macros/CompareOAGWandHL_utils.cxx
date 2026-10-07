#include "CompareOAGWandHL_utils.hxx"


// ============================== Relative Error ==============================

// ===== Fill TH2D relative error from OAGW cov matrix file =====
void FillRelativeError2D_FromOAGWCov(TH2D* &hist, TFile* file, int covMatrixOffset) {
  std::cout << ">>> Filling with relative error from MC_Sys_Error..." << std::endl;

  TH1D* sysError = (TH1D*)file->Get("MC_Sys_Error");

  int binNumber = covMatrixOffset;

  for (int biny = 1; biny < hist->GetNbinsY()+1; biny++) {
    for (int binx = 1; binx < hist->GetNbinsX()+1; binx++) { 

      double relativeError = TMath::Sqrt( sysError->GetBinContent(binNumber) );
      hist->SetBinContent(binx, biny, relativeError);

      if (std::isnan(relativeError)) {
        std::cout << "WARNING: bin (" << binx << ", " << biny << ") is undefined - setting to 0" << std::endl;
        hist->SetBinContent(binx, biny, 0);
      }

      binNumber++;

    }
  }
}


// ===== Fill TH2D relative error from HL analysis file =====
void FillRelativeError2D_FromHLAnalysis(TH2D* &hist, std::string fileName, int sampleEnum, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges) {
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

  // loop over costheta slices
  for (int slice = 0; slice < thetaNBins; slice++) {

    // define accum_level and theta cuts
    std::ostringstream ss_accum, ss_thetaMin, ss_thetaMax;
    ss_accum << accumBranchIndex;
    ss_thetaMin << thetaBinEdges[slice];
    ss_thetaMax << thetaBinEdges[slice+1];
    
    std::string accumLevelCut = "accum_level[][" + ss_accum.str() + "]>=7";

    std::string thetaCut = "selmu_direction2>=" + ss_thetaMin.str() + " && selmu_direction2<" + ss_thetaMax.str();

    // draw 1D relative errors in that bin
    std::cout << "> Getting mom bin relative errors for theta slice (" << ss_thetaMin.str() << ", " << ss_thetaMax.str() << ")" << std::endl;
    draw->DrawRelativeErrors(exper, "selmu_mom", momNBins, momBinEdges, accumLevelCut+"&&"+thetaCut);

    // get 1D histogram
    TH1D* histSlice = (TH1D*)draw->GetLastHisto();

    // add to 2D hist
    for (int ibin = 1; ibin < histSlice->GetNbinsX()+1; ibin++) {
      hist->SetBinContent(ibin, slice+1, histSlice->GetBinContent(ibin));
    }

  }
}


// ===== Get TH2D relative error =====
TH2D* GetRelativeError2D(std::vector<std::string> fileList, Int_t momNBins, Double_t* momBinEdges, Int_t thetaNBins, Double_t* thetaBinEdges, int sampleEnum=168, int covMatrixOffset=0) {

  // Create Histogram
  TH2D* hist = new TH2D("","", momNBins, momBinEdges, thetaNBins, thetaBinEdges);

  // Loop over files
  for (std::string fileName : fileList) {
    std::string fileType = "";

    std::cout << ">> Opening file: " << fileName.c_str() << std::endl;
    TFile* file = TFile::Open(fileName.c_str());

    // Check file type
    if ((TH1D*)file->Get("MC_Sys_Error")) {
      std::cout << ">> TH1D 'MC_Sys_Error' exists: this must be an OAGenWeightsApps file!" << std::endl;
      FillRelativeError2D_FromOAGWCov(hist, file, covMatrixOffset);

    } else if ((TTree*)file->Get("all_syst")) {
      std::cout << ">> TTree 'all_syst' exists: this must be a HighLAND file!" << std::endl;
      FillRelativeError2D_FromHLAnalysis(hist, fileName, sampleEnum, momNBins, momBinEdges, thetaNBins, thetaBinEdges);
    } else {
      std::cout << "ERROR: neither 'MC_Sys_Error' or 'all_syst' were found - are you sure this is the right file?" << std::endl;
      std::cout << ">> Exiting..." << std::endl;
      throw;
    }
  }

  return hist;

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

  int binNumber = covMatrixOffset;

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


// ===== Get TH2D event rates =====
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