-- require 'torch'   -- torch
-- require 'os'   --
-- require 'nn'      -- provides a normalization operator
math.randomseed(os.time())
----------------------------------------------------------------------
function readfbank(filename, lines)
   local file = io.open(filename, 'r')
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

function ReadData(listfile)
   local lines = {}
   local curlinenum = 0
   while (curlinenum<10) do
      local line = listfile:read()
      if (line~=nil) then
         local fbankfilename = line
         readfbank(fbankfilename, lines)
      else
         break
      end
   end

   local tdata = torch.Tensor(#lines, ninputs)
   local tlabels = torch.Tensor(#lines,1)

   parsefbank(lines, tdata, tlabels)
-- print(trlabels)
   local Data = {
      data = tdata,
      labels = tlabels,
      size = function() return #lines end
   }
   return Data
end
