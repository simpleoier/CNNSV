print '==> executing all'
-- Extend the path so that this script can be used from other folders
-- Parses the input arguments and sets the variables for the model and certain other variables such as:
-- model : The Neural network model
-- opt : The parsed arguments from the command line
require 'init'
require 'loss'
require 'train'
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
    -- reading labels from label file
    readLabel(opt.labelfile)
    -- reading means and variances from global norm
    local means, variances
    if (opt.globalnorm~='') then
        means, variances = readglobalnorm(opt.globalnorm)
    end
    -- training
    if (opt.scpfile~='') then
        -- reading data file names
    	local trainfeatfilelist = opt.scpfile
    	local listfile = io.open(trainfeatfilelist, 'r')
    	while (true) do
            trainData = readDataScp2(listfile, opt.filenum, means, variances)
	    -- training procedure
            if (trainData~=nil) then
            	local shuffleddata = torch.randperm(trainData:size())
            	train(shuffleddata)
            else
            	break
            end
            collectgarbage()
        end
    	listfile:close()

    	print('==> final results on Iteration # '..trainIter)
        acclog:write('==> final results of Iteration # ' .. trainIter .. '\n')
    	confusion:updateValids()
    	print('average row correct: ' .. (confusion.averageValid*100) .. '%')
    	print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
    	print('global correct: ' .. (confusion.totalValid*100) .. '%')
	acclog:write('global correct: ' .. (confusion.totalValid*100) .. '%\n')
	-- store the file names of data tensors
	local filename = paths.concat(opt.save, opt.tensorList)
        local tensorf = {
	    list = tensorList,
	    cvind = #tensorList
        }
	cvind = #tensorList
	torch.save(filename, tensorf)
    end
    local index = #tensorList	-- where the training data ends

    -- cross validation
    if (opt.cvscpfile~='') then
        print("\n==> cross validation on Iteration #"..trainIter)
	acclog:write("\n==> cross validation on Iteration #"..trainIter .. '\n')
        confusion:zero(); setnum = 0
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
	acclog:write('global correct: ' .. (confusion.totalValid*100) .. '%\n')
    end
    local filename = paths.concat(opt.save,opt.tensorList)
    local tensorf = {
	list = tensorList,
	cvind = index
    }
    torch.save(filename, tensorf)
end

function mainTensor()
    cvind = cvind or 0
    confusion:zero(); epoch = 0;
    for i=1,cvind do
	trainData = readDataTensor(tensorList[i])
	local shuffleddata = torch.randperm(trainData:size())
	train(shuffleddata)
    end
    print('==> final results of Iteration # ' .. trainIter)
    acclog:write('==> final results of Iteration # ' .. trainIter..'\n')
    confusion:updateValids()
    print('average row correct: ' .. (confusion.averageValid*100) .. '%')
    print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
    print('global correct: ' .. (confusion.totalValid*100) .. '%')
    acclog:write('global correct: ' .. (confusion.totalValid*100) .. '%\n')
    
    print("\n==> cross validation of Iteration # " .. trainIter)
    confusion:zero(); setnum = 0;
    for i=cvind+1,#tensorList do
	cvData = readDataTensor(tensorList[i])
	crossValidate()
    end
    print('==> final results of Iteration # ' .. trainIter)
    acclog:write('==> final results of Iteration # ' .. trainIter .. '\n')
    confusion:updateValids()
    print('average row correct: ' .. (confusion.averageValid*100) .. '%')
    print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
    print('global correct: ' .. (confusion.totalValid*100) .. '%')
    acclog:write('global correct: ' .. (confusion.totalValid*100) .. '%\n')
end
-- Check if the scpfile argument is given and the scpfile can be found
for i=1,opt.trainIter do
    acclog = io.open(paths.concat(opt.save, 'acc.log'),'a')
    trainIter = i
    if (opt.scpfile=='') and (opt.featfile=='') and (opt.cvscpfile=='') and (tensorList=={}) then
        error("Please specify a file containing the data with -scpfile or Please specify a file containing the data with -fbankfile")
        return
    elseif (#tensorList~=0) then
        mainTensor()
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
    local filename1 = paths.concat(opt.save, 'model.net')
    local filename2 = paths.concat(opt.save, 'model'..trainIter..'.net')
    os.execute('cp ' .. filename1 .. ' ' .. filename2)
    print('cp ' .. filename1 .. ' ' .. filename2)
    acclog:write("copy model of Iteration # " .. trainIter .. " to " .. filename2 .. '\n')
    acclog:close()
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
