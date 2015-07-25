function parseline(str)
   local t = {}
   for k,v in string.gmatch(str, "%S*") do
      if 0~=string.len(k) then
         t[#t+1] = k
      end
   end
   return t
end

function readglobalnorm(filename)
   fin = io.open(filename,'r')
   line = fin:read()
   line = fin:read()
   dim_bias = tonumber(line:split(' ')[2])
   line = fin:read()
   meansstr = line:split(' ')
   means = {}
   for i = 1,#meansstr do
      means[i] = tonumber(meansstr[i])
   end
   line = fin:read()
   line = fin:read()
   dim_window = tonumber(line:split(' ')[2])
   line = fin:read()
   line = fin:read()
   windowstr = line:split(' ')
   window = {}
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
   return frame
end

function writefile(outputfile, frame)
   fout = io.open(outputfile,'w')
   t = {}
   for i=1,#frame do
      for j = 1,#frame[i] do
         t[#t+1] = frame[i][j]
      end
   end
   for i=1,#frame-10 do
      fout:write("1 ")
      ss = ''
      for j=1, 1320 do
         ss = ss..(t[j+120*(i-1)]+means[j])*window[j]..' '
      end
      ss = ss..'\n'
      fout:write(ss)
   end
   fout:close()
end

readglobalnorm(arg[2])
finscp = io.open(arg[1],'r')
for line in finscp:lines() do
   line = string.gsub(line, "^%s*(.-)%s*$", "%1")
   frame = readfile(line)
   filename = line:split('/')[9]
   filename = filename:split('%.')[1]
   writefile(arg[3]..filename,frame)
end
