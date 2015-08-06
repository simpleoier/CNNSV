
require "libhtktoth"
require "nn"

-- th preparedata scpfile globalnorm mlffile outputdir
--require 'torch'
function readmlf(filename)
   fin = io.open(filename,'r')
   label = {}
   for line in fin:lines() do
      local l = line:split(' ')
      label[l[1]] = l[2]
   end
end

function parseline(str)
   local t = {}
   for k,v in string.gmatch(str, "%S*") do
      if 0~=string.len(k) then
         t[#t+1] = k
      end
   end
   return t
end

-- Reading in the global transform which is already preprocessed in bash
-- The global transform already has already calcualted the parameters -\mu and 1/\sigma
-- as the mean and the inverse covariance respectively
function readglobaltransf(filename)

   fin = io.open(filename,'r')
   local line = fin:read()
   local line = fin:read()
-- First read in the biases of the transforms, which are useless
-- dim_bias = tonumber(line:split(' ')[2])
-- SOme of the transfiles do not have a linebreak
   local meansstr = {}
   -- transform file was written so that there is no linebreak after the first line
   if((#(line:split(' ')) > 2)) then
      local linesplit = line:split(' ')
      for i=4,#linesplit do
         meansstr[#meansstr+1] = linesplit[i]
      end
   -- Linebreak after the "v XXXXX" line
   else
      line = fin:read()
      meansstr = line:split(' ')
   end
   means = torch.FloatTensor(#meansstr)
   -- Convert all the means to a number
   for i = 1,#meansstr do
      means[i] = tonumber(meansstr[i])
   end
   local line = fin:read()
   line = fin:read()
   -- dim_window is the dimension of the input vector to the dnn
   dim_window = tonumber(line:split(' ')[2])

   line = fin:read()

   local windowstr = {}
   -- We assume having no new line here once again
   if((#(line:split(' ')) > 2))then
      local linesplit = line:split(' ')
      for i=4,#linesplit do
         windowstr[#windowstr+1] = linesplit[i]
      end
   else
      -- One blank line
      local line = fin:read()
      -- Now we got the features
      windowstr = line:split(' ')
   end
   window = torch.FloatTensor(#windowstr)
   -- Reading in the 1/sigma aka variances
   for i = 1,#windowstr do
      window[i] = tonumber(windowstr[i])
   end
   assert(means:size(1) == window:size(1),"Error when loading the global.trans file, meansize "..means:size(1).." does not match variance size ".. window:size(1))
   fin:close()
end

function readfile(inputfile,extframe)
   fin = assert(io.open(inputfile,'r'))
   local htkfeat = loadhtk(inputfile,extframe)
   local featheader = loadheader(inputfile)
   dim_feat = htkfeat:size(2)
   if (dim_feat ~= means:size(1)) then
      print("Feature dimension "..dim_feat.." does not match globalnorm dimension "..means:size(1))
   end
   return htkfeat,featheader
end


-- Writes out the outputfile and normalizes its frames with T-norm
function writefile(outputfile, frame, extframe,htkheader)
   -- Default is 5 frames left and right
   local out_feat = {}
   -- setn(out_feat,n_frames * #means)
   local nsamples = frame:size(1)
   --We extend the frame window left and right by nextframe frames
   local nextframes= frame:size(2)
   local m = nn.Replicate(nsamples)
   -- We use replicate to extend the window size to use the map function (size needs to be equal)
   -- Replicate does not have any extra cost, only resets the stride parameter once we did iterate
   -- Already once over a certain tensor
   local means = m:forward(means)
   local window = m:forward(window)

   -- Apply T-Norm here, T-Norm is defined as:
   -- ss = (ss_old - mu)/cov
   frame:map2(means,window,function(old_frame,mean,cov) return (old_frame+mean)*cov end)
   -- print("Spend " .. te-ts.. "s in normalization")
   -- frame:map2(windows,means)
   out_feat = torch.totable(frame:resize(nsamples*nextframes))

   local newsamplesize = htkheader.nsamples*(2*extframe) + htkheader.nsamples
   -- Remove the crc checksum ...
   local newparmkind = string.gsub(htkheader.parmkind,"_K","")

   writehtk(outputfile,newsamplesize,htkheader.sampleperiod,htkheader.samplesize/4,newparmkind,out_feat)
end

if #arg < 4 then
   print ("Please use the following syntax:")
   print ("th preparedata.lua scpfile globaltransf mlffile outputdir ext_frame(optional)")
   return
end

readmlf(arg[3])
readglobaltransf(arg[2])
finscp = assert(io.open(arg[1],'r'))
-- Define ext_frame as 5 by default, if any argument is given
ext_frame = arg[5] or 5
for line in finscp:lines() do
   ts = sys.clock()
   line = string.gsub(line, "^%s*(.-)%s*$", "%1")
   frame,htkheader = readfile(line,ext_frame)
   filename = line:split('/')
   filename = filename[#filename]
   filename = filename:split('%.')
   feat_name = filename[1]
   feat_extension = filename[2]
   writefile(arg[4]..feat_name.."."..feat_extension,frame,ext_frame,htkheader)
   te = sys.clock()
   print("Writing file "..arg[4]..feat_name.."."..feat_extension .. " took "..te-ts.. "s")
end
