#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "TFile.h"
#include "TTree.h"

// DL: This script is for checking for duplicate events in highland flattrees, which is helpful for debugging.
//     The checked branches can be expanded, and it should be fairly easy to update this with other checks, more flattrees, etc.

void RunEventLoop(std::string flattreeFileName, std::ofstream& outputFile, bool checkAllEvents) {

  // Open input file
  TFile *flattreeFile = TFile::Open(flattreeFileName.c_str());
  
  // Get tree & branches
  TTree *flattree = (TTree *)flattreeFile->Get("flattree");

  Int_t sEvt;
  Int_t sNTrueVertices;
  Int_t Bunch;

  flattree->SetBranchAddress("sEvt", &sEvt);
  flattree->SetBranchAddress("sNTrueVertices", &sNTrueVertices);
  flattree->SetBranchAddress("Bunch", &Bunch);

  // Setup lists and things useful for the for
  std::vector<int> entryList;
  std::vector<int> nTrueVerticesList;
  std::vector<int> BunchList;

  int currentEvent=-999;

  for (uint i=0; i<flattree->GetEntries(); i++) {

    // Get current entry info
    flattree->GetEntry(i);

    // If we've reached a new event, print the info for the repeated event (if there was one) and clear the vectors
    if (!entryList.empty() && sEvt != currentEvent) {

      // Print info
      if ( (entryList.size() > 1) || (checkAllEvents) ) {
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

  // Print info for the last event
  if ( (entryList.size() > 1) || (checkAllEvents) ) {
    outputFile << "Event: " << entryList[0] << " (" << entryList.size() << " entries)" << std::endl;
    for (uint j=0; j<entryList.size(); j++) {
      outputFile << "  Entry = " << entryList[j] << ", sNTrueVertices = " << nTrueVerticesList[j] << ", Bunch = " << BunchList[j] << std::endl; 
    }
  }
}

void CheckDuplicateEvents(std::string input = "/scratch/dlangrid/flattrees/HL5.20/FileList_flattrees_neut_mc_HL5.20.txt",
                          std::string outputFileName = "",
                          bool checkAllEvents=false) {

  if (outputFileName == "") {
    if (checkAllEvents) outputFileName = "CheckAllEvents_HL5.20.out";
    else outputFileName = "CheckDuplicateEvents_HL5.20.out";
  }

  std::cout << "INFO: Using input " << input << std::endl;

  // Check if input is file or list of files - for now input is hardcoded but we can change that later :)
  bool fileList;
  std::string fileExt = input.substr(input.find_last_of(".") + 1);

  if (fileExt == "root") {
    std::cout << "INFO: Looks like this is a single root file" << std::endl;
    fileList = false;

  } else if (fileExt == "txt" || fileExt == "list") {
    std::cout << "INFO: Looks like this might be a list of files" << std::endl;
    fileList = true;

  } else {
    std::cout << "ERROR: I don't know what kind of file this is and I'm scared" << std::endl;
    throw;
  }

  // Open output file
  std::ofstream outputFile;
  outputFile.open(outputFileName.c_str());

  // If using file as input, run loop over the file
  if (!fileList) {
    std::cout << "INFO: Running loop over single input file" << std::endl;
    RunEventLoop(input, outputFile, checkAllEvents);

  // If using file list as input, run loop over each entry one at a time
  } else {
    std::cout << "INFO: Running loop over each file listed in input" << std::endl;
    std::ifstream fileList(input.c_str());

    std::string flattreeFileName;

    if (fileList.is_open()) {

      // Get each file line by line
      int listEntry = 0;
      while (std::getline(fileList, flattreeFileName)) {

        // Check if the file is a .root file
        if (flattreeFileName.substr(flattreeFileName.find_last_of(".") + 1) != "root") {
          std::cout << "WARN: List entry " << listEntry << " is not a root file -> skipping entry" << std::endl;
          continue;
        }

        // Run the loop if everything is file
        std::cout << "INFO: Running over file " << listEntry << " - " << flattreeFileName << std::endl;
        RunEventLoop(flattreeFileName, outputFile, checkAllEvents);
        listEntry++;
      }
      fileList.close();

    // Throw an error if the file list can't be opened
    } else {
      std::cerr << "ERROR: Unable to open file" << std::endl;
      throw;
    }
  }

  outputFile.close();
}

int main() {
  CheckDuplicateEvents();
  return 0;
}