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
   line = fin:read()
   line = fin:read()
   -- First read in the biases of the transforms, which are useless
   -- dim_bias = tonumber(line:split(' ')[2])
   line = fin:read()
   meansstr = line:split(' ')
   means = {}
   -- Convert all the means to a number
   for i = 1,#meansstr do
      means[i] = tonumber(meansstr[i])
   end
   line = fin:read()
   line = fin:read()
   -- dim_window is the dimension of the input vector to the dnn
   dim_window = tonumber(line:split(' ')[2])
   line = fin:read()
   line = fin:read()
   windowstr = line:split(' ')
   window = {}
   -- Reading in the 1/sigma aka variances
   for i = 1,#windowstr do
      window[i] = tonumber(windowstr[i])
   end
   fin:close()
end

function readfile(inputfile)
   fin = io.open(inputfile,'r')
   assert(fin)
   line = fin:read()
   line = fin:read()
   frame = {}
   field = {}
   en = true
   while (en) do
      s = string.find(line,':')
      framenum = tonumber(string.sub(line,1,s-1))
      line = string.sub(line,s+1)
      local ss = ''
      repeat
         ss = ss..' '..string.gsub(line, "^%s*(.-)%s*$", "%1")
         line = fin:read()
         if (line) then
            s,e = string.find(line, ":") or string.find(line, "END")
            if (string.find(line, "END")~=nil) then
               en = false
            end
         else
            break;
         end
      until s~=nil
      local field = parseline(ss)
      frame[framenum+1] = field
      if not (line) then
         break
      end
   end
   dim_fea = #frame[1]
   if (dim_fea*11~=#means) then
      print("Feature dimension "..dim_fea.." does not match globalnorm dimension "..#means)
   end
   return frame
end

-- Writes out the outputfile and normalizes its frames with T-norm
function writefile(outputfile, frame,extframe)
   -- Open out the outputfile
   fout = io.open(outputfile,'w')
   -- Default is 5 frames left and right
   extframe = extframe or 5
   t = {}
   -- Concatenate the frames to one large string
   for i=1,#frame do
      for j = 1,#frame[i] do
         t[#t+1] = frame[i][j]
      end
   end
   chunk = outputfile:split('/')
   chunk = chunk[#chunk]
   chunk = chunk:split('_')
   lab = chunk[1]..'_'..chunk[2]
   --We extend the frame window left and right by extframe frames
   for i=1,#frame-(2*extframe) do
      fout:write(label[lab]..' ')
      ss = ''
      -- Apply T-Norm here, T-Norm is defined as:
      -- ss = (ss_old - mu)/cov
      for j=1, #means do
         ss = ss..(t[j+dim_fea*(i-1)]+means[j])*window[j]..' '
      end
      -- add the newline
      ss = ss..'\n'
      fout:write(ss)
   end
   fout:close()
end

if #arg ~= 4 then
   print ("Please use the following syntax:")
   print ("th preparedata.lua scpfile globaltransf mlffile outputfile")
   return
end

readmlf(arg[3])
readglobaltransf(arg[2])
finscp = io.open(arg[1],'r')
for line in finscp:lines() do
   line = string.gsub(line, "^%s*(.-)%s*$", "%1")
   frame = readfile(line)
   filename = line:split('/')
   filename = filename[#filename]
   filename = filename:split('%.')[1]
   writefile(arg[4]..filename,frame)
end
