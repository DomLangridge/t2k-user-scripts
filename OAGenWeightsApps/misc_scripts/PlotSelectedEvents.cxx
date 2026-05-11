#include <cstdlib>
#include <stdlib.h>

#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "TFile.h"
#include "TObjString.h"
#include "TTree.h"
#include "TMacro.h"

// DL: This script is for checking the selected events in OAGW spline files (i.e. outputs from makeND280SystSplines)
//     Most of this can be done simply with TTree::Draw(), but some selections may require applying cuts based on
//     later events, which I don't think can be done with this method? So I'm doing it here

void PlotSelectedEvents() {

  // Open (hardcoded) input file
  std::string inputFileName = "/home/dlangrid/scratch/Splines/UpgradeTests/HL5.9_SplineTest_makeND280SystSplinesOutput.root";
  TFile *inputFile = TFile::Open(inputFileName.c_str());

  // Get tree & branches for sample_sum
  TTree *sample_sum = (TTree *)inputFile->Get("sample_sum");

  Double_t CosThetamu;
  Int_t SelectedSample;
  Char_t isConsecutiveIdenticalEvent;

  sample_sum->SetBranchAddress("CosThetamu", &CosThetamu);
  sample_sum->SetBranchAddress("SelectedSample", &SelectedSample);
  sample_sum->SetBranchAddress("isConsecutiveIdenticalEvent", &isConsecutiveIdenticalEvent);

  // Get tree & branches for flattree
  TTree *flattree = (TTree *)inputFile->Get("flattree");

  Int_t Bunch;

  flattree->SetBranchAddress("Bunch", &Bunch);

  // Make them friends :)
  sample_sum->AddFriend("flattree");

  // Create Histograms
  TH1D *hist_All = new TH1D("hist_All", "AllSamples;", 100, -1, 1);
  TH1D *hist_TPCmu = new TH1D("hist_TPCmu", "TPCmu;CosThetamu;", 100, -1, 1);
  TH1D *hist_HATmu = new TH1D("hist_HATmu", "HATmu;CosThetamu;", 100, -1, 1);
  TH1D *hist_SFGmu = new TH1D("hist_SFGmu", "SFGmu;CosThetamu;", 100, -1, 1);

////////// TA selection method //////////

  // Open (hardcoded) output file
  TFile *outputFile_TA = new TFile("SelectedEventPlots_TA_selection.root", "recreate");
  hist_All->SetDirectory(outputFile_TA);
  hist_TPCmu->SetDirectory(outputFile_TA);
  hist_HATmu->SetDirectory(outputFile_TA);
  hist_SFGmu->SetDirectory(outputFile_TA);

  // Loop over entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    // // Skip entries where the following entry isn't flagged as 'isConsecutiveIdenticalEvent' (based on Tomochika's investigations)
    if ( i != (sample_sum->GetEntries()-1) ) {
      sample_sum->GetEntry(i+1);
      if ( isConsecutiveIdenticalEvent != 0 ) continue; // Doesn't this only skip the last entry in an event? Is that something we want to do?
    }

    sample_sum->GetEntry(i);

    // Skip OB (out-of-bunch) entries
    if ( Bunch < 0 ) continue;

    // fill histogram by sample
    hist_All->Fill(CosThetamu);
    if ( SelectedSample == 168 ) hist_TPCmu->Fill(CosThetamu);
    if ( SelectedSample == 169 ) hist_HATmu->Fill(CosThetamu);
    if ( SelectedSample == 170 ) hist_SFGmu->Fill(CosThetamu);

  }

  outputFile_TA->Write();
  outputFile_TA->Close();

/////////////////////////////////////////

  // Reset histograms

  hist_All = new TH1D("hist_All", "AllSamples;", 100, -1, 1);
  hist_TPCmu = new TH1D("hist_TPCmu", "TPCmu;CosThetamu;", 100, -1, 1);
  hist_HATmu = new TH1D("hist_HATmu", "HATmu;CosThetamu;", 100, -1, 1);
  hist_SFGmu = new TH1D("hist_SFGmu", "SFGmu;CosThetamu;", 100, -1, 1);

////////// DL selection method //////////

  // Open (hardcoded) output file
  TFile *outputFile_DL = new TFile("SelectedEventPlots_DL_selection.root", "recreate");
  hist_All->SetDirectory(outputFile_DL);
  hist_TPCmu->SetDirectory(outputFile_DL);
  hist_HATmu->SetDirectory(outputFile_DL);
  hist_SFGmu->SetDirectory(outputFile_DL);

  // Loop over entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    sample_sum->GetEntry(i);

    // Skip out-of-bunch events
    if ( Bunch < 0 ) continue;

    // Skip consecutive identical events, only if the original entry was in bunch
    if ( isConsecutiveIdenticalEvent == 0 ) {
      sample_sum->GetEntry(i-1);

      if ( Bunch >= 0 ) continue;

    }

    // fill histogram by sample
    hist_All->Fill(CosThetamu);
    if ( SelectedSample == 168 ) hist_TPCmu->Fill(CosThetamu);
    if ( SelectedSample == 169 ) hist_HATmu->Fill(CosThetamu);
    if ( SelectedSample == 170 ) hist_SFGmu->Fill(CosThetamu);

  }

  // Write histograms

  outputFile_DL->Write();
  outputFile_DL->Close();

/////////////////////////////////////////

}

int main() {
  PlotSelectedEvents();
  return 0;
}