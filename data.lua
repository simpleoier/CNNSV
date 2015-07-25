-- require 'torch'   -- torch
-- require 'os'   --
-- require 'nn'      -- provides a normalization operator
math.randomseed(os.time())
print("read data")
----------------------------------------------------------------------
function readfbank(filename, lines)
   file = io.open(filename, 'r')
   if not(file) then
      print("Error "..filename.." does not exist")
      return 0
   end
   for line in file:lines() do
      lines[#lines+1] = line
   end
   file:close()
   return lines
end

function parsefbank(lines, data, labels)
   for i = 1,#lines do
      tb = {}
      for k, v in string.gmatch(lines[i], "%S*") do
         if 0~=string.len(k) then
            tb[#tb+1] = tonumber(k)
         end
      end
      labels[i] = tb[1]

      -- r = math.random()
      -- if (r<0.3) then
      --    labels[i] = 2
      --    sum = sum+1
      -- end

      for j = 2,#tb do
         data[i][j-1] = tb[j];
      end
   end
end

function trainReadData()
   trlines = {}
   local trainfbankfilelist = opt.scpfile
   local listfile = io.open(trainfbankfilelist, 'r')
   for line in listfile:lines() do
      local fbankfilename = line
      readfbank(fbankfilename, trlines)
   end

   trdata = torch.Tensor(#trlines, ninputs)
   trlabels = torch.Tensor(#trlines,1)

   parsefbank(trlines, trdata, trlabels)
-- print(trlabels)
   trainData = {
      data = trdata,
      labels = trlabels,
      size = function() return trsize end
   }
end

function testReadData()
   telines = {}
   local testfbankfilelist = opt.scpfile
   local listfile = io.open(testfbankfilelist, 'r')
   for line in listfile:lines() do
      local fbankfilename = line
      readfbank(fbankfilename, telines)
   end

   tedata = torch.Tensor(#telines, ninputs)
   telabels = torch.Tensor(#telines,1)

   parsefbank(telines, tedata, telabels)
-- print(trlabels)
   testData = {
      data = tedata,
      labels = telabels,
      size = function() return tesize end
   }
end
