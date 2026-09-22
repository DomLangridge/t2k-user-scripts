import numpy as np
import math
import ROOT

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
  saveCanvasAsC = False
  pdf_nbins = [50, 30, 25] 
  plot2DPDFs = False
  
  # Step settings
  n_steps = 10000
  step_size = 2.38 # Ideal step size for single parameter

  # Param settings
    # [name, min, max]
    # Currently min & max are not actual boundaries, just a range for starting value choice
  parameter = [
    ["x", -5, 5],
    ["y", -3, 3],
    ["z", 0, 5]
  ]

  # LH settings (currently just three arbitrary 1D Guassians)
  LH_mean = [0, -1.5, 3]
  LH_stdev = [1, 2, 0.5]

  # ====================

  # Random starting step
  par_val = [[0]]*len(parameter)
  for p in range(len(parameter)):
    par_val[p] = [np.random.uniform(parameter[p][1],parameter[p][2])]
  
  print("Starting from initial position ",par_val) # DL Debug

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
  print("Finished MCMC :)")
  print("Total Acceptance Rate = ",(accCount/n_steps)," (",accCount,"/",n_steps,")")

  canvas = ROOT.TCanvas()

  # plot trace

  canvas.Print('DummyTrace.pdf[')

  print("> Plotting Trace")
  for p in range(len(parameter)):

    tracePlot = ROOT.TGraph(n_steps+1, np.linspace(0,n_steps,n_steps+1), np.array(par_val[p]))

    tracePlot.GetXaxis().SetTitle("Step")
    tracePlot.GetYaxis().SetTitle(parameter[p][0])
    tracePlot.Draw()

    canvas.Print('DummyTrace.pdf')
    if bool(saveCanvasAsC):
      canvas.Print('DummyTrace_'+parameter[p][0]+'.C')
    
    canvas.Clear()

  canvas.Print('DummyTrace.pdf]')

  canvas.Clear()

  # plot accRate

  print("> Plotting Acceptance Rate")
  accRatePlot = ROOT.TGraph(n_steps, np.linspace(1,n_steps,n_steps), np.array(accRate))
  accRatePlot.GetXaxis().SetTitle("Step")
  accRatePlot.GetYaxis().SetTitle("Acceptance Rate")
  accRatePlot.Draw()

  canvas.Print('DummyAccProb.pdf')
  if bool(saveCanvasAsC):
    canvas.Print('DummyAccProb.C')

  canvas.Clear()

  # plot pdf

  canvas.Print('DummyPDF.pdf[')

  # 1D pdf with target

  print("> Plotting 1D PDFs")
  for p in range(len(parameter)):

    pdfPlot = ROOT.TH1D(parameter[p][0]+" PDF",parameter[p][0]+" PDF", pdf_nbins[p], parameter[p][1], parameter[p][2])
    for v in par_val[p]:
      pdfPlot.Fill(v)

    pdfPlot.SetXTitle(parameter[p][0])
    pdfPlot.SetYTitle("Steps/"+str(n_steps))
    pdfPlot.Draw("HIST")
    pdfPlot.Scale(1/n_steps)

    x = np.linspace(parameter[p][1],parameter[p][2],1000)
    # targetDist = ROOT.TGraph(1000, x, GetLH(x, LH_mean[p], LH_stdev[p]))
    targetDist = ROOT.TGraph(1000, x, GetLH(x, LH_mean[p], LH_stdev[p])*((parameter[p][2]-parameter[p][1])/pdf_nbins[p]))
    targetDist.Draw("SAME")

    canvas.Print('DummyPDF.pdf')
    if bool(saveCanvasAsC):
      canvas.Print('DummyPDF_'+parameter[p][0]+'.C')

    canvas.Clear()

  # 2D pdf

  if bool(plot2DPDFs):
    print("> Plotting 2D PDFs (this may take a while...)")
    for p in range(len(parameter)-1):
      for q in range(p+1,len(parameter)):

        print("  ",parameter[p][0],", ",parameter[q][0])

        pdfPlot2D = ROOT.TH2D(parameter[p][0]+" "+parameter[q][0]+" PDF",parameter[p][0]+" "+parameter[q][0]+" PDF", pdf_nbins[p], parameter[p][1], parameter[p][2], pdf_nbins[q], parameter[q][1], parameter[q][2])

        for v1 in par_val[p]:
          for v2 in par_val[q]:
            pdfPlot2D.Fill(v1, v2)

        pdfPlot2D.SetXTitle(parameter[p][0])
        pdfPlot2D.SetYTitle(parameter[q][0])
        pdfPlot2D.SetZTitle("Steps/"+str(n_steps))
        pdfPlot2D.Draw("HIST COLZ")
        pdfPlot2D.Scale(1/n_steps)

        canvas.Print('DummyPDF.pdf')
        if bool(saveCanvasAsC):
          canvas.Print('DummyPDF_'+parameter[p][0]+'_'+parameter[q][0]+'.C')

        canvas.Clear()

  canvas.Print('DummyPDF.pdf]')
  canvas.Clear()
