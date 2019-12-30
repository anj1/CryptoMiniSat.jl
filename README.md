CryptoMiniSat.jl
====

Julia wrapper for the [CryptoMiniSat](https://github.com/msoos/cryptominisat) advanced SAT solver library.

### Scope
This is intended to be a very thin wrapper around the library. As such, variables are represented in a numerical ordering. For example, to represent the variable 'x0', we write `Lit(0)`. To represent the negated variable 'not x0', we write `~Lit(0)`. To represent 'not x1', we write `~Lit(1)`, and so on.

Clauses are lists of `Lit`s, represented a logical OR. So for example, to represent '(not x0) or (x1)', we write:

```julia
[~Lit(0), Lit(1)]
```

### Basic Usage

To use the solver, we first create a solver instance and then add clauses to it. Finally, we solve to obtain whether the system is satisfiable or not, and if it is, to return a satisfying assignment. For example:

```julia
using CryptoMiniSat 

# Create new instance of SAT solver 
solver = SATSolver()

# Set number of threads 
set_num_threads(solver, 2)

# We are using 3 variables
new_vars(solver, 3)

# Create clauses 
add_clause(solver, [Lit(0)])
add_clause(solver, [~Lit(1)])
add_clause(solver, [~Lit(0), Lit(1), Lit(2)])

# Solve system (this should return true)
solve(solver) 

# Verify solution
mdl = get_model(solver)

@show mdl
```
This code will print the assignment `[true, false, true]` which satisfies the constraints.

### Installation

First install the [CryptoMiniSat](https://github.com/msoos/cryptominisat) C++ library, either through your package manager, binary install, or building from source. Once the library has been installed in your system, use Julia's package manager to install CryptoMiniSat.jl.
