import ROOT
import argparse

# ==================== Arguments ====================

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", type=str)
parser.add_argument("-o", "--output", type=str)
args = parser.parse_args()

# ==================== Set Up ====================

# Read input and output names if provided
if args.input is None:
  print("ERROR: No input argument provided")
  print("       Run as: python DrawUpgradeRelativeError -i <input_file_name> (-i <output_file_basename>)")
  exit(1)
else:
  name = args.input

if args.output is None:
  outNameBase = "blarb"
else:
  outNameBase = args.output

# Set up Drawing tools & samples
mc      = ROOT.DataSample(name)
draw    = ROOT.DrawingTools(name)

# Set up experiment and runs
exper = ROOT.Experiment("nd280")

run13 = ROOT.SampleGroup("run13")
run13.AddMCSample("magnet", mc);  
run13.AddDataSample(mc);

exper.AddSampleGroup("run13", run13);

# Options
saveCanvasAsC = False

# ==================== PlotRelativeErrors ====================

def PlotRelativeErrors(SampleName="TPCmu", AccumBranch="accum_level[][0]", VarName="selmu_mom", BinDef=[[100,0,5000]], outName="blarb"):

  # Set up canvas and output file
  canvas = ROOT.TCanvas()
  canvas.Print(outName+'.pdf[')

  # For each sample, draw plot
  for s,Sample in enumerate(SampleName):
    for v,Var in enumerate(VarName):

      draw.SetTitleX(Sample+' '+Var)

      draw.DrawRelativeErrors(exper, Var, BinDef[s][v][0], BinDef[s][v][1], BinDef[s][v][2], AccumBranch[s]+'>=7')
      
      canvas.Update()
      canvas.Print(outName+'.pdf')
      if bool(saveCanvasAsC):
        canvas.Print(outName+'_'+Sample+'_'+Var+'.C')
      canvas.Clear()

  canvas.Print(outName+'.pdf]')


# ==================== Main ====================

# if __name__ == "__main__":

# Set up arrays
SampleName = ["TPCmu", "HATmu", "SFGmu"]
AccumBranch = ["accum_level[][0]", "accum_level[][1]", "accum_level[][2]"]
VarName = ["selmu_mom", "selmu_direction2"]
  # BinDef is by [Sample][Variable]
BinDef = [
  [ [20,0,5000], [20,-1,1] ], # TPCmu
  [ [20,0,5000], [20,-1,1] ], # HATmu
  [ [20,0,600], [20,-1,1] ] # SFGmu

]

# Safety checks
if len(SampleName) != len(AccumBranch):
  print("WARNING: Lengths of SampleName and AccumBranch do not match -> exiting")
  exit(1)

if len(BinDef) != len(SampleName):
  print("WARNING: BinDef contains more or fewer sample entries than needed -> exiting")
  exit(1)

for s,Sample in enumerate(SampleName):
  if len(BinDef[s]) != len(VarName):
    print("WARNING: BinDef contains more or fewer variable entries than needed for sample "+Sample+" -> exiting")
    exit(1)

# Make plots

PlotRelativeErrors(SampleName, AccumBranch, VarName, BinDef, outNameBase+"_PlotRelativeErrors")