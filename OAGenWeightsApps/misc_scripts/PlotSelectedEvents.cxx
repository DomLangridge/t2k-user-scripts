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
  
  sample_sum->SetBranchAddress("CosThetamu", &CosThetamu);
  sample_sum->SetBranchAddress("SelectedSample", &SelectedSample);
  sample_sum->SetBranchAddress("isConsecutiveIdenticalEvent", &isConsecutiveIdenticalEvent);
  sample_sum->SetBranchAddress("EventNumber", &EventNumber);

  // Get tree & branches for flattree
  TTree *flattree = (TTree *)inputFile->Get("flattree");

  Int_t Bunch;
  Int_t sNTrueVertices;

  flattree->SetBranchAddress("Bunch", &Bunch);
  flattree->SetBranchAddress("sNTrueVertices", &sNTrueVertices);

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

  // Open (hardcoded) output files
  TFile *outputFile = new TFile("SelectedEventPlots.root", "recreate");
  hist_All->SetDirectory(outputFile);
  hist_TPCmu->SetDirectory(outputFile);
  hist_HATmu->SetDirectory(outputFile);
  hist_SFGmu->SetDirectory(outputFile);

  ofstream eventPrint;
  eventPrint.open("SelectedEvents.out");

  // Loop over entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    selected = true;

    sample_sum->GetEntry(i);

    // Skip OB (out-of-bunch) entries
    if ( Bunch < 0 ) selected = false;

    // Skip entries flagged as 'isConsecutiveIdenticalEvent' unless the original entry was out of bunch
    if ( bool(isConsecutiveIdenticalEvent) == true ) {
      sample_sum->GetEntry(i-1);
      if (Bunch >= 0) selected = false;
      sample_sum->GetEntry(i);
    }

    // Print entry to .out file
    if (EventNumber != currentEvent) {
      if (currentEvent != -999) eventPrint << "Entries in event = " << entriesInEvent << std::endl;
      eventPrint << "============================== Event = " << EventNumber << " ==============================" << std::endl;
      currentEvent = EventNumber;
      entriesInEvent = 1;
    } else {
      entriesInEvent++;
    }
    eventPrint << "     Entry = " << i;
    eventPrint << "     Bunch = " << Bunch;
    eventPrint << "     nTrueVtx = " << sNTrueVertices;
    eventPrint << "     isCIE = " << bool(isConsecutiveIdenticalEvent);
    eventPrint << "     Sample = " << SelectedSample;
    if (selected) eventPrint << "     selected";
    eventPrint << std::endl;
    if (i == (sample_sum->GetEntries()-1)) eventPrint << "Entries in event = " << entriesInEvent << std::endl;

    // fill histograms if selected
    if (selected) {
      hist_All->Fill(CosThetamu);
      if ( SelectedSample == 168 ) hist_TPCmu->Fill(CosThetamu);
      if ( SelectedSample == 169 ) hist_HATmu->Fill(CosThetamu);
      if ( SelectedSample == 170 ) hist_SFGmu->Fill(CosThetamu);
    }

  }
  outputFile->Write();

  eventPrint.close();

}

int main() {
  PlotSelectedEvents();
  return 0;
}