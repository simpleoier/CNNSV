-- require 'torch'
----------------------------------------------------------------------
print '==> executing all'

dofile 'init.lua'
dofile 'data.lua'
dofile 'model.lua'
dofile 'loss.lua'
-- dofile 'train.lua'
dofile 'test.lua'
----------------------------------------------------------------------
print(" ==> testing")

testReadData()

test()
