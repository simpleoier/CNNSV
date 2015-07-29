print '==> executing all'

dofile 'init.lua'
dofile 'data.lua'
dofile 'model.lua'
dofile 'loss.lua'
dofile 'train.lua'
-- dofile 'test.lua'

----------------------------------------------------------------------
print '==> training!'

-- Check if the scpfile argument is given and the scpfile can be found
if not opt.scpfile then
    error("Please specify a file containing the data with -scpfile")
    return
elseif io.open(opt.scpfile,"rb") == nil then
    error(string.format("Given scp file %s cannot be found!",opt.scpfile))
    return
end
-- correct = 0
-- wrong = 0
local trainfbankfilelist = opt.scpfile
local listfile = io.open(trainfbankfilelist, 'r')
trainData = readData(listfile)
while (true) do
    if (trainData:size()>0) then
        local shuffleddata = torch.randperm(trainData:size())
        train(shuffleddata)
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

