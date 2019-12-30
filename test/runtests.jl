include("../src/CryptoMiniSat.jl")
using .CryptoMiniSat

function test_satisfiable()
    # Example taken from:
    # https://github.com/msoos/cryptominisat#rust-binding

    # Create new instance of SAT solver 
    solver = SATSolver()

    # Set number of threads 
    set_num_threads(solver, 2)

    new_vars(solver, 3)

    # Create clauses 
    @assert add_clause(solver, [Lit(0, false)])
    @assert add_clause(solver, [Lit(1, true)])
    @assert add_clause(solver, [Lit(0, true), Lit(1, false), Lit(2, false)])

    # Solve system
    @assert solve(solver) == l_true

    # Verify solution
    mdl = get_model(solver)

    @assert mdl[1] == l_true
    @assert mdl[2] == l_false
    @assert mdl[3] == l_true

    # no need to free the SAT solver,
    # as it will be finalized with gc
end 

function test_unsatisfiable()
    solver = SATSolver()

    new_vars(solver, 3)

    # Create clauses 
    @assert add_clause(solver, [Lit(0, false)])
    @assert add_clause(solver, [Lit(1, true)])
    @assert add_clause(solver, [Lit(0, true), Lit(1, false), Lit(2, false)])

    # Solve system with a conflicting assumption.
    @assert l_false == solve_with_assumptions(solver, [Lit(1, false), Lit(2, true)])

    # Verify that the conflict has been identified.
    conflict = get_conflict(solver)
    @assert conflict[1] == Lit(1, true)
end 

test_satisfiable()
test_unsatisfiable()