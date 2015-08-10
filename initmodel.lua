package.path = '/slfs1/users/hedi7/asr/CNNSV/torchTest/?.lua;' .. package.path

require "init"


-- Get the current modelname
local modelname = opt.ldmodel

local filename = paths.concat(opt.save, opt.ldmodel)
-- Outputs the current model statistics and layers
printmodel()
os.execute('mkdir -p ' .. sys.dirname(filename))
print('==> Initalized model, saving model to '..filename)
torch.save(filename, model)


