-- require 'torch'
----------------------------------------------------------------------
print '==> executing all'

dofile 'init.lua'
dofile 'data.lua'
dofile 'model.lua'
dofile 'loss.lua'
-- dofile 'train.lua'
dofile 'test.lua'
----------------------------------------------------------------------
print(" ==> testing")

local trainfbankfilelist = opt.scpfile
local listfile = io.open(trainfbankfilelist, 'r')
while (true) do
    if (testData:size()>0) then
        testData = ReadData(listfile)
        test()
    else
        break
    end
    collectgarbage()
end
listfile:close()
