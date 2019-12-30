include("../src/CryptoMiniSat.jl")
using .CryptoMiniSat

# Example taken from:
# https://github.com/msoos/cryptominisat#rust-binding

# Create new instance of SAT solver 
solver = SATSolver()

# Set number of threads 
set_num_threads(solver, 2)

new_vars(solver, 3)

# Create clauses 
@assert add_clause(solver, [C_Lit(0x0, false)])

@assert add_clause(solver, [C_Lit(0x1, true)])

@assert add_clause(solver, [C_Lit(0x0, true), C_Lit(0x1, false), C_Lit(0x2, false)])

# Solve system
@show solve(solver)

# Display solution
mdl = get_model(solver)
@show mdl 

@assert mdl[1] == l_true
@assert mdl[2] == l_false
@assert mdl[3] == l_true


# no need to free the SAT solver,
# as it will be finalized with gc