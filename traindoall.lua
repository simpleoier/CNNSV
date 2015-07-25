-- require 'torch'
----------------------------------------------------------------------
print '==> executing all'

dofile 'init.lua'
dofile 'data.lua'
dofile 'model.lua'
dofile 'loss.lua'
dofile 'train.lua'
dofile 'test.lua'

----------------------------------------------------------------------
print '==> training!'

trainReadData()

for i = 1, opt.MaxEpochs do
   train()
end
