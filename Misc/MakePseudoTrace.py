import numpy as np
import ROOT

# Gaussian Likelihood
def GetLH(x, mean=0, sig=1):
  return np.exp(-1*( ((x-mean)**2) / (2*(sig**2)) ) )

if __name__ == "__main__":
  
  # Step settings
  n_steps = 500
  step_size = 0.01

  # Param settings
  par_min = -5
  par_max = 5

  # LH settings
  LH_center = 0
  LH_width = 1


  # `step' here is actually the param value
  step = [np.random.uniform(par_min,par_max)]
  
  for i in range(n_steps):

    proposed = np.random.normal(step[i], np.sqrt(step_size*(par_max-par_min)))

    accProb = np.minimum(1, GetLH(proposed, LH_center, LH_width)/GetLH(step[i], LH_center, LH_width) )

    if np.random.uniform(0,1) < accProb:
      step.append(proposed)
    else:
      step.append(step[i])

canvas = ROOT.TCanvas()

trace = ROOT.TGraph(n_steps+1, np.linspace(0,n_steps,n_steps+1), np.array(step))
trace.Draw()

canvas.Print('DummyTrace.pdf')
canvas.Print('DummyTrace.C')