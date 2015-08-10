print '==> executing all'
-- Extend the path so that this script can be used from other folders
-- Parses the input arguments and sets the variables for the model and certain other variables such as:
-- model : The Neural network model
-- opt : The parsed arguments from the command line
require 'init'
require 'loss'
require 'train'
-- dofile 'test.lua'

----------------------------------------------------------------------
print '==> training!'

function mainfeat()
    local trainfeatfile = opt.featfile
    local featfile = io.open(trainfeatfile, 'r')
    while (true) do
        trainData = readDataFeat(featfile)
        if (trainData:size()>0) then
            local shuffleddata = torch.randperm(trainData:size())
            train(shuffleddata)
        else
            break
        end
        collectgarbage()
    end
    featfile:close()

    print('==> final results')
    confusion:updateValids()
    print('average row correct: ' .. (confusion.averageValid*100) .. '%')
    print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
    print('global correct: ' .. (confusion.totalValid*100) .. '%')
end

function mainscp()
    readLabel(opt.labelfile)
    local means, variances
    if (opt.globalnorm~='') then
        means, variances = readglobalnorm(opt.globalnorm)
    end
    if (opt.scpfile~='') then
    	local trainfeatfilelist = opt.scpfile
    	local listfile = io.open(trainfeatfilelist, 'r')
    	while (true) do
            trainData = readDataScp2(listfile, opt.filenum, means, variances)
            if (trainData~=nil) then
            	local shuffleddata = torch.randperm(trainData:size())
            	train(shuffleddata)
            else
            	break
            end
            collectgarbage()
        end
    	listfile:close()

    	print('==> final results')
    	confusion:updateValids()
    	print('average row correct: ' .. (confusion.averageValid*100) .. '%')
    	print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
    	print('global correct: ' .. (confusion.totalValid*100) .. '%')
    end

    -- cross validation
    if (opt.cvscpfile~='') then
        print("\n==> cross validation")
        confusion:zero()
        local cvfeatfilelist = opt.cvscpfile
        local listfile = io.open(cvfeatfilelist, 'r')
        while (true) do
            cvData = readDataScp2(listfile,opt.filenum)
            if (cvData~=nil) then
                crossValidate()
            else
                break
            end
            collectgarbage()
        end
        listfile:close()

        confusion:updateValids()
        print('average row correct: ' .. (confusion.averageValid*100) .. '%')
        print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
        print('global correct: ' .. (confusion.totalValid*100) .. '%')
        print('global correct: ' .. (confusion.totalValid*100) .. '%')
    end

end

-- Check if the scpfile argument is given and the scpfile can be found
if (opt.scpfile=='') and (opt.featfile=='') and (opt.cvscpfile=='') then
    error("Please specify a file containing the data with -scpfile or Please specify a file containing the data with -fbankfile")
    return
elseif (opt.scpfile~='' or opt.cvscpfile~='') then
        mainscp()
elseif (opt.featfile~='') then
    if io.open(opt.featfile,"rb") == nil then
        error(string.format("Given feature file %s cannot be found!",opt.featfile))
        return
    else
        mainfeat()
    end
end

-- if not opt.featfile then
--     error("Please specify a file containing the data with -fbankfile")
--     return
-- elseif io.open(opt.featfile,"rb") == nil then
--     error(string.format("Given feature file %s cannot be found!",opt.featfile))
--     return
-- end

-- local trainfeatfile = opt.featfile
-- local featfile = io.open(trainfeatfile, 'r')
-- while (true) do
--     trainData = readData(featfile)
--     if (trainData:size()>0) then
--         local shuffleddata = torch.randperm(trainData:size())
--         train(shuffleddata)
--     else
--         break
--     end
--     collectgarbage()
-- end
-- featfile:close()

-- confusion:updateValids()
-- print('average row correct: ' .. (confusion.averageValid*100) .. '%')
-- print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
-- print('global correct: ' .. (confusion.totalValid*100) .. '%')
