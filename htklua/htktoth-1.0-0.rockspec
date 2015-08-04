package = "htktoth"
version = "1.0-0"

source = {
   url = "...",
   tag = "1.0-0"
}

description = {
   summary = "A HTK format loader for Torch",
   detailed = [[
      Load htk files into torch.
   ]],
   homepage = "..",
<<<<<<< HEAD
   license = "sbt11"
=======
   license = "sbt11&hedi7"
>>>>>>> f545cc7c14b10ec1e879ee5cd4d7c5e234efa35d
}

dependencies = {
   "torch >= 7.0",
   "xlua >= 1.0"
}

build = {
   type = "command",
   build_command = [[
cmake -E make_directory build;
cd build;
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$(LUA_BINDIR)/.." -DCMAKE_INSTALL_PREFIX="$(PREFIX)"; 
$(MAKE)
   ]],
   install_command = "cd build && $(MAKE) install"
}
