print '==> executing all'

require 'init'
require 'data'
require 'model'
require 'loss'
-- require 'train'
require 'test'
----------------------------------------------------------------------
print(" ==> testing")

-- remove the last two layer
-- model:remove()
-- model:remove()
-- print(model)

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
