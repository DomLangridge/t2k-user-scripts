import ROOT
import argparse

# ==================== Arguments ====================

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", type=str)  # input (either combined magnet and sand file, or just magnet)
parser.add_argument("-s", "--sand", type=str)   # sand input, if wanting magnet and sand separate
parser.add_argument("-o", "--output", type=str) # output base name
args = parser.parse_args()

if args.input is None:
  print("ERROR: No input argument provided")
  print("       Run as: python DrawUpgradeRelativeError -i <input_file> (-s <separate_sand_file> -o <output_file_basename>)")
  exit(1)

if args.output is not None:
  outNameBase = args.output
else:
  outNameBase = "blarb"

# ==================== Set Up ====================

# Drawing tools
draw = ROOT.DrawingTools(args.input)

# Experiment and runs
exper = ROOT.Experiment("nd280")
run13 = ROOT.SampleGroup("run13")

# MC
mc = ROOT.DataSample(args.input)
run13.AddMCSample("magnet", mc);

if args.sand is not None:
  sand_mc = ROOT.DataSample(args.sand)
  run13.AddMCSample("sand", sand_mc);

run13.AddDataSample(mc);
exper.AddSampleGroup("run13", run13);

# Options
saveCanvasAsC = False

# ==================== PlotEventRate ====================

def PlotEventRate(SampleName="TPCmu", AccumBranch="accum_level[][0]", VarName="selmu_mom", BinDef=[[100,0,5000]], outName="blarb"):

  # Set up canvas and output file
  canvas = ROOT.TCanvas()
  canvas.Print(outName+'.pdf[')

  # For each sample, draw plot
  for s,Sample in enumerate(SampleName):
    for v,Var in enumerate(VarName):

      draw.SetTitleX(Sample+' '+Var)

      draw.Draw(mc, Var, BinDef[s][v][0], BinDef[s][v][1], BinDef[s][v][2], 'all', AccumBranch[s]+'>=7')
      
      canvas.Update()
      canvas.Print(outName+'.pdf')
      if bool(saveCanvasAsC):
        canvas.Print(outName+'_'+Sample+'_'+Var+'.C')
      canvas.Clear()

  canvas.Print(outName+'.pdf]')

# ==================== PlotEventRate2D ====================

def PlotEventRate2D(SampleName="TPCmu", AccumBranch="accum_level[][0]", VarName="selmu_mom", BinDef=[[100,0,5000]], outName="blarb"):

  # Check if this makes sense
  if len(VarName) != 2:
    print("WARNING: VarName doesn't contain two variables -> I'm currently not able to handle this :(")
    print("         Exiting PlotEventRate2D...")
    return None

  # Set up canvas and output file
  canvas = ROOT.TCanvas()
  canvas.Print(outName+'.pdf[')

  # For each sample, draw plot
  for s,Sample in enumerate(SampleName):

    # These need to go "y:x" for some stupid reason
    Var=VarName[1]+':'+VarName[0]

    draw.SetTitle(Sample)
    draw.SetTitleX(VarName[0])
    draw.SetTitleY(VarName[1])

    draw.Draw(mc, Var, BinDef[s][0][0], BinDef[s][0][1], BinDef[s][0][2], BinDef[s][1][0], BinDef[s][1][1], BinDef[s][1][2], 'all', AccumBranch[s]+'>=7', "colz")
    
    canvas.Update()
    canvas.Print(outName+'.pdf')
    if bool(saveCanvasAsC):
      canvas.Print(outName+'_'+Sample+'_'+VarName[0]+'_'+VarName[1]+'.C')
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
  [ [100,0,5000], [100,-1,1] ], # TPCmu
  [ [100,0,5000], [100,-1,1] ], # HATmu
  [ [120,0,600], [100,-1,1] ] # SFGmu

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

PlotEventRate(SampleName, AccumBranch, VarName, BinDef, outNameBase+"_PlotEventRate")

PlotEventRate2D(SampleName, AccumBranch, VarName, BinDef, outNameBase+"_PlotEventRate2D")