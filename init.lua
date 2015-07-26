require 'torch'   -- torch
require 'os'   --
require 'nn'      -- provides a normalization operator
require 'xlua'    -- xlua provides useful tools, like progress bars
require 'optim'   -- an optimization package, for online and batch methods

if not (opt) then
    cmd = torch.CmdLine()
    cmd:text()
    cmd:text('Speaker Verification with DNN')
    cmd:text()
    cmd:text('Options:')
    -- filelist:
    cmd:option('-scpfile', '', 'name a file storing all the filenames of data')
    -- global:
    cmd:option('-seed', 1, 'fixed input seed for repeatable experiments')
    cmd:option('-threads', 2, 'number of threads')
    -- data:
    cmd:option('-size', 'full', 'how many samples do we load: small | full | extra')
    -- model:
    cmd:option('-model', 'deepneunet', 'type of model to construct: linear | mlp | convnet | deepneunet')
    cmd:option('-model', 'deepneunet', 'type of model to construct: linear | mlp | convnet | deepneunet')
    -- loss:
    cmd:option('-loss', 'nll', 'type of loss function to minimize: nll | mse | margin')
    -- training:
    cmd:option('-save', 'results', 'subdirectory to save/log experiments in')
    cmd:option('-plot', false, 'live plot')
    cmd:option('-optimization', 'SGD', 'optimization method: SGD | ASGD | CG | LBFGS')
    cmd:option('-learningRate', 1e-3, 'learning rate at t=0')
    cmd:option('-batchSize', 10, 'mini-batch size (1 = pure stochastic)')
    cmd:option('-weightDecay', 0, 'weight decay (SGD only)')
    cmd:option('-momentum', 0, 'momentum (SGD only)')
    cmd:option('-t0', 1, 'start averaging at t0 (ASGD only), in nb of epochs')
    cmd:option('-maxIter', 2, 'maximum nb of iterations for CG and LBFGS')
    cmd:option('-type', 'double', 'type: double | float | cuda')
    cmd:text()
    opt = cmd:parse(arg or {})
end
print '==> processing options'
-- nb of threads and fixed seed (for repeatable experiments)
if opt.type == 'float' then
   print('==> switching to floats')
   torch.setdefaulttensortype('torch.FloatTensor')
elseif opt.type == 'cuda' then
   print('==> switching to CUDA')
   require 'cunn'
   torch.setdefaulttensortype('torch.FloatTensor')
end
--torch.setnumthreads(opt.threads)
torch.manualSeed(opt.seed)
print '==> define parameters'

-- trsize = 181
-- tesize = 181
--featdim = 1320
noutputs = 2910
-- input dimensions
--nfeats = 3
--width = 32
--height = 32
--ninputs = nfeats*width*height
ninputs = 1320
-- number of hidden units (for MLP only):
nhiddens = ninputs / 2
-- hidden units, filter sizes (for ConvNet only):
nstates = {1024, 1024, 1024, 1024}
--filtsize = 5
--poolsize = 2
-- classes
classes = {}
for i=1,noutputs do
  classes[#classes+1] = ''..i
end

sum = 0

-- This matrix records the current confusion across classes
confusion = optim.ConfusionMatrix(classes)

-- Log results to files
trainLogger = optim.Logger(paths.concat(opt.save, 'train.log'))
testLogger = optim.Logger(paths.concat(opt.save, 'test.log'))
