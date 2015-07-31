----------------------------------------------------------------------

local weights,bias,activations
if (opt.modelPara~='') then
   print("Reading parameters from "..opt.modelPara)
   weights,bias,activations = readModelPara(opt.modelPara)
   model = nn.Sequential()
   for i=1,#weights do
      if (i==1) then
         model:add(nn.Linear(ninputs,#weights[1]))
      else
         model:add(nn.Linear(#weights[i-1],#weights[i]))
      end
      model:get(2*i-1).bias = torch.Tensor(bias[i])
      model:get(2*i-1).weight = torch.Tensor(weights[i])
      if (activations[i]=='sigmoid') then
         model:add(nn.Sigmoid())
      elseif (activations[i]=='softmax') then
         model:add(nn.SoftMax())
      elseif (activations[i]=='relu') then
         model:add(nn.ReLU())
      end
   end
   -- model:add(nn.Linear(#weights[#weights],noutputs))
   -- model:add(nn.LogSoftMax())
end
if (model==nil) then
   print '==> load model'

   local filename = paths.concat(opt.save, opt.ldmodel)
   model = io.open(filename, 'rb')

   if (model) then
      print ('find model '..filename)
      model:close()
      model = torch.load(filename)
      local curhid
      curhid = (model:size()-4)/3+1  -- 4 is the number of input and output layers (Lin, Re, Lin, LogSM)
      if (opt.model=='deepneunet' and curhid<opt.hidlaynb) then 
         for i=1, opt.hidlaynb-curhid do
            model:insert(nn.Linear(nstates[curhid],nstates[curhid+1]),model:size()-1)
            model:insert(nn.PReLU(),model:size()-1)
            model:insert(nn.BatchNormalization(nstates[curhid+1]),model:size()-1)
            curhid = curhid+1
         end
      end
      print(model)
   else
      print ('==> model in '..filename..' is not found')
      print '==> construct model'

      if opt.model == 'linear' then

         -- Simple linear model
         model = nn.Sequential()
         model:add(nn.Reshape(ninputs))
         model:add(nn.Linear(ninputs,noutputs))

      elseif opt.model == 'mlp' then

         -- Simple 2-layer neural network, with tanh hidden units
         model = nn.Sequential()
         model:add(nn.Reshape(ninputs))
         model:add(nn.Linear(ninputs,nhiddens))
         model:add(nn.Tanh())
         model:add(nn.Linear(nhiddens,noutputs))

      elseif opt.model == 'convnet' then

         if opt.type == 'cuda' then
            -- a typical modern convolution network (conv+relu+pool)
            model = nn.Sequential()

            -- stage 1 : filter bank -> squashing -> L2 pooling -> normalization
            model:add(nn.SpatialConvolutionMM(nfeats, nstates[1], filtsize, filtsize))
            model:add(nn.ReLU())
            model:add(nn.SpatialMaxPooling(poolsize,poolsize,poolsize,poolsize))

            -- stage 2 : filter bank -> squashing -> L2 pooling -> normalization
            model:add(nn.SpatialConvolutionMM(nstates[1], nstates[2], filtsize, filtsize))
            model:add(nn.ReLU())
            model:add(nn.SpatialMaxPooling(poolsize,poolsize,poolsize,poolsize))

            -- stage 3 : standard 2-layer neural network
            model:add(nn.View(nstates[2]*filtsize*filtsize))
            model:add(nn.Dropout(0.5))
            model:add(nn.Linear(nstates[2]*filtsize*filtsize, nstates[3]))
            model:add(nn.ReLU())
            model:add(nn.Linear(nstates[3], noutputs))

         else
            -- a typical convolutional network, with locally-normalized hidden
            -- units, and L2-pooling

            -- Note: the architecture of this convnet is loosely based on Pierre Sermanet's
            -- work on this dataset (http://arxiv.org/abs/1204.3968). In particular
            -- the use of LP-pooling (with P=2) has a very positive impact on
            -- generalization. Normalization is not done exactly as proposed in
            -- the paper, and low-level (first layer) features are not fed to
            -- the classifier.

            model = nn.Sequential()

            -- stage 1 : filter bank -> squashing -> L2 pooling -> normalization
            model:add(nn.SpatialConvolutionMM(nfeats, nstates[1], filtsize, filtsize))
            model:add(nn.Tanh())
            model:add(nn.SpatialLPPooling(nstates[1],2,poolsize,poolsize,poolsize,poolsize))
            model:add(nn.SpatialSubtractiveNormalization(nstates[1], normkernel))

            -- stage 2 : filter bank -> squashing -> L2 pooling -> normalization
            model:add(nn.SpatialConvolutionMM(nstates[1], nstates[2], filtsize, filtsize))
            model:add(nn.Tanh())
            model:add(nn.SpatialLPPooling(nstates[2],2,poolsize,poolsize,poolsize,poolsize))
            model:add(nn.SpatialSubtractiveNormalization(nstates[2], normkernel))

            -- stage 3 : standard 2-layer neural network
            model:add(nn.Reshape(nstates[2]*filtsize*filtsize))
            model:add(nn.Linear(nstates[2]*filtsize*filtsize, nstates[3]))
            model:add(nn.Tanh())
            model:add(nn.Linear(nstates[3], noutputs))
         end
      elseif opt.model == 'deepneunet' then
         local nhidla
         nhidla = math.min(#nstates,opt.hidlaynb)
         model = nn.Sequential()
         model:add(nn.Linear(ninputs,nstates[1]))
         model:add(nn.PReLU())
         for i = 1,nhidla-1 do
            model:add(nn.Linear(nstates[i], nstates[i+1]))
            model:add(nn.PReLU())
            model:add(nn.BatchNormalization(nstates[i+1]))
         end
         model:add(nn.Linear(nstates[nhidla], noutputs))
         model:add(nn.LogSoftMax())

         print(model)
      else

         error('unknown -model')

      end
   end
end
----------------------------------------------------------------------
print '==> here is the model:'
print(model)

----------------------------------------------------------------------
-- Visualization is quite easy, using itorch.image().

if opt.visualize then
   if opt.model == 'convnet' then
      if itorch then
     print '==> visualizing ConvNet filters'
     print('Layer 1 filters:')
     itorch.image(model:get(1).weight)
     print('Layer 2 filters:')
     itorch.image(model:get(5).weight)
      else
     print '==> To visualize filters, start the script in itorch notebook'
      end
   end
end
