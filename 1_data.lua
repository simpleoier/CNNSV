require 'torch'   -- torch
require 'os'   --
require 'nn'      -- provides a normalization operator
print("read data")
----------------------------------------------------------------------
function readfbank(filename,frameindex)
   file = io.open(filename, 'r')
   if not(file) then
      print("Error "..filename.." does not exist")
      return 0
   end
   for line in file:lines() do
      trlines[#trlines+1] = line
   end
   file:close()
end

function parsefbank(lines)
   for i = 1,#lines do
      tb = {}
      for k, v in string.gmatch(lines[i], "%S*") do
         if 0~=string.len(k) then
            tb[#tb+1] = tonumber(k)
         end
      end
      trlabels[i] = tb[1]
      for j = 2,#tb do
         trdata[i][j-1] = tb[j];
      end
   end
end

trlines = {}
local trainfbankfilelist = opt.scpfile
local listfile = io.open(trainfbankfilelist, 'r')
for line in listfile:lines() do
   local fbankfilename = line
   readfbank(fbankfilename)
end

trdata = torch.Tensor(#trlines, ninputs)
trlabels = torch.Tensor(#trlines,1)
-- tedata = torch.Tensor(#telines, ninputs)
-- telabels = torch.Tensor(#telines,1)

parsefbank(trlines)
-- print(trlabels)

trainData = {
   data = trdata,
   labels = trlabels,
   size = function() return trsize end
}
-- testData = {
--    data = tedata,
--    labels = telabels,
--    size = function() return tesize end
-- }
