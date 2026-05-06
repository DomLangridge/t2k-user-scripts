#!/bin/bash -l

# DL: This is a script to make MaCh3's ND280 predictive overlay plots nicer.
# You'll first need to save each plot as a .C file as well as a pdf, which needs to be done in the MaCh3 nd280 code itself.
# Then you can run this, using a directory full of these files as an input argument.
# -----     WARNING: RUN THIS ON A DIRECTORY THAT CONTAINS .C FILES *ONLY*      -----
# ----- YOU REALLY DON"T WANT TO ACCIDENTALLY FUCK UP ANY OTHER CODE USING THIS -----

FILEPATH=$1

cd $FILEPATH

PDFSAVE_SEARCH="canvas->SetSelected(canvas);"

PDFSAVE_REPLACE="
  canvas->SetSelected(canvas);
  const char* FileName = __FILE__;
  std::string OutputName = FileName;

  size_t start_pos = OutputName.find(".C");
  OutputName.replace(start_pos, 2, "_plot.pdf");

  if (OutputName != FileName) {
    canvas->SaveAs(OutputName.c_str(), "pdf");
  }
"

for file in ${FILEPATH}/*; do

  sed -i "s|-nan|std::numeric_limits<double>::quiet_NaN()|" $file

  sed -i "s|canvas->SetGrid|//canvas->SetGrid|" $file
  sed -i "s|pad1->SetGrid|//pad1->SetGrid|" $file
  sed -i "s|pad2->SetGrid|//pad2->SetGrid|" $file

  sed -i "s|$PDFSAVE_SEARCH|$PDFSAVE_REPLACE|" $file

done