-----------------------------------------------------------------------------
-- reading parameters from a txt file, usually trained by TNET or other tools
function modelfromparameterfile()
      local weights,bias,activations
      print("Reading parameters from "..opt.modelPara)
      weights,bias,activations = readModelPara(opt.modelPara)
      ninputs = #weights[1][1]
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
      model:add(nn.Linear(#weights[#weights],noutputs))
      model:add(nn.LogSoftMax())
end

------------------------------------------------------------------------------
-- load a model from a binary file trained by previous torch work or create a new model if could not find a model in save path
function loadmodelfromfile(filename)
      print ('Model found  '..filename)
      model = torch.load(filename)
      -- parameters
      ninputs = model:get(1).weight:size(2)
      -- If our model has already init some layers (typically after training once), we load the outputs
      -- of the layers into the current model, otherwise skip them
      if (model.modules[#model.modules].output:dim() ~= 0)then
         noutputs = model.modules[#model.modules].output:size(2)
      end

      local curhid         -- current hidden layer
      curhid = (model:size()-5)/3+1  -- 5 is the number of input and output layers (Lin, Re, Lin, LogSM)
      if (opt.model=='deepneunet' and curhid<opt.hidlaynb and opt.hidlaynb~=0 and opt.hidlaynb<=#nstates) then
         table.remove(model.modules, #model.modules)
         table.remove(model.modules, #model.modules)
         for i=1, opt.hidlaynb-curhid do
            model:add(nn.Linear(nstates[curhid],nstates[curhid+1]))
            model:add(nn.PReLU(),model:size())
            model:add(nn.BatchNormalization(nstates[curhid+1]))
            curhid = curhid+1
         end
         model:add(nn.Linear(nstates[curhid],noutputs))
         model:add(nn.LogSoftMax())
      elseif (opt.hidlaynb>#nstates) then
         print("Warning: too many layers to build, not enough nstates")
      end
end

------------------------------------------------------------------------------
-- create a new model from scratch with torch.nn
function newmodel()
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
         local curState=1
         model = nn.Sequential()

         -- stage 1 : filter bank -> squashing -> L2 pooling -> normalization
         model:add(nn.SpatialConvolutionMM(nfeats, nstates[curState], filtsizew, filtsizeh))
         model:add(nn.ReLU())
         model:add(nn.SpatialMaxPooling(poolsize,poolsize,poolsize,poolsize))
         curState = curState+1

         -- stage 2 : filter bank -> squashing -> L2 pooling -> normalization
         model:add(nn.SpatialConvolutionMM(nstates[curState-1], nstates[curState], filtsizew, filtsizeh))    -- output size is {nstates[curState], height2-filtsizeh+1, width2-filtsizew+1}
         model:add(nn.ReLU())
         model:add(nn.SpatialMaxPooling(poolsize,poolsize,poolsize,poolsize))                -- output size is {nstates[curState], (height2-filtersizeh+1)/poolsize, (width2-filtersizew+1)/poolsize}
         curState = curState+1

         -- stage 3 : standard 2-layer neural network
         model:add(nn.Reshape(nstates[curState-1]*width2*height2))
         model:add(nn.Linear(nstates[curState-1]*width2*height2,nstates[curState]))
         model:add(nn.ReLU())
         for i = curState,#nstates-1 do
            model:add(nn.Linear(nstates[i], nstates[i+1]))
            model:add(nn.PReLU())
            -- model:add(nn.BatchNormalization(nstates[i+1]))
         end
         model:add(nn.Linear(nstates[#nstates], noutputs))
         model:add(nn.LogSoftMax())


      else
         -- a typical convolutional network, with locally-normalized hidden
         -- units, and L2-pooling

         -- Note: the architecture of this convnet is loosely based on Pierre Sermanet's
         -- work on this dataset (http://arxiv.org/abs/1204.3968). In particular
         -- the use of LP-pooling (with P=2) has a very positive impact on
         -- generalization. Normalization is not done exactly as proposed in
         -- the paper, and low-level (first layer) features are not fed to
         -- the classifier.

         local curState=1
         model = nn.Sequential()

         -- stage 1 : filter bank -> squashing -> L2 pooling -> normalization
         model:add(nn.SpatialConvolutionMM(nfeats, nstates[curState], filtsizew, filtsizeh))    -- output size is {nstates[curState],height-filtsizeh+1, width-filtsizew+1}
         model:add(nn.Tanh())
         model:add(nn.SpatialMaxPooling(poolsize,poolsize,poolsize,poolsize))    -- output size is {nstates[curState], (height-filtersizeh+1)/poolsize, (width-filtersizew+1)/poolsize} as {nstates[curState], height1, width1}
         curState = curState+1

         -- -- stage 2 : filter bank -> squashing -> L2 pooling -> normalization
         model:add(nn.SpatialConvolutionMM(nstates[curState-1], nstates[curState], filtsizew, filtsizeh))      -- output size is {nstates[curState], height1-filtsizeh+1, width1-filtsizew+1}
         model:add(nn.Tanh())
         model:add(nn.SpatialMaxPooling(poolsize,poolsize,poolsize,poolsize))    -- output size is {nstates[curState], (height1-filtersizeh+1)/poolsize, (width1-filtersizew+1)/poolsize} as {nstates[curState], height2, width2}
         curState = curState+1

         -- stage 3 : standard 2-layer neural network
         model:add(nn.Reshape(nstates[curState-1]*width2*height2))
         model:add(nn.Linear(nstates[curState-1]*width2*height2,nstates[curState]))
         model:add(nn.PReLU())
         for i = curState,#nstates-1 do
            model:add(nn.Linear(nstates[i], nstates[i+1]))
            model:add(nn.PReLU())
            -- model:add(nn.BatchNormalization(nstates[i+1]))
         end
         model:add(nn.Linear(nstates[#nstates], noutputs))
         model:add(nn.LogSoftMax())
      end
   elseif opt.model == 'deepneunet' then
      local nhidla
      nhidla = #nstates
      if (opt.hidlaynb~=0) then
         nhidla = math.min(nhidla,opt.hidlaynb)
      end
      model = nn.Sequential()
      model:add(nn.Linear(ninputs,nstates[1]))
      model:add(nn.PReLU())
      model:add(nn.BatchNormalization(nstates[1]))
      for i = 1,nhidla-1 do
         model:add(nn.Linear(nstates[i], nstates[i+1]))
         model:add(nn.PReLU())
         model:add(nn.BatchNormalization(nstates[i+1]))
      end
      model:add(nn.Linear(nstates[nhidla], noutputs))
      model:add(nn.LogSoftMax())
   else

      error('unknown -model')
   end
end

function printmodel()
   print '==> here is the model:'
   print(model)
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
end
