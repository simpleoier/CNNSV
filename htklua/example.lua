require "libhtktoth"
require "sys"

arr = {}
for i=1,100000 do
    arr[i] = i
end

ts = sys.clock()
writehtk("feature.plp",10000,100000,10,"PLP_0_D_A_Z",arr)
te = sys.clock()
print ("Time to write was " .. te - ts )


ts= sys.clock()
feat = loadhtk('feature.plp',1)
te = sys.clock()
print("Time to read was " .. te -ts )


ts =sys.clock()
header = loadheader('feature.plp')
te =sys.clock()
print("Time to read header was " .. te -ts)
print(header)




