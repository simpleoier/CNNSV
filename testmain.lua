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

local trainfbankfilelist = opt.scpfile
local listfile = io.open(trainfbankfilelist, 'r')
while (true) do
    testData = readData(listfile)
    if (testData:size()>0) then
        test()
    else
        break
    end
    collectgarbage()
end
listfile:close()
