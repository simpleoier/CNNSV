----------------------------------------------------------------------
-- CUDA?
if opt.type == 'cuda' then
   model:cuda()
   criterion:cuda()
end
----------------------------------------------------------------------
-- Retrieve parameters and gradients:
-- this extracts and flattens all the trainable parameters of the mode
-- into a 1-dim vector
if model then
   parameters,gradParameters = model:getParameters()
end

----------------------------------------------------------------------
print '==> configuring optimizer'

if opt.optimization == 'CG' then
   optimState = {
      maxIter = opt.maxIter
   }
   optimMethod = optim.cg

elseif opt.optimization == 'LBFGS' then
   optimState = {
      learningRate = opt.learningRate,
      maxIter = opt.maxIter,
      nCorrection = 10
   }
   optimMethod = optim.lbfgs

elseif opt.optimization == 'SGD' then
   optimState = {
      learningRate = opt.learningRate,
      weightDecay = opt.weightDecay,
      momentum = opt.momentum,
      learningRateDecay = 1e-7
   }
   optimMethod = optim.sgd

elseif opt.optimization == 'ASGD' then
   optimState = {
      eta0 = opt.learningRate,
      t0 = trsize * opt.t0
   }
   optimMethod = optim.asgd

else
   error('unknown optimization method')
end

----------------------------------------------------------------------
print '==> defining training procedure'

function train(stuffleddata)

   -- epoch tracker
   epoch = epoch or 1

   -- local vars
   local time = sys.clock()

   -- set model to training mode (for modules that differ in training and testing, like Dropout)
   model:training()

   -- shuffle at each epoch
   -- shuffle = torch.randperm(trsize)

   -- do one epoch
   print('==> doing epoch on training data:')
   print("==> online epoch # " .. epoch .. ' [batchSize = ' .. opt.batchSize .. ']')
   for t = 1,trainData:size(),opt.batchSize do
      -- disp progress
      xlua.progress(t, trainData:size())
      -- create mini batch
      -- local inputs = {}
      -- local targets = {}
      -- local inputs = trainData.data:narrow(1, t, math.min(opt.batchSize,trainData:size()-t+1))
      -- local targets = trainData.labels:narrow(1, t, math.min(opt.batchSize,trainData:size()-t+1))
      local inputs = torch.Tensor(math.min(opt.batchSize,trainData:size()-t+1),ninputs)
      local targets = torch.Tensor(math.min(opt.batchSize,trainData:size()-t+1),1)
      for i = t,math.min(t+opt.batchSize-1,trainData:size()) do
         -- load new sample
         local input = trainData.data[shuffle[i]]
         local target = trainData.labels[shuffle[i]]
         if opt.type == 'double' then input = input:double()
         elseif opt.type == 'cuda' then input = input:cuda() end
         inputs[i-t+1] = input
         targets[i-t+1] = target
      end

      targets = targets:squeeze(2)
      -- create closure to evaluate f(X) and df/dX
      local feval = function(x)
         -- get new parameters
         if x ~= parameters then
           parameters:copy(x)
         end

         -- reset gradients
         gradParameters:zero()

         -- f is the average of all criterions
         local f = 0

         -- evaluate function for complete mini batch
         -- for i = 1,inputs:size(1) do
         --    -- estimate f
         --    local output = model:forward(inputs[i])
         --    local err = criterion:forward(output, targets[i])
         --    f = f + err

         --    -- estimate df/dW
         --    local df_do = criterion:backward(output, targets[i])
         --    model:backward(inputs[i], df_do)

         --    -- update confusion
         --    confusion:add(output, targets[i])
         -- end

         local outputs = model:forward(inputs)
         -- for k=1, outputs:size(1) do
         --    -- print(k,targets[k],outputs[k][targets[k]])
         --    print(k,targets[k],outputs[k][1])
         -- end
         -- print(targets:size())
         local err = criterion:forward(outputs, targets)
         f = f + err

         -- estimate df/dW
         local df_do = criterion:backward(outputs, targets)
         model:backward(inputs, df_do)
         -- update confusion
         confusion:batchAdd(outputs, targets)

         -- normalize gradients and f(X)
         gradParameters:div(inputs:size(1))
         f = f/inputs:size(1)
         
         -- optimize on current mini-batch
         if optimMethod == optim.asgd then
            _,_,average = optimMethod(feval, parameters, optimState)
         else
            optimMethod(feval, parameters, optimState)
         end
      end
   end

   -- time taken
   time = sys.clock() - time
   time = time / trainData:size()
   print("\n==> time to learn 1 sample = " .. (time*1000) .. 'ms')

   -- print confusion matrix
   -- print(confusion)
   confusion:updateValids()
   print('average row correct: ' .. (confusion.averageValid*100) .. '%')
   print('average rowUcol correct (VOC measure): ' .. (confusion.averageUnionValid*100) .. '%')
   print('global correct: ' .. (confusion.totalValid*100) .. '%')

   -- update logger/plot
   -- trainLogger:add{['% mean class accuracy (train set)'] = confusion.totalValid * 100}
   if opt.plot then
      trainLogger:style{['% mean class accuracy (train set)'] = '-'}
      trainLogger:plot()
   end

   -- save/log current net
   local filename = paths.concat(opt.save, 'model.net')
   os.execute('mkdir -p ' .. sys.dirname(filename))
   print('==> saving model to '..filename)
   torch.save(filename, model)

   -- next epoch
   confusion:zero()
   epoch = epoch + 1
end
