--Copyright (C) 2015  Hani Altwaijry
--Released under MIT License
--license available in LICENSE file

require 'torch'
require 'libhtktoth'
require 'xlua'

local htk4th = {}

local help = {
loadhtk = [[Loads a htk file to a torch.Tensor]],
}

htk4th.loadhtk = function(filepath)
                   if not filepath then
                      xlua.error('file path must be supplied',
                                  'htk4th.loadhtk', 
                                  help.loadhtk)
                   end
                   return libreadhtk.loadhtk(filepath)
                end




return htk4th
