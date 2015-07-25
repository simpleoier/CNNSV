# dir: FeatureRSR2015fbank
awk -F/ '{print $NF}' norm1.scp | awk '{if (length($1)>0){printf("/slfs1/users/yl710/htk/HTKTools/HList feature_cmvn/feat/%s > feature_cmvn/feat/norm/%s\n",$0,$0)}}' > fbankbin2txt.sh

cd norm

FRM_EXT=5

./genidentity.sh norm/identity.trans
/slwork/users/nxc04/Cuckoo_all_serial/src/TNormCu -D -A -T 1 -S train.scp -H identity.trans --TARGET-MMF=global.norm --START-FRM-EXT=$FRM_EXT --END-FRM-EXT=$FRM_EXT | tee TNorm.LOG
cat identity.trans global.norm > global.transf
