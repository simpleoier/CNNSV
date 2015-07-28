print '==> executing all'

dofile 'init.lua'
dofile 'data.lua'
dofile 'model.lua'
dofile 'loss.lua'
dofile 'train.lua'
-- dofile 'test.lua'

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

-- print(model:size())
-- trainData = ReadData(listfile)
-- for i=1,3 do
--     shuffle = torch.randperm(trainData:size())
--     train()
--     print(parameters:size())
--     print(parameters[3],parameters[30],parameters[300],parameters[3000],parameters[30000])
--     --print(model:get(1).weight:size())
--     print(model:get(1).weight[1][3],model:get(1).weight[1][30],model:get(1).weight[1][300],model:get(1).weight[3][360],model:get(1).weight[23][960])
--     parameters[3] = 100
--     print(parameters[3],parameters[30],parameters[300],parameters[3000],parameters[30000])
--     --print(model:get(1).weight:size())
--     print(model:get(1).weight[1][3],model:get(1).weight[1][30],model:get(1).weight[1][300],model:get(1).weight[3][360],model:get(1).weight[23][960])
-- end
-- listfile:close()
