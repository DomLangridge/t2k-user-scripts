#include <fstream>
#include <iostream>
#include <string>

#include "TFile.h"
#include "TTree.h"

// DL: This script is for checking the selected events in OAGW spline files (i.e. outputs from makeND280SystSplines)
//     Most of this can be done simply with TTree::Draw(), but some selections may require applying cuts based on
//     later events, which I don't think can be done with this method? So I'm doing it here

void PlotSelectedEvents() {

  // Open (hardcoded) input files
  std::string OAGWinputFileName = "/home/dlangrid/scratch/Output_OAGenWeightsApps/UpgradeTests/HL5.16/AllFlatTrees/Output_combineND280Splines_HL5.16_500NMP.root";
  TFile *OAGWinputFile = TFile::Open(OAGWinputFileName.c_str());

  std::string HighLANDinputFileName = "/home/dlangrid/scratch/Output_OAGenWeightsApps/UpgradeTests/HL5.16/AllFlatTrees/Output_UpgradeNumuCCAnalysis_HL5.16.root";
  TFile *HighLANDinputFile = TFile::Open(HighLANDinputFileName.c_str());

  // Open (hardcoded) output file
  std::string eventPrintName = "CompareEvents.out";

  ofstream eventPrint;
  eventPrint.open(eventPrintName.c_str());

  // Get tree & branches for OAGW sample_sum
  TTree *sample_sum = (TTree *)OAGWinputFile->Get("sample_sum");

  Double_t SS_Pmu;
  Double_t SS_CosThetamu;
  Int_t SS_SelectedSample;
  Char_t SS_isConsecutiveIdenticalEvent;
  Int_t SS_EventNumber;
  Int_t SS_TruthVtx;
  Double_t SS_FluxWeight;
  Double_t SS_DetNomWeight;
  Double_t SS_XsecNomWeight;
  
  sample_sum->SetBranchAddress("Pmu", &SS_Pmu);
  sample_sum->SetBranchAddress("CosThetamu", &SS_CosThetamu);
  sample_sum->SetBranchAddress("SelectedSample", &SS_SelectedSample);
  sample_sum->SetBranchAddress("isConsecutiveIdenticalEvent", &SS_isConsecutiveIdenticalEvent);
  sample_sum->SetBranchAddress("EventNumber", &SS_EventNumber);
  sample_sum->SetBranchAddress("TruthVtx", &SS_TruthVtx);
  sample_sum->SetBranchAddress("FluxWeight", &SS_FluxWeight);
  sample_sum->SetBranchAddress("DetNomWeight", &SS_DetNomWeight);
  sample_sum->SetBranchAddress("XsecNomWeight", &SS_XsecNomWeight);

  // Get tree & branches for psyche flattree
  TTree *flattree = (TTree *)OAGWinputFile->Get("flattree");

  Int_t FT_Bunch;
  Int_t FT_sNTrueVertices;

  flattree->SetBranchAddress("Bunch", &FT_Bunch);
  flattree->SetBranchAddress("sNTrueVertices", &FT_sNTrueVertices);

  // Make them friends :)
  sample_sum->AddFriend("flattree");

  // Get tree & branches for HighLAND ana
  TTree *anaTree = (TTree *)HighLANDinputFile->Get("ana");

  Double_t AT_selmu_mom;
  Double_t AT_selmu_direction2;
  Int_t AT_evt;
  Int_t AT_entry;
  Int_t AT_sample;
  Int_t AT_bunch;
  Int_t AT_TruthVertexID;
  Int_t AT_accum_level;

  anaTree->SetBranchAddress("selmu_mom", &AT_selmu_mom);
  anaTree->SetBranchAddress("selmu_direction2", &AT_selmu_direction2);
  anaTree->SetBranchAddress("evt", &AT_evt);
  anaTree->SetBranchAddress("entry", &AT_entry);
  anaTree->SetBranchAddress("sample", &AT_sample);
  anaTree->SetBranchAddress("bunch", &AT_bunch);
  anaTree->SetBranchAddress("TruthVertexID", &AT_TruthVertexID);
  anaTree->SetBranchAddress("accum_level", &AT_accum_level);

  // Create array for unmatched events between HL & OAGW
  std::vector<int> Unmatched_OAGW;
  std::vector<int> Unmatched_HL;

  // Create any variables used in the loops
  bool selected;

  // Do some text file formatting
  eventPrint << "========== Unmatched events in OAGW file ==========" << std::endl;

  // Loop over OAGW entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    selected = true;

    sample_sum->GetEntry(i);

    // Skip entries flagged as 'isConsecutiveIdenticalEvent'
    if ( bool(SS_isConsecutiveIdenticalEvent) == true ) {
      selected = false;
    }

    // Try to find the same entry in the HL file (this is very inefficient and I hate it)
    if (selected = true) {
      bool matched = false;
      for (uint j=0; j<=anaTree->GetEntries(); j++) {
        anaTree->GetEntry(j);
        if ( (AT_evt == SS_EventNumber) && (AT_bunch = FT_Bunch) ) matched = true;
      }
      // If we didn't find it, print it
      if (!matched) {
        eventPrint << "Entry=" << i << ", Spill=" << SS_EventNumber << ", Bunch=" << FT_Bunch << ", Sample=" << SS_SelectedSample << std::endl;
      }
    }
  }

  // Do some more text file formatting
  eventPrint << std::endl;
  eventPrint << "=========== Unmatched events in HL file ===========" << std::endl;

  // Loop over HL entries
  for (uint i=0; i<anaTree->GetEntries(); i++) {

    selected = false;

    anaTree->GetEntry(i);

    // Only select entries with the correct accum_level
    if ( AT_accum_level >= 7 ) {
      selected = true;
    }

    // Try to find the same entry in the OAGW file (this is very inefficient and I hate it)
    if (selected = true) {
      bool matched = false;
      for (uint j=0; j<=sample_sum->GetEntries(); j++) {
        sample_sum->GetEntry(j);
        if ( (AT_evt == SS_EventNumber) && (AT_bunch = FT_Bunch) ) matched = true;
      }
      // If we didn't find it, print it
      if (!matched) {
        eventPrint << "Entry=" << i << ", Spill=" << AT_evt << ", Bunch=" << AT_bunch << ", Sample=" << AT_sample << std::endl;
      }
    }
  }

  eventPrint.close();

}

int main() {
  PlotSelectedEvents();
  return 0;
}