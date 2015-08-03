print '==> executing all'

require 'init'
require 'data'
require 'model'
require 'loss'
-- require 'train'
require 'test'
----------------------------------------------------------------------
print("==> testing")

if not opt.scpfile then
    error("Please specify a file containing the data with -scpfile")
    return
elseif io.open(opt.scpfile,"rb") == nil then
    error(string.format("Given scp file %s cannot be found!",opt.scpfile))
    return
end

readLabel(opt.labelfile)
local testfbankfilelist = opt.scpfile
local listfile = io.open(testfbankfilelist, 'r')
while (true) do
    testData = readDataScp2(listfile)
    if (testData~=nil) then
        test()
    else
        break
    end
    collectgarbage()
end
listfile:close()
