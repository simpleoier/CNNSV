require 'torch'
----------------------------------------------------------------------
print '==> executing all'

dofile '0_init.lua'
dofile '1_data.lua'
dofile '2_model.lua'
dofile '3_loss.lua'
dofile '4_train.lua'
dofile '5_test.lua'

----------------------------------------------------------------------
print '==> training!'

while true do
   train()
   -- print("doall training")
   -- test()
end
