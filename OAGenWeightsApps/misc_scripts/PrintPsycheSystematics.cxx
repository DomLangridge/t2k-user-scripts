#include <cstdlib>
#include <stdlib.h>

#include <fstream>
#include <iostream>
#include <string>

// psyche includes
#include "AnalysisManager.hxx"
#include "AnalysisUtils.hxx"
#include "Parameters.hxx"
#include "VersioningUtils.hxx"

// psyche systematic includes
#include "ChargeIDEffSystematics.hxx" // DL: Doesn't work for Charge ID apparently
#include "TrackerOOFVSystematics.hxx"

//DL: This is an incredibly basic script for accessing the printouts for psyche systematics. There are a few steps for running this:
//    - Make sure you include the header file for the systematic you want to use. I'll figure out how to automatically grab all of
//      later but for now this'll have to do
//    - Replace the class names below with the systematic you want to print
//    - This code should be compiled within something that sources psyche (so you don't have to faff around with paths). I've been
//      putting it in OAGenWeightsApps (app/ND280) and then adding it into the CMakeLists.txt file in the same directory.
//
//    I might look into expanding this to have it as an actual ND280 script for OAGenWeightsApps, by looking through a given
//    systematics config file and then printing each one (also warning of any that can't / don't have a print function)

void PrintPsycheSystematic() {

  // Set production
  versionUtils::SetProduction(versionUtils::kProd8);

  // Create instance of systematic
  TrackerOOFVSystematics *syst = new TrackerOOFVSystematics;

  // Print parameters
  syst->Print();

}

int main() {
  PrintPsycheSystematic();
  return 0;
}