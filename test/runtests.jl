using CryptoMiniSat

function test_satisfiable()
    # Example taken from:
    # https://github.com/msoos/cryptominisat#rust-binding

    # Create new instance of SAT solver 
    solver = SATSolver()

    # Set number of threads 
    set_num_threads(solver, 2)

    new_vars(solver, 3)

    # Create clauses 
    @assert add_clause(solver, [Lit(0)])
    @assert add_clause(solver, [~Lit(1)])
    @assert add_clause(solver, [~Lit(0), Lit(1), Lit(2)])

    # Solve system
    @assert solve(solver) == true

    # Verify solution
    mdl = get_model(solver)

    @assert mdl == [true, false, true]

    # no need to free the SAT solver,
    # as it will be finalized with gc
end 

function test_unsatisfiable()
    solver = SATSolver()

    new_vars(solver, 3)

    # Create clauses 
    @assert add_clause(solver, [Lit(0)])
    @assert add_clause(solver, [~Lit(1)])
    @assert add_clause(solver, [~Lit(0), Lit(1), Lit(2)])

    # Solve system with a conflicting assumption.
    @assert false == solve(solver, [Lit(1), ~Lit(2)])

    # Verify that the conflict has been identified.
    conflict = get_conflict(solver)
    @assert conflict == [~Lit(1)]
end 

test_satisfiable()
test_unsatisfiable()