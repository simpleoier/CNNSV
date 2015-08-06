print '==> defining test procedure'
-- Log results to files
testLogger = optim.Logger(paths.concat(opt.save, 'test.log'))

-- test function
function test()
   -- local vars
   local time = sys.clock()

   -- averaged param use?
   if average then
      cachedparams = parameters:clone()
      parameters:copy(average)
   end

   -- set model to evaluate mode (for modules that differ in training and testing, like Dropout)
   model:evaluate()

   local inputs = testData.data
   local targets = testData.labels

   if opt.type == 'double' then inputs = inputs:double()
   elseif opt.type == 'cuda' then inputs = inputs:cuda() end

   setnum = setnum or 0
   setnum = setnum + 1
   -- test over test data
   print('==> testing on test set'..setnum)

   local preds = model:forward(inputs)
   local lastlayer = #model.modules
   -- Take the output of the layer before the last one
   local botneckout = model.modules[lastlayer-2].output
   local outputpath = paths.concat(opt.save,"features/")
   os.execute('mkdir -p ' .. outputpath)
   print("==> Saving output layer "..(lastlayer-2).." to " .. outputpath)
   local botnecktable = torch.totable(botneckout)
   
   local botneck1d_feat = torch.totable(botneckout:view(botneckout:nElement()))

   local outputfeature = paths.concat(outputpath,filename)
   writehtk(outputfeature,#botnecktable,100000,#botnecktable[1],"USER",botneck1d_feat)
   
   -- timing
   time = sys.clock() - time
   time = time / testData:size()
   print("==> time to test 1 sample = " .. (time*1000) .. 'ms'..'\n')
   
   -- averaged param use?
   if average then
      -- restore parameters
      parameters:copy(cachedparams)
   end

end
