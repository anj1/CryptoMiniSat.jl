using CryptoMiniSat

#=
Basic sanity check that we can interface properly
with the library.
=#
function test_nvars()
    solver = SATSolver()

    new_vars(solver, 7)

    @assert nvars(solver) == 7
end 

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

    # Solve system and verify
    sat, mdl = solve(solver)
    @assert sat == true
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
    sat, mdl = solve(solver, [Lit(1), ~Lit(2)])
    @assert sat == false 

    # Verify that the conflict has been identified.
    conflict = get_conflict(solver)
    @assert conflict == [~Lit(1)]
end 

function test_xor_clause()
    solver = SATSolver()

    new_vars(solver, 3)

    # Create clauses 
    @assert add_clause(solver, [Lit(0)])
    @assert add_xor_clause(solver, Unsigned[0, 1], true)
    @assert add_xor_clause(solver, Unsigned[0, 1, 2], true)

    # Solve system with a conflicting assumption.
    sat, mdl = solve(solver)
    @assert sat == true 
    
    # Verify that the solution has been identified.
    @assert sat == true
    @assert mdl == [true, false, false]

    # Verify that this is in fact the only solution 
    @assert add_clause(solver, [~Lit(0), Lit(1), Lit(2)]) == false
end 

test_nvars()
test_satisfiable()
test_unsatisfiable()
test_xor_clause()