#include <fstream>
#include <iostream>
#include <string>

#include "TFile.h"
#include "TTree.h"

// DL: This script is an incredibly slow script for comparing event rates between OAGW and HighLAND outputs
//     I hate it beyond measure

void CompareSelectedEvents() {

  // Open (hardcoded) input files
  std::string OAGWinputFileName = "/Users/dominiclangridge/T2K/OA_ND_Upgrade/Spline_Validation/HL5.16/AllFlatTrees/Output_combineND280Splines_HL5.16_500NMP.root";
  TFile *OAGWinputFile = TFile::Open(OAGWinputFileName.c_str());

  std::string HighLANDinputFileName = "/Users/dominiclangridge/T2K/OA_ND_Upgrade/Spline_Validation/HL5.16/AllFlatTrees/Output_UpgradeNumuCCAnalysis_HL5.16.root";
  TFile *HighLANDinputFile = TFile::Open(HighLANDinputFileName.c_str());

  // Open (hardcoded) output file
  std::string eventPrintName = "CompareEvents.out";

  ofstream eventPrint;
  eventPrint.open(eventPrintName.c_str());

  // Get tree & branches for OAGW sample_sum
  TTree *sample_sum = (TTree *)OAGWinputFile->Get("sample_sum");

  Int_t SS_SelectedSample;
  Char_t SS_isConsecutiveIdenticalEvent;
  Int_t SS_EventNumber;
  
  sample_sum->SetBranchAddress("SelectedSample", &SS_SelectedSample);
  sample_sum->SetBranchAddress("isConsecutiveIdenticalEvent", &SS_isConsecutiveIdenticalEvent);
  sample_sum->SetBranchAddress("EventNumber", &SS_EventNumber);

  // Get tree & branches for psyche flattree
  TTree *flattree = (TTree *)OAGWinputFile->Get("flattree");

  Int_t FT_Bunch;

  flattree->SetBranchAddress("Bunch", &FT_Bunch);

  // Make them friends :)
  sample_sum->AddFriend("flattree");

  // Get tree & branches for HighLAND ana
  TTree *anaTree = (TTree *)HighLANDinputFile->Get("ana");

  Int_t AT_evt;
  Int_t AT_sample;
  Int_t AT_bunch;
  Int_t AT_accum_level;

  anaTree->SetBranchAddress("evt", &AT_evt);
  anaTree->SetBranchAddress("sample", &AT_sample);
  anaTree->SetBranchAddress("bunch", &AT_bunch);
  anaTree->SetBranchAddress("accum_level", &AT_accum_level);

  // Do some text file formatting
  eventPrint << "========== Unmatched events in OAGW file ==========" << std::endl;

  // Loop over OAGW entries
  for (uint i=0; i<sample_sum->GetEntries(); i++) {

    sample_sum->GetEntry(i);

    // Skip entries flagged as 'isConsecutiveIdenticalEvent'
    if ( bool(SS_isConsecutiveIdenticalEvent) == true ) {
      std::cout << "OAGW entry " << i << " not selected" << std::endl;
      continue;
    }

    // Try to find the same entry in the HL file
    bool matched = false;

    for (uint j=0; j<=anaTree->GetEntries(); j++) {
      // Search outward from the event number
      int high = i + j;
      int low = i - j;
      if ( (low < 0) && (high >= anaTree->GetEntries()) ) break;

      if ( high < anaTree->GetEntries()) {
        anaTree->GetEntry(high);
        if ( (AT_evt == SS_EventNumber) && (AT_bunch == FT_Bunch) ) {
          std::cout << "Found OAGW entry " << i << " in the HL file (" << high << ")" << std::endl;
          matched = true;
          break;
        }
      }

      if ( (low >= 0) && (high != low) ) {
        anaTree->GetEntry(low);
        if ( (AT_evt == SS_EventNumber) && (AT_bunch == FT_Bunch) ) {
          std::cout << "Found OAGW entry " << i << " in the HL file (" << low << ")" << std::endl;
          matched = true;
          break;
        }
      }

    }
    // If we didn't find it, print it
    if (!matched) {
      std::cout << "Didn't find OAGW entry " << i << " in the HL file" << std::endl;
      eventPrint << "Entry=" << i << ", Spill=" << SS_EventNumber << ", Bunch=" << FT_Bunch << ", Sample=" << SS_SelectedSample << std::endl;
    }
  }

  // Do some more text file formatting
  eventPrint << std::endl;
  eventPrint << "=========== Unmatched events in HL file ===========" << std::endl;

  // Loop over HL entries
  for (uint i=0; i<anaTree->GetEntries(); i++) {

    anaTree->GetEntry(i);

    // Skip entries with incorrect accum_level
    if ( AT_accum_level < 7 ) {
      std::cout << "HL entry " << i << " not selected" << std::endl;
      continue;
    }

    // Try to find the same entry in the OAGW file
    bool matched = false;

    for (uint j=0; j<=sample_sum->GetEntries(); j++) {
      // Search outward from the event number
      int high = i + j;
      int low = i - j;
      if ( (low < 0) && (high >= sample_sum->GetEntries()) ) break;

      if ( high < sample_sum->GetEntries()) {
        sample_sum->GetEntry(high);
        if ( (AT_evt == SS_EventNumber) && (AT_bunch == FT_Bunch) ) {
          std::cout << "Found HL entry " << i << " in the OAGW file (" << high << ")" << std::endl;
          matched = true;
          break;
        }
      }

      if ( (low >= 0) && (high != low) ) {
        sample_sum->GetEntry(low);
        if ( (AT_evt == SS_EventNumber) && (AT_bunch == FT_Bunch) ) {
          std::cout << "Found HL entry " << i << " in the OAGW file (" << low << ")" << std::endl;
          matched = true;
          break;
        }
      }

    }
    // If we didn't find it, print it
    if (!matched) {
      std::cout << "Didn't find HL entry " << i << " in the OAGW file" << std::endl;
      eventPrint << "Entry=" << i << ", Spill=" << AT_evt << ", Bunch=" << AT_bunch << ", Sample=" << AT_sample << std::endl;
    }
  }

  eventPrint.close();

}

int main() {
  CompareSelectedEvents();
  return 0;
}