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

local trainfbankfilelist = opt.scpfile
local listfile = io.open(trainfbankfilelist, 'r')
while (true) do
    trainData = ReadData(listfile)
    if (trainData:size()>0) then
        shuffle = torch.randperm(trainData:size())
        train()
    else
        break
    end
    collectgarbage()
end
listfile:close()
