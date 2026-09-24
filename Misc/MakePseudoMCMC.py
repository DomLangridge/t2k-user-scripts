import numpy as np
import math
import ROOT

# To Do
# - Add more parameters (increase to 10 maybe?)
# - Start parameters outside of good LLH range (and use low n_steps, ~200) to get good trace plots
#   - Compare to plots in Kirsty's thesis (they're very good examples)
# - Add a way to handle crossing parameter boundaries maybe?

# Combination of 1D Gaussian Likelihoods
def GetLH(x, mean, stdev):

  # Make sure x, mean, and stdev work as lists
  if type(x) is not list: x = [x]
  if type(mean) is not list: mean = [mean]
  if type(stdev) is not list: stdev = [stdev]

  # Calculate 1D likelihoods
  Likelihood = 1.
  for i in range(len(x)):
    Likelihood = Likelihood * ( 1 / (stdev[i] * np.sqrt(2*math.pi) ) ) * np.exp(-1*( ((x[i]-mean[i])**2) / (2*(stdev[i]**2)) ) )

  return Likelihood

# Main

if __name__ == "__main__":

  # ===== Settings =====

  # General
  saveCanvasAsC = True
  pdf_nbins = [50, 50, 50] 
  plot2DPDFs = False
  nAccRateBatches = 20

  RandomStart = False
  RandomLH = False
  RandomLH_precision = [3, 5, 7]

  # Param settings
    # [name, start, min, max]
    # Currently min & max are not actual boundaries, just a range for random start or likelihood
  parameter = [
    ["x", 0, -99, 99],
    ["y", 5, -99, 99],
    ["z", -5, -99, 99]
  ]

  # LH settings (currently just three arbitrary 1D Gaussians)
    # Will be overwritten if RandomLH is set
  LH_mean = [
    0,
    0,
    0
  ]
  LH_stdev = [
    1,
    1,
    1
  ]

  # Step settings
  n_steps = 100000
  # step_size = 1.75
  step_size = 2.38/np.sqrt(len(parameter))
    # From chat w/ Henry: Ideal step size is to scale the covariance matrix variance by (2.38^2)/#parameters
    #                     This is standard dev not variance, so 2.38/sqrt(#parameters)

  # ====================

  # Start at 0
  par_val = [[0]]*len(parameter)

  # Set start position
  if bool(RandomStart):
    for p in range(len(parameter)):
      par_val[p] = [np.random.uniform(parameter[p][2],parameter[p][3])]
  else:
    for p in range(len(parameter)):
      par_val[p] = [parameter[p][1]]

  # Set random LH if on
  if bool(RandomLH):
    for p in range(len(parameter)):
      LH_mean[p] = np.random.uniform(parameter[p][2],parameter[p][3])
      LH_stdev[p] = abs(np.random.normal(0,abs(parameter[p][3]-parameter[p][2])/RandomLH_precision[p]))
  
  print("")
  print("Starting from initial position ",par_val)
  print("Using step size ",step_size)
  print("")
  print("With Gaussian LH mean ", LH_mean)
  print("              & stdev ", LH_stdev)
  print("")

  # Counters
  accCount = 0
  accRate = []

  # Run MCMC
  print("Running MCMC...")
  for i in range(n_steps):

    # Progress updates
    if 100*(i/n_steps) % 5 == 0:
        print("-> ",100*(i/n_steps),"% (step ",i,"/",n_steps,")")

    # Propose step
    current = []
    proposed = []
    for p in range(len(parameter)):
      current.append(par_val[p][i])
      proposed.append(np.random.normal(current[p], step_size*LH_stdev[p]))

    # Calculate acceptance probability
    accProb = np.minimum(1, GetLH(proposed, LH_mean, LH_stdev)/GetLH(current, LH_mean, LH_stdev) )

    # Accept / reject step
    if np.random.uniform(0,1) < accProb:
      for p in range(len(parameter)):
        par_val[p].append(proposed[p])
      accCount += 1
    else:
      for p in range(len(parameter)):
        par_val[p].append(current[p])

    # Calculate acceptance rate
    accRate.append(accCount/(i+1))

  # End MCMC
  print("")
  print("Finished MCMC :)")
  print("Total Acceptance Rate = ",(accCount/n_steps)," (",accCount,"/",n_steps,")")
  print("")

  canvas = ROOT.TCanvas()
  # gStyle.SetOptStat(0)

  # plot trace

  print("> Plotting Trace")
  canvas.Print('DummyTrace.pdf[')

  for p in range(len(parameter)):

    tracePlot = ROOT.TGraph(n_steps+1, np.linspace(0,n_steps,n_steps+1), np.array(par_val[p]))

    tracePlot.GetXaxis().SetTitle("Step")
    tracePlot.SetTitle("")
    # tracePlot.GetYaxis().SetTitle(parameter[p][0]) # For testing
    tracePlot.GetYaxis().SetTitle("Parameter Value") # for MaCh3 paper plots

    tracePlot.Draw()

    canvas.SetLogx()
    canvas.Print('DummyTrace.pdf')
    if bool(saveCanvasAsC):
      canvas.Print('DummyTrace_'+parameter[p][0]+'.C')
    
    canvas.Clear()

  canvas.Print('DummyTrace.pdf]')

  canvas.Clear()

  # plot accRate

  print("> Plotting Acceptance Rate")
  canvas.Print('DummyAccProb.pdf[')

    # graph
  accRatePlot = ROOT.TGraph(n_steps, np.linspace(1,n_steps,n_steps), np.array(accRate))

  accRatePlot.SetTitle("")
  accRatePlot.GetXaxis().SetTitle("Step")
  accRatePlot.GetYaxis().SetTitle("Acceptance Probability")
  accRatePlot.GetYaxis().SetRangeUser(0, 1)
  accRatePlot.Draw()

  canvas.Print('DummyAccProb.pdf')
  if bool(saveCanvasAsC):
    canvas.Print('DummyAccProb.C')

  canvas.Clear()

    # batched hist
  accRateBatchPlot = ROOT.TH1D("", "", nAccRateBatches, 0, n_steps)
  for step in range(len(accRate)):
    accRateBatchPlot.Fill(step, accRate[step]*nAccRateBatches/(n_steps+1))

  for batch in range(nAccRateBatches):
    batch_min = batch*(n_steps//nAccRateBatches)
    batch_max = (batch+1)*(n_steps//nAccRateBatches)
    accRateBatchPlot.GetXaxis().SetBinLabel(batch+1,str(batch_min)+" - "+str(batch_max))

  accRateBatchPlot.SetTitle("")
  accRateBatchPlot.SetXTitle("")
  accRateBatchPlot.SetYTitle("Acceptance Probability")
  accRateBatchPlot.GetYaxis().SetRangeUser(0,1)
  accRateBatchPlot.Draw("HIST")
  
  canvas.Print('DummyAccProb.pdf')
  if bool(saveCanvasAsC):
    canvas.Print('DummyAccProb_Batch.C')


  canvas.Print('DummyAccProb.pdf]')
  canvas.Clear()

  # plot 1D pdf

  print("> Plotting 1D PDFs")
  canvas.Print('DummyPDF.pdf[')

  for p in range(len(parameter)):

    par_min = min(par_val[p])
    par_max = max(par_val[p])

    pdfPlot = ROOT.TH1D(parameter[p][0]+" PDF",parameter[p][0]+" PDF", pdf_nbins[p], par_min, par_max)
    for v in par_val[p]:
      pdfPlot.Fill(v, (pdf_nbins[p]/(par_max-par_min)))

    pdfPlot.SetXTitle(parameter[p][0])
    pdfPlot.SetYTitle("Steps/("+str(n_steps)+"*"+str((par_max-par_min)/pdf_nbins[p])+")")
    pdfPlot.Draw("HIST")
    pdfPlot.Scale(1/n_steps)

    x = np.linspace(par_min,par_max,1000)
    # targetDist = ROOT.TGraph(1000, x, GetLH(x, LH_mean[p], LH_stdev[p]))
    targetDist = ROOT.TGraph(1000, x, GetLH(x, LH_mean[p], LH_stdev[p]))
    targetDist.Draw("SAME")

    canvas.Print('DummyPDF.pdf')
    if bool(saveCanvasAsC):
      canvas.Print('DummyPDF_'+parameter[p][0]+'.C')

    canvas.Clear()

  # plot 2D pdf

  if bool(plot2DPDFs):
    print("> Plotting 2D PDFs (this may take a while...)")
    for p in range(len(parameter)-1):
      par_min_x = min(par_val[p])
      par_max_x = max(par_val[p])
      
      for q in range(p+1,len(parameter)):
        par_min_y = min(par_val[q])
        par_max_y = max(par_val[q])

        print("  ",parameter[p][0],", ",parameter[q][0])

        pdfPlot2D = ROOT.TH2D(parameter[p][0]+" "+parameter[q][0]+" PDF",parameter[p][0]+" "+parameter[q][0]+" PDF", pdf_nbins[p], par_min_x, par_max_x, pdf_nbins[q], par_min_y, par_max_y)

        for v1 in par_val[p]:
          for v2 in par_val[q]:
            pdfPlot2D.Fill(v1, v2, (pdf_nbins[p]/(par_max_x-par_min_x))*(pdf_nbins[q]/(par_max_y-par_min_y)))

        pdfPlot2D.SetXTitle(parameter[p][0])
        pdfPlot2D.SetYTitle(parameter[q][0])
        pdfPlot2D.SetZTitle("Steps/("+str(n_steps)+"*"+str((par_max_x-par_min_x)/pdf_nbins[p])+"*"+str((par_max_y-par_min_y)/pdf_nbins[q])+")")
        pdfPlot2D.Draw("HIST COLZ")
        pdfPlot2D.Scale(1/n_steps)

        canvas.Print('DummyPDF.pdf')
        if bool(saveCanvasAsC):
          canvas.Print('DummyPDF_'+parameter[p][0]+'_'+parameter[q][0]+'.C')

        canvas.Clear()

  canvas.Print('DummyPDF.pdf]')
  canvas.Clear()
