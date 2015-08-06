
require "libpreparedata"

if #arg < 4 then
   print ("Please use the following syntax:")
   print ("th preparedata.lua scpfile globaltransf mlffile outputdir ext_frame(optional)")
   return
end

readmlf(arg[3])
means,window = readglobalnorm(arg[2])
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
