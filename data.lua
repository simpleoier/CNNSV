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

function readLabel(filename)
   filelabel = {}
   if (filename~='') then
      local fin = io.open(filename,'r')
      for line in fin:lines() do
         local l = line:split(' ')
         filelabel[l[1]] = tonumber(l[2])
      end
   end
end

function readDataFeat(featfile)
   print('==> reading feature from '..opt.featfile)
   local lines = {}
   local curlinenum = 0
   while (curlinenum<opt.maxrows) do
      curlinenum = curlinenum+1
      local line = featfile:read()
      if (line~=nil) then
         lines[#lines+1] = line
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

function readDataScp1(listfile,filenum)
   local lines = {}
   local curlinenum = 0
   while (curlinenum<filenum) do
      curlinenum = curlinenum+1
      local line = listfile:read()
      if (line~=nil) then
         local fbankfilename = line
         print("Reading feature from "..fbankfilename)
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

function readDataScp2(listfile,filenum)
   local feats = {}
   local labels = {}
   local curlinenum = 0
   while (curlinenum<filenum) do
      curlinenum = curlinenum+1
      local line = listfile:read()
      if (line~=nil) then
         local filename = paths.basename(line)
         local chunk = filename:split('_')
         print("Reading feature from "..line)
         local feat = loadhtk(line, frameExt)
         for i=1,feat:size(1) do
            feats[#feats+1] = feat[i]
            if (#filelabel~=0) then
               labels[#feats] = filelabel[chunk[1]]
            else
               labels[#feats] = 1
            end
         end
      else
         break
      end
   end
   -- local tdata = torch.Tensor(#lines, ninputs)
   -- local tlabels = torch.Tensor(#lines,1)
   if (#feats==0) then
      return
   end
   local tdata = torch.Tensor(#feats, feats[1]:size(1))
   local tlabels = torch.Tensor(#labels,1)
   for i=1,#feats do
      tdata[i] = feats[i]
      tlabels[i] = labels[i]
   end
   local Data = {
      data = tdata,
      labels = tlabels,
      size = function() return #feats end
   }
   return Data
end
