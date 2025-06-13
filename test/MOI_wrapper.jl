# Copyright (c) 2014: SCS.jl contributors
#
# Use of this source code is governed by an MIT-style license that can be found
# in the LICENSE.md file or at https://opensource.org/licenses/MIT.

module TestSCS

using Test
import MathOptInterface as MOI
import SCS

function runtests()
    for name in names(@__MODULE__; all = true)
        if startswith("$(name)", "test_")
            @testset "$(name)" begin
                getfield(@__MODULE__, name)()
            end
        end
    end
    return
end

test_DirectSolver() = _test_runtests(SCS.DirectSolver)

test_IndirectSolver() = _test_runtests(SCS.IndirectSolver)

@static if Sys.islinux() && Sys.ARCH == :x86_64
    test_MKLDirectSolver() = _test_runtests(SCS.MKLDirectSolver)
end

function _test_runtests(linear_solver)
    optimizer = SCS.Optimizer()
    MOI.set(
        optimizer,
        MOI.RawOptimizerAttribute("linear_solver"),
        linear_solver,
    )
    MOI.set(optimizer, MOI.RawOptimizerAttribute("eps_abs"), 1e-6)
    MOI.set(optimizer, MOI.Silent(), true)
    model = MOI.Bridges.full_bridge_optimizer(
        MOI.Utilities.CachingOptimizer(
            MOI.Utilities.UniversalFallback(MOI.Utilities.Model{Float64}()),
            optimizer,
        ),
        Float64,
    )
    MOI.Test.runtests(
        model,
        MOI.Test.Config(
            atol = 1e-2,
            exclude = Any[
                MOI.ConstraintBasisStatus,
                MOI.VariableBasisStatus,
                MOI.ConstraintName,
                MOI.VariableName,
                MOI.ObjectiveBound,
                MOI.SolverVersion,
            ],
        ),
        exclude = String[
            # Unexpected failures:
            #   TODO(odow): looks like a tolerance issue?
            "test_linear_add_constraints",
            "test_conic_HermitianPositiveSemidefiniteConeTriangle_2",
            # Expected test failures:
            #   TODO(odow): get not supported for primal/dual starts
            "test_model_ModelFilter_AbstractConstraintAttribute",
            #   ArgumentError: The number of constraints must be greater than 0
            "test_attribute_RawStatusString",
            "test_attribute_SolveTimeSec",
            "test_objective_ObjectiveFunction_blank",
            "test_solve_TerminationStatus_DUAL_INFEASIBLE",
        ],
    )
    return
end

function test_RawOptimizerAttribute()
    model = SCS.Optimizer()
    MOI.set(model, MOI.RawOptimizerAttribute("eps_abs"), 1.0)
    @test MOI.get(model, MOI.RawOptimizerAttribute("eps_abs")) == 1.0
    @test MOI.get(model, MOI.RawOptimizerAttribute("eps_abs")) == 1.0
    MOI.set(model, MOI.RawOptimizerAttribute("eps_abs"), 2.0)
    @test MOI.get(model, MOI.RawOptimizerAttribute("eps_abs")) == 2.0
    @test MOI.get(model, MOI.RawOptimizerAttribute("eps_abs")) == 2.0
    return
end

function test_constrained_variables()
    model = MOI.Bridges.full_bridge_optimizer(
        MOI.Utilities.CachingOptimizer(
            MOI.Utilities.UniversalFallback(MOI.Utilities.Model{Float64}()),
            SCS.Optimizer(),
        ),
        Float64,
    )
    @test MOI.supports_constraint(
        model,
        MOI.VectorOfVariables,
        MOI.PositiveSemidefiniteConeTriangle,
    )
    x = MOI.add_variables(model, 6)
    f = MOI.VectorOfVariables(x)
    s = MOI.PositiveSemidefiniteConeTriangle(3)
    @test isa(
        MOI.add_constraint(model, f, s),
        MOI.ConstraintIndex{typeof(f),typeof(s)},
    )
    return
end

function test_unsupported()
    model = MOI.Utilities.UniversalFallback(MOI.Utilities.Model{Float64}())
    optimizer = SCS.Optimizer()
    x = MOI.add_variable(model)
    MOI.add_constraint(model, 1.0x, MOI.EqualTo(1.0))
    err = MOI.UnsupportedConstraint{
        MOI.ScalarAffineFunction{Float64},
        MOI.EqualTo{Float64},
    }()
    @test_throws err MOI.optimize!(optimizer, model)
    MOI.empty!(model)
    x = MOI.add_variable(model)
    MOI.set(model, MOI.Test.UnknownVariableAttribute(), x, 1.0)
    err = MOI.UnsupportedAttribute{MOI.Test.UnknownVariableAttribute}
    @test_throws err MOI.optimize!(optimizer, model)
    MOI.empty!(model)
    x = MOI.add_variable(model)
    c = MOI.add_constraint(model, MOI.Utilities.vectorize([1.0x]), MOI.Zeros(1))
    MOI.set(model, MOI.Test.UnknownConstraintAttribute(), c, 1.0)
    err = MOI.UnsupportedAttribute{MOI.Test.UnknownConstraintAttribute}
    @test_throws err MOI.optimize!(optimizer, model)
    return
end

function test_empty_problem()
    model = MOI.Utilities.Model{Float64}()
    scs = SCS.Optimizer()
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.TerminationStatus()) == MOI.INVALID_MODEL
    @test MOI.get(scs, MOI.PrimalStatus()) == MOI.NO_SOLUTION
    @test MOI.get(scs, MOI.DualStatus()) == MOI.NO_SOLUTION
    return
end

function test_conic_no_variables()
    model = MOI.Utilities.Model{Float64}()
    scs = SCS.Optimizer()
    f = MOI.VectorAffineFunction(
        MOI.VectorAffineTerm{Float64}[],
        [1.0, 0.5, 0.5],
    )
    MOI.add_constraint(model, f, MOI.SecondOrderCone(3))
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.TerminationStatus()) == MOI.INVALID_MODEL
    @test MOI.get(scs, MOI.PrimalStatus()) == MOI.NO_SOLUTION
    @test MOI.get(scs, MOI.DualStatus()) == MOI.NO_SOLUTION
    return
end

function test_Name_skip()
    model = MOI.Utilities.UniversalFallback(MOI.Utilities.Model{Float64}())
    MOI.set(model, MOI.Name(), "My problem")
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.add_constraint(model, f, MOI.Nonnegatives(3))
    scs = SCS.Optimizer()
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.TerminationStatus()) == MOI.OPTIMAL
    return
end

function test_VectorOfVariables_psd_permutation()
    MOI.Bridges.runtests(
        SCS.ScaledPSDConeBridge,
        """
        variables: x1
        [x1] in ScaledPositiveSemidefiniteConeTriangle(1)
        """,
        """
        variables: x1
        [x1] in SCS.ScaledPSDCone(1)
        """,
    )
    MOI.Bridges.runtests(
        SCS.ScaledPSDConeBridge,
        """
        variables: x1, x2, x3
        [x1, x2, x3] in ScaledPositiveSemidefiniteConeTriangle(2)
        """,
        """
        variables: x1, x2, x3
        [x1, x2, x3] in SCS.ScaledPSDCone(2)
        """,
    )
    MOI.Bridges.runtests(
        SCS.ScaledPSDConeBridge,
        """
        variables: x1, x2, x3, x4, x5, x6
        [x1, x2, x3, x4, x5, x6] in ScaledPositiveSemidefiniteConeTriangle(3)
        """,
        """
        variables: x1, x2, x3, x4, x5, x6
        [x1, x2, x4, x3, x5, x6] in SCS.ScaledPSDCone(3)
        """,
    )
    MOI.Bridges.runtests(
        SCS.ScaledPSDConeBridge,
        """
        variables: x1, x2, x3, x4, x5, x6, x7, x8, x9, x10
        [x1, x2, x3, x4, x5, x6, x7, x8, x9, x10] in ScaledPositiveSemidefiniteConeTriangle(4)
        """,
        """
        variables: x1, x2, x3, x4, x5, x6, x7, x8, x9, x10
        [x1, x2, x4, x7, x3, x5, x8, x6, x9, x10] in SCS.ScaledPSDCone(4)
        """,
    )
    return
end

function test_redirect_stdout()
    filename = tempname()
    open(filename, "w") do io
        redirect_stdout(io) do
            model = MOI.Utilities.Model{Float64}()
            x = MOI.add_variables(model, 3)
            f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
            MOI.add_constraint(model, f, MOI.Nonnegatives(3))
            scs = SCS.Optimizer()
            MOI.optimize!(scs, model)
            return
        end
        return
    end
    output = read(filename, String)
    @test occursin("SCS", output)
    @test length(output) > 100
    return
end

function test_attribute_TimeLimitSec()
    model = SCS.Optimizer()
    @test MOI.supports(model, MOI.TimeLimitSec())
    @test MOI.get(model, MOI.TimeLimitSec()) === nothing
    MOI.set(model, MOI.TimeLimitSec(), 0.0)
    @test MOI.get(model, MOI.TimeLimitSec()) == 0.0
    MOI.set(model, MOI.TimeLimitSec(), nothing)
    @test MOI.get(model, MOI.TimeLimitSec()) === nothing
    MOI.set(model, MOI.TimeLimitSec(), 1.0)
    @test MOI.get(model, MOI.TimeLimitSec()) == 1.0
    return
end

function test_SolveTimeSec()
    model = MOI.Utilities.Model{Float64}()
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.add_constraint(model, f, MOI.Nonnegatives(3))
    scs = SCS.Optimizer()
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.SolveTimeSec()) >= 0
    return
end

function test_RawStatusString()
    model = MOI.Utilities.Model{Float64}()
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.add_constraint(model, f, MOI.Nonnegatives(3))
    scs = SCS.Optimizer()
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.RawStatusString()) isa String
    return
end

function test_ADMMIterations()
    model = MOI.Utilities.Model{Float64}()
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.add_constraint(model, f, MOI.Nonnegatives(3))
    MOI.add_constraint(
        model,
        MOI.Utilities.operate(vcat, Float64, 1.0 * x[1] + 1.0 * x[2] - 2.0),
        MOI.Nonnegatives(1),
    )
    scs = SCS.Optimizer()
    MOI.optimize!(scs, model)
    attr = SCS.ADMMIterations()
    @test MOI.is_set_by_optimize(attr)
    @test MOI.get(scs, attr) > 0
    return
end

function test_max_iters()
    model = MOI.Utilities.Model{Float64}()
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.add_constraint(model, f, MOI.Nonnegatives(3))
    MOI.add_constraint(
        model,
        MOI.Utilities.operate(vcat, Float64, 1.0 * x[1] + 1.0 * x[2] - 2.0),
        MOI.Nonnegatives(1),
    )
    scs = SCS.Optimizer()
    MOI.set(scs, MOI.RawOptimizerAttribute("max_iters"), 1)
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.TerminationStatus()) == MOI.ITERATION_LIMIT
    return
end

function test_time_limit_secs()
    model = MOI.Utilities.Model{Float64}()
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.add_constraint(model, f, MOI.Nonnegatives(3))
    MOI.add_constraint(
        model,
        MOI.Utilities.operate(vcat, Float64, 1.0 * x[1] + 1.0 * x[2] - 2.0),
        MOI.Nonnegatives(1),
    )
    scs = SCS.Optimizer()
    # The time limit has to be > 0 for SCS to respect it.
    MOI.set(scs, MOI.RawOptimizerAttribute("time_limit_secs"), 1e-14)
    MOI.optimize!(scs, model)
    @test MOI.get(scs, MOI.TerminationStatus()) == MOI.TIME_LIMIT
    return
end

function test_unsupported_objective()
    model = MOI.Utilities.Model{Float64}()
    x = MOI.add_variables(model, 3)
    f = MOI.Utilities.operate(vcat, Float64, 1.0 .* x...)
    MOI.set(model, MOI.ObjectiveSense(), MOI.MIN_SENSE)
    attr = MOI.ObjectiveFunction{MOI.VariableIndex}()
    MOI.set(model, attr, x[1])
    scs = SCS.Optimizer()
    @test_throws(
        MOI.UnsupportedAttribute{typeof(attr)},
        MOI.optimize!(scs, model),
    )
    return
end

end  # module

TestSCS.runtests()
