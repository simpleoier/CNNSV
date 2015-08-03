//Copyright (C) 2015  Hani Altwaijry
//Released under MIT License
//license available in LICENSE file

extern "C" {
#include <lua.h>                               /* Always include this */
#include <lauxlib.h>                           /* Always include this */
#include <lualib.h>                           /* Always include this */
}

#include <string>
#include <cstdio>
#include <cstdlib>
#include <chtk.h>
#include <stdint.h>

#include <TH.h>
#include <luaT.h>

#include <iostream>
#include <fstream>
#include <map>
#include <cstring>
#include <sys/stat.h>


static std::map<std::string, int> HTKFEATURETYPE = {
{"WAVEFORM",0},
{"LPC", 1,},
{"LPREFC", 2},
{"LPCEPSTRA", 3},
{"LPDELCEP", 4},
{"IREFC", 5},
{"MFCC", 6},
{"FBANK", 7,},
{"MELSPEC", 8},
{"USER", 9},
{"DISCRETE", 10},
{"PLP", 11}
};

const std::string ERROR_MSG = "Arguments for writehtk are:\nfilename(string) number_samples(int) sampleperiod(int) featuredim(int) featuretype(string) data(table)\n";

short _swap16b(short end){
    return ((end>>8)|(end<<8));
}

inline bool file_exists (const std::string& name) {
  struct stat buffer;
  return (stat (name.c_str(), &buffer) == 0);
}


static void load_array_to_lua(lua_State *L, chtk::htkarray& arr){
	int ndims = 2;

	//based on code from mattorch with stride fix
	int k;
    THLongStorage *size = THLongStorage_newWithSize(ndims);
    THLongStorage *stride = THLongStorage_newWithSize(ndims);
    THLongStorage_set(size,0 , arr.nsamples);
	THLongStorage_set(size,1,arr.samplesize/4*(2*arr.frm_ext+1));
	THLongStorage_set(stride,1,1);
	THLongStorage_set(stride,0,arr.samplesize/4*(2*arr.frm_ext+1));
    void * tensorDataPtr = NULL;
    size_t numBytes = 0;

	THFloatTensor *tensor = THFloatTensor_newWithSize(size, stride);
    tensorDataPtr = (void *)(THFloatTensor_data(tensor));

    numBytes = THFloatTensor_nElement(tensor) * 4;
    luaT_pushudata(L, tensor, luaT_checktypename2id(L, "torch.FloatTensor"));
	// now copy the data
    assert(tensorDataPtr);
	memcpy(tensorDataPtr, (void *)(arr.data<void>()), numBytes);


}

static int loadhtk_l(lua_State *L) {

	try{
		std::string filename = luaL_checkstring(L, 1);
        if (! file_exists(filename)){
            std::cerr << " The given file " <<filename << " was not found! " << std::endl;
            return 0;
        }

		const int FRM_EXT = luaL_checknumber(L,2);
		chtk::htkarray arr = chtk::htk_load(filename,FRM_EXT);

		load_array_to_lua(L, arr);

	} catch (std::exception& e){
		THError(e.what());
        return 1;
	}
	return 1;
}

void error (lua_State *L, const char *fmt, ...) {
      luaL_error(L, fmt);
      va_list argp;
      va_start(argp, fmt);
      vfprintf(stderr, fmt, argp);
      va_end(argp);
      lua_close(L);
      exit(EXIT_FAILURE);
    }

void error(lua_State *L , std::string fmt){
    std::string ERR = ERROR_MSG + fmt;
    error(L,ERR.c_str());
}

int parse_write_args(lua_State *L){
    // Check that the arguments are all right
    if (lua_isnumber(L, 1)){
        std::string FN_ERR = "First argument `Filename ` should be a string";
        error(L, FN_ERR);
        return 0;
    }
    else if(!lua_isnumber(L,2)){
        std::string FN_ERR = "Argument 2 should be a number";
        error(L,FN_ERR);
        return 0;
    }
    else if(!lua_isnumber(L,3)){
        std::string FN_ERR = "Argument 3 should be a number";
        error(L,FN_ERR);
        return 0;
    }
    else if(!lua_isnumber(L,4)){
        std::string FN_ERR = "Argument 4 should be a number";
        error(L,FN_ERR);
        return 0;
    }
    else if(lua_isnumber(L,5)){
        std::string FN_ERR = "Argument 5 should be a string. Possible values are:\n";
        for (std::map<std::string,int>::iterator i = HTKFEATURETYPE.begin(); i != HTKFEATURETYPE.end(); ++i)
        {
            FN_ERR+= i->first + "\n";
        }
        error(L,FN_ERR);
        return 0;
    }
    else if(!lua_istable(L,6)){
        std::string FN_ERR = "Argument 6 should be a table, which contains all the feature data\n";
        error(L,FN_ERR);
    }
    return 1;


}

static int writehtk_l (lua_State *L){
    // luaL_openlibs(L);
    // Parse the arguments and write them out
    if (!parse_write_args(L)){
        return 0;
    }

    std::ofstream outputfile;
    outputfile.open(luaL_checkstring(L,1),std::ios::binary);
    short feat_dim = luaL_checknumber(L,4);
    // 4 bytes for the feature dimensions
    short featurelength = feat_dim*4;
    if(outputfile.is_open()){
        // HTK uses big endian, c++ uses little endian, so we need
        // to convert the big to the little endian using the buildin
        // gcc function bswap
        int n_samples=luaL_checknumber(L,2);
        n_samples = __builtin_bswap32(n_samples);
        int sampleperiod=luaL_checknumber(L,3);
        sampleperiod=__builtin_bswap32(sampleperiod);

        featurelength = _swap16b(featurelength);
        std::string featuretypestring=lua_tostring(L,5);

        std::map<std::string,int>::iterator it;
        // Check if given feature type exists in HTK
        it = HTKFEATURETYPE.find(featuretypestring);
        if (it == HTKFEATURETYPE.end()){
            std::string err = "Feature type unknown! Possible types are:\n";
            for (std::map<std::string,int>::iterator i = HTKFEATURETYPE.begin(); i != HTKFEATURETYPE.end(); ++i)
            {
                err += i->first + "\n";
            }
            error(L,err);
            return 0;
        }
        short featuretype = it->second;


        featuretype = _swap16b(featuretype);
        // get size of the data
        auto size_n = luaL_getn(L,6);

        // Write out the HTK header, which is two 4 byte ints and two 2 byte shorts
        // in big endian format
        outputfile.write(reinterpret_cast<char*>(&n_samples),sizeof(int));
        outputfile.write(reinterpret_cast<char*>(&sampleperiod),sizeof(int));
        outputfile.write(reinterpret_cast<char*>(&featurelength),sizeof(short));
        outputfile.write(reinterpret_cast<char*>(&featuretype),sizeof(short));


        // Write out the data ( we use as default floats here )
        // Lua indices start at 1
        for (auto i = 1; i <= size_n; ++i)
        {
            // Get the current index i of the array on the stack
            lua_rawgeti(L,6, i);
            // Convert the current value into a float
            float val = lua_tonumber(L,-1);
            // Pop the value from the stack
            lua_pop(L,1);
            val = chtk::swapfloatendian(val);
            outputfile.write(reinterpret_cast<char*>(&val),sizeof(float));
        }
        outputfile.close();
    }else{
        std::cerr<< " File is already open or cant be opened !" <<std::endl;
        return 0;
    }
    return 0;
}




extern "C"
int luaopen_libhtktoth (lua_State *L) {
    lua_register(L, // Lua state variable
                 "writehtk", // Lua func name
                 writehtk_l // C++ func name
                 );

    lua_register(L,
                 "loadhtk",
                 loadhtk_l
                 );
  return 1;
}

int main(int argc, char const *argv[])
{
    lua_State * L = luaL_newstate();
    luaL_openlibs(L);
    {
        std::cout << "Running Test .... " <<std::endl;
        luaL_dofile(L, "../test.lua" );
    }
    lua_close(L);
    return 0;
}
