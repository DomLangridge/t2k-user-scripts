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
  Int_t EventNumber;
  Char_t HaveTruth;

  sample_sum->SetBranchAddress("CosThetamu", &CosThetamu);
  sample_sum->SetBranchAddress("SelectedSample", &SelectedSample);
  sample_sum->SetBranchAddress("isConsecutiveIdenticalEvent", &isConsecutiveIdenticalEvent);
  sample_sum->SetBranchAddress("EventNumber", &EventNumber);
  sample_sum->SetBranchAddress("HaveTruth", &HaveTruth);

  // Get tree & branches for flattree
  TTree *flattree = (TTree *)inputFile->Get("flattree");

  Int_t Bunch;

  flattree->SetBranchAddress("Bunch", &Bunch);

  // Make them friends :)
  sample_sum->AddFriend("flattree");

  // Create any variables used in the loops
  bool selected;
  int currentEvent = -999;
  int entriesInEvent = 0;

  // Create Histograms
  TH1D *hist_All = new TH1D("hist_All", "AllSamples;", 100, -1, 1);
  TH1D *hist_TPCmu = new TH1D("hist_TPCmu", "TPCmu;CosThetamu;", 100, -1, 1);
  TH1D *hist_HATmu = new TH1D("hist_HATmu", "HATmu;CosThetamu;", 100, -1, 1);
  TH1D *hist_SFGmu = new TH1D("hist_SFGmu", "SFGmu;CosThetamu;", 100, -1, 1);

////////// TA selection method //////////

  // Open (hardcoded) output files
  TFile *outputFile_TA = new TFile("SelectedEventPlots_TA_selection.root", "recreate");
  hist_All->SetDirectory(outputFile_TA);
  hist_TPCmu->SetDirectory(outputFile_TA);
  hist_HATmu->SetDirectory(outputFile_TA);
  hist_SFGmu->SetDirectory(outputFile_TA);

  ofstream eventPrint_TA;
  eventPrint_TA.open("SelectedEvents_TA_selection.out");

  // Loop over entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    selected = true;

    // Only select entries where the following entry is flagged as 'isConsecutiveIdenticalEvent == 0' (false) - based on Tomochika's investigations
    if ( i != (sample_sum->GetEntries()-1) ) {
      sample_sum->GetEntry(i+1);
      if ( bool(isConsecutiveIdenticalEvent) != 0 ) selected = false; // This looks like it only ever skips the first entry then
    }

    sample_sum->GetEntry(i);

    // Skip OB (out-of-bunch) entries
    if ( Bunch < 0 ) selected = false;

    // Print entry to .out file
    if (EventNumber != currentEvent) {
      if (currentEvent != -999) eventPrint_TA << "Entries in event = " << entriesInEvent << std::endl;
      eventPrint_TA << "============================== Event = " << EventNumber << " ==============================" << std::endl;
      currentEvent = EventNumber;
      entriesInEvent = 1;
    } else {
      entriesInEvent++;
    }
    eventPrint_TA << "     Entry = " << i;
    eventPrint_TA << "     Bunch = " << Bunch;
    eventPrint_TA << "     Truth = " << bool(HaveTruth);
    eventPrint_TA << "     isCIE = " << bool(isConsecutiveIdenticalEvent);
    eventPrint_TA << "     Sample = " << SelectedSample;
    if (selected) eventPrint_TA << "     selected";
    eventPrint_TA << std::endl;
    if (i == (sample_sum->GetEntries()-1)) eventPrint_TA << "Entries in event = " << entriesInEvent << std::endl;

    // fill histograms if selected
    if (selected) {
      hist_All->Fill(CosThetamu);
      if ( SelectedSample == 168 ) hist_TPCmu->Fill(CosThetamu);
      if ( SelectedSample == 169 ) hist_HATmu->Fill(CosThetamu);
      if ( SelectedSample == 170 ) hist_SFGmu->Fill(CosThetamu);
    }

  }

  outputFile_TA->Write();
  outputFile_TA->Close();

  eventPrint_TA.close();

/////////////////////////////////////////

  // Reset histograms and variables

  hist_All = new TH1D("hist_All", "AllSamples;", 100, -1, 1);
  hist_TPCmu = new TH1D("hist_TPCmu", "TPCmu;CosThetamu;", 100, -1, 1);
  hist_HATmu = new TH1D("hist_HATmu", "HATmu;CosThetamu;", 100, -1, 1);
  hist_SFGmu = new TH1D("hist_SFGmu", "SFGmu;CosThetamu;", 100, -1, 1);

  currentEvent = -999;
  entriesInEvent = 0;

////////// DL selection method //////////

  // Open (hardcoded) output file
  TFile *outputFile_DL = new TFile("SelectedEventPlots_DL_selection.root", "recreate");
  hist_All->SetDirectory(outputFile_DL);
  hist_TPCmu->SetDirectory(outputFile_DL);
  hist_HATmu->SetDirectory(outputFile_DL);
  hist_SFGmu->SetDirectory(outputFile_DL);

  ofstream eventPrint_DL;
  eventPrint_DL.open("SelectedEvents_DL_selection.out");

  // Loop over entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    selected = true;

    sample_sum->GetEntry(i);

    // Skip out-of-bunch events
    if ( Bunch < 0 ) selected = false;

    // Skip consecutive identical events, only if the previous entry was in bunch
    if ( bool(isConsecutiveIdenticalEvent) == true ) {
      sample_sum->GetEntry(i-1);
      if ( Bunch >= 0 ) selected = false;
      sample_sum->GetEntry(i);
    }

    // Print entry to .out file
    if (EventNumber != currentEvent) {
      if (currentEvent != -999) eventPrint_DL << "Entries in event = " << entriesInEvent << std::endl;
      eventPrint_DL << "============================== Event = " << EventNumber << " ==============================" << std::endl;
      currentEvent = EventNumber;
      entriesInEvent = 1;
    } else {
      entriesInEvent++;
    }
    eventPrint_DL << "     Entry = " << i;
    eventPrint_DL << "     Bunch = " << Bunch;
    eventPrint_DL << "     Truth = " << bool(HaveTruth);
    eventPrint_DL << "     isCIE = " << bool(isConsecutiveIdenticalEvent);
    eventPrint_DL << "     Sample = " << SelectedSample;
    if (selected) eventPrint_DL << "     selected";
    eventPrint_DL << std::endl;
    if (i == (sample_sum->GetEntries()-1)) eventPrint_TA << "Entries in event = " << entriesInEvent << std::endl;

    // fill histograms if selected
    if (selected) {
      hist_All->Fill(CosThetamu);
      if ( SelectedSample == 168 ) hist_TPCmu->Fill(CosThetamu);
      if ( SelectedSample == 169 ) hist_HATmu->Fill(CosThetamu);
      if ( SelectedSample == 170 ) hist_SFGmu->Fill(CosThetamu);
    }

  }

  // Write histograms

  outputFile_DL->Write();
  outputFile_DL->Close();

  eventPrint_DL.close();

/////////////////////////////////////////

}

int main() {
  PlotSelectedEvents();
  return 0;
}