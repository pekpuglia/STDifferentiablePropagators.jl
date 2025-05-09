## Description #############################################################################
#
#  API implementation for two-body orbit propagator.
#
############################################################################################

Propagators.epoch(orbp::OrbitPropagatorTwoBody)         = orbp.tbd.orb₀.t
Propagators.last_instant(orbp::OrbitPropagatorTwoBody)  = orbp.tbd.Δt
Propagators.mean_elements(orbp::OrbitPropagatorTwoBody) = orbp.tbd.orbk
Propagators.name(orbp::OrbitPropagatorTwoBody)          = "Two-Body Orbit Propagator"

"""
    Propagators.init(Val(:TwoBody), orb₀::KeplerianElements; kwargs...) -> OrbitPropagatorTwoBody

Create and initialize the two-body orbit propagator structure using the mean Keplerian
elements `orb₀`.

!!! note

    The type used in the propagation will be the same as used to define the gravitational
    constant `m0`.

# Keywords

- `m0::T`: Standard gravitational parameter of the central body [m³ / s²].
    (**Default** = `tbc_m0`)
"""
function Propagators.init(::Val{:TwoBody}, orb₀::KeplerianElements; m0::Number = tbc_m0, propagation_type=nothing)

    if isnothing(propagation_type)
        tbd = twobody_init(orb₀; m0 = m0)
        optb = OrbitPropagatorTwoBody(tbd)
    else
        orb0 = KeplerianElements{propagation_type, propagation_type}(getfield.(Ref(orb₀), fieldnames(KeplerianElements))...)
        tbd = twobody_init(orb0; m0 = m0, propagation_type=propagation_type)
        optb = OrbitPropagatorTwoBody{propagation_type, propagation_type}(tbd)
    end
    return optb
end

"""
    Propagators.init!(orbp::OrbitPropagatorTwoBody, orb₀::KeplerianElements) -> Nothing

Initialize the two-body orbit propagator structure `orbp` using the mean Keplerian elements
`orb₀`.

!!! warning

    The propagation constant `m0::Number` in `tbd` will not be changed. Hence, it must be
    initialized.

# Arguments

- `orb₀::KeplerianElements`: Initial mean Keplerian elements [SI units].
"""
function Propagators.init!(orbp::OrbitPropagatorTwoBody, orb₀::KeplerianElements)
    twobody_init!(orbp.tbd, orb₀)
    return nothing
end

function Propagators.propagate!(orbp::OrbitPropagatorTwoBody, t::Number)
    # Auxiliary variables.
    # return_type = promote_type(typeof(orbp.tbd.Δt), typeof(orbp.tbd.orb₀.a))
    # tbd = TwoBodyPropagator{typeof(orbp.tbd.Δt), return_type}(getfield.(Ref(orbp.tbd), fieldnames(typeof(orbp.tbd)))...)
    # orbp.tbd = tbd
    # Propagate the orbit.
    return twobody!(orbp.tbd, t)
end

############################################################################################
#                                        Julia API                                         #
############################################################################################

function Base.copy(orbp::OrbitPropagatorTwoBody{Tepoch, T}) where {Tepoch<:Number, T<:Number}
    return OrbitPropagatorTwoBody{Tepoch, T}(copy(orbp.tbd))
end
