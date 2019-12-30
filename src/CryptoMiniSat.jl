module CryptoMiniSat 

import Base.convert 
import Base.show 

global const cmsat_lib = Sys.isunix() ? "libcryptominisat5" : "cryptominisat5"

export SATSolver
export Lit, C_lbool, Slice_Lit, Slice_lbool
export l_true, l_false, l_undef
export cmsat_new, cmsat_free, nvars, add_clause, add_xor_clause, new_vars, solve,
       solve_with_assumptions, get_model, get_conflict, print_stats,
       set_num_threads, set_verbosity
    
# structs taken from:
# https://github.com/msoos/cryptominisat/blob/master/src/cryptominisat_c.h.in
struct C_Lit
    x::UInt32
end 

struct C_lbool
    x::UInt8 
end 

struct Slice_Lit
    vals::Ptr{C_Lit}
    num_vals::Csize_t
end 

struct Slice_lbool 
    vals::Ptr{C_lbool}
    num_vals::Csize_t 
end 

const l_true = C_lbool(0)
const l_false = C_lbool(1)
const l_undef = C_lbool(2)

const Csatsolver = Ptr{Nothing}

# adapted from:
# https://github.com/msoos/cryptominisat/blob/master/rust/src/lib.rs
#=
function C_Lit(var::T, negated::Bool) where {T <: Unsigned}
    @assert var < (1 << 31)
    
    return C_Lit(var << 1 | negated)
end 
=#

struct Lit
    var::Int
    negated::Bool
end 

function Base.show(io::IO, l::Lit)
    if l.negated 
        print(io, "¬")
    end 
    show(io, l.var)
end

function convert(::Type{C_Lit}, l::Lit)
    @assert l.var < (1 << 31)
    @assert l.var >= 0 

    return C_Lit(l.var << 1 | l.negated)
end 

function convert(::Type{Lit}, l::C_Lit)
    return Lit(l.x >> 1, l.x & 0x1)
end 

mutable struct SATSolver 
    hnd::Csatsolver
    function SATSolver(hnd::Csatsolver)
        a = new(hnd)
        finalizer(cmsat_free, a)
    end
end

SATSolver() = SATSolver(cmsat_new())

function cmsat_free(sat_solver::SATSolver)
    ccall((:cmsat_free, cmsat_lib),
        Nothing,
        (Csatsolver,),
        sat_solver.hnd)
end 

function cmsat_new()::Csatsolver
    solver = ccall((:cmsat_new, cmsat_lib), Csatsolver, ())
    return solver
end 

function nvars(sat_solver::SATSolver)
    return ccall((:cmsat_nvars, cmsat_lib),
                 Cuint,
                 (Csatsolver,),
                 sat_solver.hnd)
end 

function add_clause(sat_solver::SATSolver, clause::Vector{Lit})::Bool
    return ccall((:cmsat_add_clause, cmsat_lib),
                 Bool,
                 (Csatsolver, Ref{C_Lit}, Csize_t),
                 sat_solver.hnd, convert(Vector{C_Lit}, clause), length(clause))
end 

function add_xor_clause(sat_solver::SATSolver, vars::Vector{Unsigned}, rhs::Bool)::Bool
    return ccall((:cmsat_add_xor_clause, cmsat_lib),
          Bool,
          (Csatsolver, Ref{Cuint}, Bool),
          sat_solver.hnd, vars, rhs)
end 

function new_vars(sat_solver::SATSolver, n_vars::T) where {T <: Integer}
    ccall((:cmsat_new_vars, cmsat_lib),
           Nothing,
           (Csatsolver, Cuint),
           sat_solver.hnd, n_vars)
end 

function solve(sat_solver::SATSolver)::C_lbool
    return ccall((:cmsat_solve, cmsat_lib),
                 C_lbool, 
                 (Csatsolver,),
                 sat_solver.hnd)
end 

function solve_with_assumptions(sat_solver::SATSolver, assumptions::Vector{Lit})::C_lbool
    return ccall((:cmsat_solve_with_assumptions, cmsat_lib),
                 C_lbool, 
                 (Csatsolver, Ref{C_Lit}, Csize_t),
                 sat_solver.hnd, convert(Array{C_Lit}, assumptions), length(assumptions))
end  

function get_model(sat_solver::SATSolver)::Vector{C_lbool}
    c_mdl = ccall((:cmsat_get_model, cmsat_lib),
                  Slice_lbool,
                  (Csatsolver,),
                  sat_solver.hnd)
    return unsafe_wrap(Array{C_lbool}, c_mdl.vals, c_mdl.num_vals)
end 

function get_conflict(sat_solver::SATSolver)::Vector{Lit}
    c_conflict = ccall((:cmsat_get_conflict, cmsat_lib),
                       Slice_Lit,
                       (Csatsolver,),
                       sat_solver.hnd)
    clits = unsafe_wrap(Array{C_Lit}, c_conflict.vals, c_conflict.num_vals)
    return clits
end 

function print_stats(sat_solver::SATSolver)
    ccall((:cmsat_print_stats, cmsat_lib),
          Nothing, 
          (Csatsolver,),
          sat_solver.hnd)
end 

function set_num_threads(sat_solver::SATSolver, n_threads::T) where {T <: Integer}
    ccall((:cmsat_set_num_threads, cmsat_lib),
          Nothing,
          (Csatsolver, Cuint),
          sat_solver.hnd, n_threads)
end 

function set_verbosity(sat_solver::SATSolver, n::T) where {T <: Integer}
    ccall((:cmsat_set_verbosity, cmsat_lib),
          Nothing,
          (Csatsolver, Cuint),
          sat_solver.hnd, n)
end 

end 