print '==> defining test procedure'
-- -- classes
classes = {}
for i=1,noutputs do
  classes[i] = ''..i
end
-- -- This matrix records the current confusion across classes
confusionBatch = optim.ConfusionMatrix(classes)
confusion = optim.ConfusionMatrix(classes)
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

   -- test over test data
   print('==> testing on test set')

   local preds = model:forward(inputs)
   if (opt.crossvalid==0) then
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
   else
      correct = correct or 0
      wrong = wrong or 0
      for i=1,inputs:size(1) do
         local maxindex,maxpred
         maxindex = 1
         maxpred = preds[i][1]
         for j=2,preds:size(2) do
            if preds[i][j]>maxpred then
               maxpred = preds[i][j]
               maxindex = j
            end
         end
         if (maxindex==targets[i]) then
            correct = correct+1
         else
            wrong = wrong+1
         end
      end
      confusion:batchAdd(preds, targets)
      confusionBatch:batchAdd(preds, targets)
         -- print confusion matrix
      -- print(confusion)
      -- confusion:__tostring__()
      confusion:updateValids()
      print('average row correct: ' .. (confusion.averageValid*100) .. '%')
      print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
      print('global correct: ' .. (confusion.totalValid*100) .. '%')
      print("correct and wrong "..correct..' '..wrong)

      -- update log/plot
      testLogger:add{['% mean class accuracy (test set)'] = confusion.totalValid * 100}
      if opt.plot then
         testLogger:style{['% mean class accuracy (test set)'] = '-'}
         testLogger:plot()
      end

      confusionBatch:zero()
   end
   -- timing
   time = sys.clock() - time
   time = time / testData:size()
   print("\n==> time to test 1 sample = " .. (time*1000) .. 'ms')

   -- averaged param use?
   if average then
      -- restore parameters
      parameters:copy(cachedparams)
   end

end
