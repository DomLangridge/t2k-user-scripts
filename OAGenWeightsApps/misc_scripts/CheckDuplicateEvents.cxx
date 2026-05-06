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

// DL: This script is for checking for duplicate events in highland flattrees, which is helpful for debugging.
//     The checked branches can be expanded, and it should be fairly easy to update this with other checks, more flattrees, etc.

void CheckDuplicateEvents() {

  // Open (hardcoded) input file
  std::string flattreeFileName = "/home/dlangrid/scratch/Flattrees/HL5.9/flattrees_p8v17_neut_mc_run_91320000_hl5.9.root";
  TFile *flattreeFile = TFile::Open(flattreeFileName.c_str());

  // Open (hardcoded) output file
  ofstream outputFile;
  outputFile.open("CheckDuplicateEvents.out");

  // Get tree & branches
  TTree *flatTree = (TTree *)flattreeFile->Get("flattree");

  Int_t sEvt;
  Int_t sNTrueVertices;
  Int_t Bunch;

  flatTree->SetBranchAddress("sEvt", &sEvt);
  flatTree->SetBranchAddress("sNTrueVertices", &sNTrueVertices);
  flatTree->SetBranchAddress("Bunch", &Bunch);

  // Setup lists and things useful for the for
  std::vector<int> entryList;
  std::vector<int> nTrueVerticesList;
  std::vector<int> BunchList;

  int currentEvent=-999;

  for (uint i=0; i<flatTree->GetEntries(); i++) {

    // Get current entry info
    flatTree->GetEntry(i);

    // If we've reached a new event, print the info for the repeated event (if there was one) and clear the vectors
    if (!entryList.empty() && sEvt != currentEvent) {

      // Print info
      if (entryList.size() > 1) {
        outputFile << "Event: " << entryList[0] << " (" << entryList.size() << " entries)" << std::endl;
        for (uint j=0; j<entryList.size(); j++) {
          outputFile << "  Entry = " << entryList[j] << ", sNTrueVertices = " << nTrueVerticesList[j] << ", Bunch = " << BunchList[j] << std::endl; 
        }
      }
      
      // Clear vectors
      entryList.clear();
      nTrueVerticesList.clear();
      BunchList.clear();
      
    }

    // Store current entry info
    currentEvent = sEvt;
    entryList.push_back(i);
    nTrueVerticesList.push_back(sNTrueVertices);
    BunchList.push_back(Bunch);

  }

  outputFile.close();
}

int main() {
  CheckDuplicateEvents();
  return 0;
}