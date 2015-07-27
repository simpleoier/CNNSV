# Training a DNN for speaker verification with torch
## Do preparedata.lua for data preparation
Training
th traindoall.lua -scpfile fbanklist -modelPara sampleModelParameters(train)

Test
th testdoall.lua  -scpfile fbanklist -modelPara sampleModelParameters(test)
