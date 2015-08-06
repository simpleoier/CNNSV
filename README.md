# Training a DNN for speaker verification with torch

## Do preparedata.lua for data preparation
Training
th trainmain.lua -scpfile fbanklist -modelPara sampleModelParameters(train)

Test
th testdoall.lua  -scpfile fbanklist -modelPara sampleModelParameters(test)

#on gauss the location of torch is /slfs1/users/xkc09/TOOLS/torch/install/bin/th

