require ("htkwrite")
arr = {}
for i=1,10 do
    arr[i] = i
end
writehtk("feature.plp",3,100000,5,"PLP",arr)
