
global const cmsat_lib = Sys.isunix() ? "libcryptominisat5" : "cryptominisat5"

using Libdl
try
    dlopen(cmsat_lib)
catch
    @warn "CryptoMiniSat5 library not loaded:
    please download and build from https://github.com/msoos/cryptominisat"
    rethrow()
end