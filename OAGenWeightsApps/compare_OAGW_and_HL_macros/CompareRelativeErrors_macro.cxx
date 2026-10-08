#include "CompareOAGWandHL_utils.cxx"

///// *actual* main
void CompareRelativeErrors_macro() {

  std::string outfileName = "RelativeErrorComparison_UpgradeSamples_TpcPid";

  // Options
  bool saveCanvasAsC = false;

  // OAGW file
  std::string fileName_OAGW = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/MakeND280Cov/NDCov_HL5.27.1_all_all.root";
  // std::string fileName_OAGW = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/MakeND280Cov/BFieldDist/NDCov_HL5.27.1_BFieldDist_all_all.root";
  // std::string fileName_OAGW = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/UpgradeNumuCCAnalysis/SystThrows/Output_UpgradeNumuCCAnalysis_BFieldDist_all_HL5.27.1.root";
  // std::string fileName_OAGW = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/MakeND280Cov/TpcPid/NDCov_HL5.27.1_TpcPid_all_all.root";

  

  // HL file
  // std::string fileName_HL = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/UpgradeNumuCCAnalysis/SystThrows/Output_UpgradeNumuCCAnalysis_AllSysts_all_HL5.27.1.root";
  // std::string fileName_HL = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/UpgradeNumuCCAnalysis/SystThrows/Output_UpgradeNumuCCAnalysis_BFieldDist_all_HL5.27.1.root";
  std::string fileName_HL = "/scratch/dlangrid/UpgradeValidations/HL5.27.1/UpgradeNumuCCAnalysis/SystThrows/Output_UpgradeNumuCCAnalysis_TPCPID_all_HL5.27.1.root";

  // The single most godly method of writing sample binning you've ever seen: ( sampleBinning[Sample][Kinematic][Bin] )
  std::vector<int> sampleEnum = {168, 169, 170};
  std::vector<std::string> sampleName = {"TPC muon", "HAT muon", "SFG contained muon"};
  std::vector<std::string> sampleShortName = {"TPCmu", "HATmu", "SFGmu"};

  std::vector<std::vector<std::vector<Double_t>>> sample_Binning = {
    // TPCmu
    { {0, 440, 640, 840, 1080, 1300, 1540, 1680, 1940, 2200, 2500, 2840, 3260, 3860, 4720, 30000}, // mom
      {-1, 0.851, 0.8823, 0.9152, 0.943, 0.9585, 0.9716, 0.9823, 0.9905, 0.9949, 0.9987, 1} }, // theta
    // HATmu
    { {0, 280, 440, 600, 800, 960, 1160, 1520, 2120, 3120, 30000}, // mom
      {-1, 0.4029, 0.4707, 0.5144, 0.5569, 0.5979, 0.6374, 0.6753, 0.7203, 0.7705, 0.8235, 0.8639, 0.8994, 0.9251, 0.9387, 0.9471, 0.9585, 1} }, // theta
    // SFGmu
    { {0, 220, 320, 1000}, // mom
      {-1, -0.8823, -0.666, -0.4144, -0.175, 0.0628, 0.2608, 0.4371, 0.5776, 0.7203, 0.8163, 0.9048, 0.9654, 1} } // theta
  };

  // Create canvases and pdfs
  TCanvas* canv_OAGW = new TCanvas();
  canv_OAGW->Print((outfileName+std::string("_OAGW.pdf[")).c_str());

  TCanvas* canv_HL = new TCanvas();
  canv_HL->Print((outfileName+std::string("_HL.pdf[")).c_str());

  TCanvas* canv_Comp = new TCanvas();
  canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL.pdf[")).c_str());

  gStyle->SetOptStat(0);
  gStyle->SetFillColor(-1);
  gStyle->SetFillStyle(4000);
  gStyle->SetLegendBorderSize(0);

  // Loop over samples
  // int covMatrixOffset = 2; // DL: This works because diagonal of covariance of 1D representation of 2D kinematic binning etc etc
  int covMatrixOffset = 1; // 0th bin is always underflow

  // Total relative syst error
  std::vector<double> totalSystError_OAGW(sampleEnum.size(), 0);
  std::vector<double> totalSystError_HL(sampleEnum.size(), 0);

  for (uint s=0; s < sampleEnum.size(); s++) {
    std::cout << std::endl;
    std::cout << ">>>>> Plotting for sample Enum: " << sampleEnum[s] << std::endl;

    // Get binning
    Int_t momNBins = sample_Binning[s][0].size()-1;
    Double_t momBinEdges[momNBins+1];
    for (uint i = 0; i < momNBins+1; i++) { momBinEdges[i] = sample_Binning[s][0][i]; }

    Int_t thetaNBins = sample_Binning[s][1].size()-1;
    Double_t thetaBinEdges[thetaNBins+1];
    for (uint i = 0; i < thetaNBins+1; i++) { thetaBinEdges[i] = sample_Binning[s][1][i]; }
    
    // ===== OAGW =====

    // Get 2D rel errors
    std::cout << std::endl;
    std::cout << "> Getting OAGW rel errors" << std::endl;
    TH2D* Hist_OAGW = GetRelativeError2D(fileName_OAGW, momNBins, momBinEdges, thetaNBins, thetaBinEdges, sampleEnum[s], covMatrixOffset);
    Hist_OAGW->Scale(100.); // DL: If HL rel error is a %
    
    // Calculate total systematic error
    TH2D* nEvents_OAGW = GetSpectra2D(fileName_OAGW, momNBins, momBinEdges, thetaNBins, thetaBinEdges, sampleEnum[s], covMatrixOffset);
    TH2D* AbsError_OAGW = (TH2D*)Hist_OAGW->Clone();
    AbsError_OAGW->Multiply(nEvents_OAGW); // Get absolute error
    AbsError_OAGW->Multiply(AbsError_OAGW); // Get absolute variance
    totalSystError_OAGW[s] = TMath::Sqrt( AbsError_OAGW->Integral() ) / nEvents_OAGW->Integral(); // Convert back to relative error

    // Format 2D hist
    Hist_OAGW->SetTitle(sampleName[s].c_str());
    Hist_OAGW->SetXTitle("Muon Momentum (MeV)");
    Hist_OAGW->SetYTitle("Muon CosTheta");
    Hist_OAGW->SetZTitle("Relative Error");
    Hist_OAGW->GetZaxis()->SetRangeUser(0., Hist_OAGW->GetMaximum());

    // Create 1D rel errors from 2D projection (requires 2D event spectra)
    TH1D* Hist_OAGW_mom = GetRelativeErrorProjection(Hist_OAGW, nEvents_OAGW, momNBins, momBinEdges, "x", (sampleName[s]+" mom").c_str());
    TH1D* Hist_OAGW_theta = GetRelativeErrorProjection(Hist_OAGW, nEvents_OAGW, thetaNBins, thetaBinEdges, "y", (sampleName[s]+" costheta").c_str());

    // Draw and save plots
    canv_OAGW->cd();

    Hist_OAGW->Draw("COLZ");
    canv_OAGW->Print((outfileName+std::string("_OAGW.pdf")).c_str());
    if (saveCanvasAsC) canv_OAGW->Print((outfileName+std::string("_OAGW")+sampleShortName[s]+("_2D.C")).c_str());
    canv_OAGW->Clear();

    Hist_OAGW_mom->Draw("HIST");
    canv_OAGW->Print((outfileName+std::string("_OAGW.pdf")).c_str());
    if (saveCanvasAsC) canv_OAGW->Print((outfileName+std::string("_OAGW")+sampleShortName[s]+("_mom.C")).c_str());
    canv_OAGW->Clear();

    Hist_OAGW_theta->Draw("HIST");
    canv_OAGW->Print((outfileName+std::string("_OAGW.pdf")).c_str());
    if (saveCanvasAsC) canv_OAGW->Print((outfileName+std::string("_OAGW")+sampleShortName[s]+("_theta.C")).c_str());
    canv_OAGW->Clear();
    
    // ===== HL =====

    // Get 2D rel errors
    std::cout << std::endl;
    std::cout << "> Getting HL rel errors" << std::endl;
    TH2D* Hist_HL = GetRelativeError2D(fileName_HL, momNBins, momBinEdges, thetaNBins, thetaBinEdges, sampleEnum[s], covMatrixOffset);

    // Calculate total systematic error
    TH2D* nEvents_HL = GetSpectra2D(fileName_HL, momNBins, momBinEdges, thetaNBins, thetaBinEdges, sampleEnum[s], covMatrixOffset);
    TH2D* AbsError_HL = (TH2D*)Hist_HL->Clone();
    AbsError_HL->Multiply(nEvents_HL);
    AbsError_HL->Multiply(AbsError_HL);
    totalSystError_HL[s] = TMath::Sqrt( AbsError_HL->Integral() ) / nEvents_HL->Integral() ; // Convert back to relative error

    // Format 2D hist
    Hist_HL->SetTitle(sampleName[s].c_str());
    Hist_HL->SetXTitle("Muon Momentum (MeV)");
    Hist_HL->SetYTitle("Muon CosTheta");
    Hist_HL->SetZTitle("Relative Error");
    Hist_HL->GetZaxis()->SetRangeUser(0., Hist_HL->GetMaximum());

    // Create 1D rel errors from HL drawing tools
    TH1D* Hist_HL_mom = GetRelativeError1D(fileName_HL, momNBins, momBinEdges, "selmu_mom", sampleEnum[s]);
    TH1D* Hist_HL_theta = GetRelativeError1D(fileName_HL, thetaNBins, thetaBinEdges, "selmu_direction2", sampleEnum[s]);

    // Draw and save plots
    canv_HL->cd();

    Hist_HL->Draw("COLZ");
    canv_HL->Print((outfileName+std::string("_HL.pdf")).c_str());
    if (saveCanvasAsC) canv_HL->Print((outfileName+std::string("_HL")+sampleShortName[s]+("_2D.C")).c_str());
    canv_HL->Clear();

    Hist_HL_mom->Draw("HIST");
    canv_HL->Print((outfileName+std::string("_HL.pdf")).c_str());
    if (saveCanvasAsC) canv_HL->Print((outfileName+std::string("_HL")+sampleShortName[s]+("_mom.C")).c_str());
    canv_HL->Clear();

    Hist_HL_theta->Draw("HIST");
    canv_HL->Print((outfileName+std::string("_HL.pdf")).c_str());
    if (saveCanvasAsC) canv_HL->Print((outfileName+std::string("_HL")+sampleShortName[s]+("_theta.C")).c_str());
    canv_HL->Clear();

    // ===== Comparison =====

    // Get 2D ratio
    std::cout << std::endl;
    std::cout << "> Getting OAGW / HL ratio" << std::endl;
    TH2D* Hist_Comp = new TH2D((sampleName[s]+" OAGW/HL ratio").c_str(), "", momNBins, momBinEdges, thetaNBins, thetaBinEdges);
    // DL: REMEMBER THAT ROOT HISTS COUNT BINS FROM 1
    for (uint binx = 1; binx < momNBins+1; binx++) {
      for (uint biny = 1; biny < thetaNBins+1; biny++) {

        // Double_t nEventsInBinOAGW = Hist_OAGW->GetBinContent(binx, biny);
        // Double_t nEventsInBinHL = Hist_HL->GetBinContent(binx, biny);
        Double_t nEventsInBinOAGW = Hist_OAGW->Integral(binx, binx, biny, biny);
        Double_t nEventsInBinHL = Hist_HL->Integral(binx, binx, biny, biny);
        Double_t binRatio = nEventsInBinOAGW / nEventsInBinHL;

        if (nEventsInBinHL == 0) {
          if (nEventsInBinOAGW != 0) {
            std::cout << "ERROR: HighLAND bin value = 0 but OAGW does not (binx = " << binx << ", biny = " << biny;
            std::cout << ", OAGW value = " << nEventsInBinOAGW << ")" << std::endl;
            throw;
          }
          // std::cout << "WARNING: Both HighLAND and OAGW bins have 0 value (" << momBinEdges[binx] << "-" << momBinEdges[binx+1] << ", ";
          // std::cout << thetaBinEdges[biny] << "-" << thetaBinEdges[biny+1] << ") - setting ratio to 0" << std::endl;
          binRatio = 0;
        }
        Hist_Comp->SetBinContent(binx, biny, binRatio);
      }
    }
    std::cout << "Total OAGW / HL relative error ratio = " << Hist_OAGW->Integral() / Hist_HL->Integral() << std::endl;

    // Format 2D ratio
    Hist_Comp->SetTitle(sampleName[s].c_str());
    Hist_Comp->SetXTitle("Muon Momentum (MeV)");
    Hist_Comp->SetYTitle("Muon CosTheta");
    Hist_Comp->SetZTitle("OAGW / HL ratio");
    Hist_Comp->GetZaxis()->SetRangeUser( TMath::Min(0.,Hist_Comp->GetMinimum()), TMath::Max(1.,Hist_Comp->GetMaximum()) );

    // Create 1D ratios
    Hist_OAGW_mom->SetLineColor(kBlue);
    Hist_HL_mom->SetLineColor(kRed);
    auto Ratio_mom = new TRatioPlot(Hist_OAGW_mom, Hist_HL_mom, "divsym");
    Ratio_mom->SetH1DrawOpt("HIST");
    Ratio_mom->SetH2DrawOpt("HIST");

    Hist_OAGW_theta->SetLineColor(kBlue);
    Hist_HL_theta->SetLineColor(kRed);
    auto Ratio_theta = new TRatioPlot(Hist_OAGW_theta, Hist_HL_theta, "divsym");
    Ratio_theta->SetH1DrawOpt("HIST");
    Ratio_theta->SetH2DrawOpt("HIST");

    // Draw and save plots
    canv_Comp->cd();

    Hist_Comp->Draw("COLZ");
    canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL.pdf")).c_str());
    if (saveCanvasAsC) canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL")+sampleShortName[s]+("_2D.C")).c_str());
    canv_Comp->Clear();

    Ratio_mom->Draw("HIST");
    // TGraphAsymmErrors* Ratio_mom_errors = (TGraphAsymmErrors*)Ratio_mom->GetLowerRefGraph(); // set ratio y errors to 0
    // for (int n=0; n<Ratio_mom_errors->GetN(); n++) {
    //   double binWidth = momBinEdges[n+1] - momBinEdges[n];
    //   Ratio_mom_errors->SetPointError(n,binWidth/2,binWidth/2,0.,0.); // breaks here
    // }
    TLegend *legend_mom = new TLegend(0.4, 0.75, 0.6, 0.85);
    legend_mom->AddEntry(Hist_OAGW_mom, "OAGW", "l");
    legend_mom->AddEntry(Hist_HL_mom, "HL", "l");
    legend_mom->Draw();
    canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL.pdf")).c_str());
    if (saveCanvasAsC) canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL")+sampleShortName[s]+("_mom.C")).c_str());
    canv_Comp->Clear();

    Ratio_theta->Draw("HIST");
    // TGraphAsymmErrors* Ratio_theta_errors = (TGraphAsymmErrors*)Ratio_theta->GetLowerRefGraph(); // set ratio y errors to 0
    // for (int n=0; n<Ratio_theta_errors->GetN(); n++) {
    //   double binWidth = thetaBinEdges[n+1] - thetaBinEdges[n];
    //   Ratio_theta_errors->SetPointError(n,binWidth/2,binWidth/2,0,0); // breaks here
    // }
    TLegend *legend_theta = new TLegend(0.4, 0.75, 0.6, 0.85);
    legend_theta->AddEntry(Hist_OAGW_theta, "OAGW", "l");
    legend_theta->AddEntry(Hist_HL_theta, "HL", "l");
    legend_theta->Draw();
    canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL.pdf")).c_str());
    if (saveCanvasAsC) canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL")+sampleShortName[s]+("_theta.C")).c_str());
    canv_Comp->Clear();

    // Increase offset of bins in Cov Matrix
    covMatrixOffset += momNBins*thetaNBins;
  }

  // close pdfs
  canv_OAGW->Print((outfileName+std::string("_OAGW.pdf]")).c_str());
  canv_HL->Print((outfileName+std::string("_HL.pdf]")).c_str());
  canv_Comp->Print((outfileName+std::string("_Comp_OAGW_vs_HL.pdf]")).c_str());

  // print total relative syst errors
  std::cout << std::endl;
  std::cout << "> Total Relative Systematic Errors (OAGW | HL)" << std::endl;
  for (int s = 0; s < sampleEnum.size(); s++) {
    std::cout << "  " << sampleShortName[s] << ":   " << totalSystError_OAGW[s] << "   |   " << totalSystError_HL[s] << std::endl;
  }
  std::cout << std::endl;

}

///// main
int main() {
  CompareRelativeErrors_macro();
  return 0;
}