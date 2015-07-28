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

      -- create mini batches from the data
      local datasize =math.min(trainData:size()-t+1,opt.batchSize)
      if datasize>0 then
         local inputs = trainData.data:narrow(1,t,datasize)
         local targets = trainData.labels:narrow(1,t,datasize)
         local targets = targets:squeeze(2)

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
            -- Calculate model outputs
            local outputs = model:forward(inputs)
            local err = criterion:forward(outputs, targets)
            f = f + err

            -- -- estimate df/dW
            local df_do = criterion:backward(outputs, targets)
            model:backward(inputs, df_do)
            -- -- -- update confusion
            confusion:batchAdd(outputs, targets)


            -- normalize gradients and f(X)
            gradParameters:div(inputs:size(1))
            f = f/inputs:size(1)

            -- return f and df/dX
            return f,gradParameters
            end
         -- for i = 1,#inputs do

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
