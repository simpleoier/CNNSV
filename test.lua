print '==> defining test procedure'

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

   -- test over test data
   print('==> testing on test set:')
   local inputs = testData.data
   local targets = testData.labels
   local preds = model:forward(inputs)
   print(targets)
   confusion:batchAdd(preds, targets)
   -- end

   -- timing
   time = sys.clock() - time
   time = time / testData:size()
   print("\n==> time to test 1 sample = " .. (time*1000) .. 'ms')

   -- print confusion matrix
   -- print(confusion)
   -- confusion:__tostring__()
   confusion:updateValids()
   print('average row correct: ' .. (confusion.averageValid*100) .. '%')
   print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
   print('global correct: ' .. (confusion.totalValid*100) .. '%')

   -- update log/plot
   testLogger:add{['% mean class accuracy (test set)'] = confusion.totalValid * 100}
   if opt.plot then
      testLogger:style{['% mean class accuracy (test set)'] = '-'}
      testLogger:plot()
   end

   -- averaged param use?
   if average then
      -- restore parameters
      parameters:copy(cachedparams)
   end

   -- next iteration:
   confusion:zero()
end
