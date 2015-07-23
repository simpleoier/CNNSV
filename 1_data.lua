require 'torch'   -- torch
require 'os'   -- for color transforms
require 'nn'      -- provides a normalization operator

----------------------------------------------------------------------
-- parse command line arguments
if not opt then
   print '==> processing options'
   cmd = torch.CmdLine()
   cmd:text()
   cmd:text('Speaker Verification with DNN')
   cmd:text()
   cmd:text('Options:')
   --cmd:option('-size', 'small', 'how many samples do we load: small | full | extra')
   --cmd:option('-visualize', true, 'visualize input data and weights during training')
   cmd:text()
   opt = cmd:parse(arg or {})
end

trsize = 90256
tesize = 30286
trdata = torch.Tensor(trsize,23)
trlabels = torch.Tensor(trsize,1)
tedata = torch.Tensor(tesize,23)
telabels = torch.Tensor(tesize,1)

cur_line = 1
file = io.open('/media/chao/Study/3rd(Spring)/机器学习/project/data/feature/train_1','r')
for line in file:lines() do
   lb = tonumber(string.sub(line,1,1));
   -- trlabels[cur_line][lb+1] = 1
   -- trlabels[cur_line][2-lb] = 0
   trlabels[cur_line] = lb+1
   line = string.sub(line,3)
   for i = 1,22 do
      s,e = string.find(line,":")
      line = string.sub(line,e+1)
      s,e = string.find(line," ")
      trdata[cur_line][i] = string.sub(line,1,e-1)
      line = string.sub(line,e+1)
   end
   s,e = string.find(line,":")
   line = string.sub(line,e+1)
   trdata[cur_line][23] = string.sub(line,1)
   cur_line = cur_line+1
end
file:close()
cur_line = 1
file = io.open('/media/chao/Study/3rd(Spring)/机器学习/project/data/feature/train_2','r')
for line in file:lines() do
   lb = tonumber(string.sub(line,1,1));
   --trlabels[cur_line][lb+1] = 1
   --trlabels[cur_line][2-lb] = 0
   trlabels[cur_line] = lb+1
   line = string.sub(line,3)
   for i = 1,22 do
      s,e = string.find(line,":")
      line = string.sub(line,e+1)
      s,e = string.find(line," ")
      tedata[cur_line][i] = string.sub(line,1,e-1)
      line = string.sub(line,e+1)
   end
   s,e = string.find(line,":")
   line = string.sub(line,e+1)
   tedata[cur_line][23] = string.sub(line,1)
   cur_line = cur_line+1
end
file:close()

trainData = {
   data = trdata,
   labels = trlabels,
   size = function() return trsize end
}
testData = {
   data = tedata,
   labels = telabels,
   size = function() return tesize end
}
