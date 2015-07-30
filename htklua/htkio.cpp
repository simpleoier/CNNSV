extern "C" {
#include <lua.h>                               /* Always include this */
#include <lauxlib.h>                           /* Always include this */
#include <lualib.h>                           /* Always include this */
}

#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <cstring>


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

float swapfloatendian( const float inFloat )
{
   float retVal;
   char *floatToConvert = ( char* ) & inFloat;
   char *returnFloat = ( char* ) & retVal;

   // swap the bytes into a temporary buffer
   returnFloat[0] = floatToConvert[3];
   returnFloat[1] = floatToConvert[2];
   returnFloat[2] = floatToConvert[1];
   returnFloat[3] = floatToConvert[0];

   return retVal;
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


int parsearguments(lua_State *L){
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



static int writehtkfeature (lua_State *L){
    luaL_openlibs(L);
    // Parse the arguments and write them out
    if (!parsearguments(L)){
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
        {
        for (auto i = 1; i <= size_n; ++i)
        {
            // Get the current index i of the array on the stack
            lua_rawgeti(L,6, i);
            // Convert the current value into a float
            float val = lua_tonumber(L,-1);
            // Pop the value from the stack
            lua_pop(L,1);
            val = swapfloatendian(val);
            outputfile.write(reinterpret_cast<char*>(&val),sizeof(float));
        }
        }
        outputfile.close();
    }else{
        std::cerr<< " File is already open or cant be opened !" <<std::endl;
        return 0;
    }
    return 0;
}

extern "C"
int luaopen_htkwrite(lua_State *L){
    lua_register(
            L,               /* Lua state variable */
            "writehtk",        /* func name as known in Lua */
            writehtkfeature          /* func name in this file */
            );
    return 0;
}

int main(int argc, char const *argv[])
{
    lua_State * L = luaL_newstate();
    luaL_openlibs(L);
    {
        luaL_dofile(L, "htk.lua" );
    }
    lua_close(L);
    return 0;
}
