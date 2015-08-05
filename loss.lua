----------------------------------------------------------------------
print '==> define loss'

if opt.loss == 'margin' then

   -- This loss takes a vector of classes, and the index of
   -- the grountruth class as arguments. It is an SVM-like loss
   -- with a default margin of 1.

   --criterion = nn.MultiMarginCriterion()
   criterion = nn.MarginCriterion()

elseif opt.loss == 'nll' then

   -- This loss requires the outputs of the trainable model to
   -- be properly normalized log-probabilities, which can be
   -- achieved using a softmax function

   -- model:add(nn.LogSoftMax())

   -- The loss works like the MultiMarginCriterion: it takes
   -- a vector of classes, and the index of the grountruth class
   -- as arguments.

   criterion = nn.ClassNLLCriterion()

elseif opt.loss == 'mse' then

   -- for MSE, we add a tanh, to restrict the model's output
   model:add(nn.Tanh())

   -- The mean-square error is not recommended for classification
   -- tasks, as it typically tries to do too much, by exactly modeling
   -- the 1-of-N distribution. For the sake of showing more examples,
   -- we still provide it here:

   criterion = nn.MSECriterion()
   criterion.sizeAverage = false

   -- Compared to the other losses, the MSE criterion needs a distribution
   -- as a target, instead of an index. Indeed, it is a regression loss!
   -- So we need to transform the entire label vectors:

   if trainData then
      -- convert training labels:
      local trsize = (#trainData.labels)[1]
      local trlabels = torch.Tensor( trsize, noutputs )
      trlabels:fill(0)
      for i = 1,trsize do
         trlabels[{ i,trainData.labels[i] }] = 1
      end
      trainData.labels = trlabels

      -- convert test labels
      local tesize = (#testData.labels)[1]
      local telabels = torch.Tensor( tesize, noutputs )
      telabels:fill(0)
      for i = 1,tesize do
         telabels[{ i,testData.labels[i] }] = 1
      end
      testData.labels = telabels
   end
else
   error('unknown -loss')
end

----------------------------------------------------------------------
print '==> here is the loss function:'
print(criterion)
