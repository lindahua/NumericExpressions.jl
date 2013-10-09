# Unit testing for numeric type inference

using NumericExpressions
using Base.Test

# fptype

@test fptype(Bool)   == Float32
@test fptype(Int8)   == Float32
@test fptype(Uint8)  == Float32
@test fptype(Int16)  == Float32
@test fptype(Uint16) == Float32
@test fptype(Int32)  == Float64
@test fptype(Uint32) == Float64
@test fptype(Int64)  == Float64
@test fptype(Uint64) == Float64
@test fptype(Float32) == Float32
@test fptype(Float64) == Float64

# type inference for operators

const vecopmap = {
	* => .*, 
	/ => ./, 
	^ => .^, 
	== => .==, 
	!= => .!=, 
	> => .>, 
	< => .<, 
	>= => .>=, 
	<= => .<=};

base_tyinfer(f::Function, T1::Type) = eltype(f(ones(T1, 1)))
function base_tyinfer(f::Function, T1::Type, T2::Type)
	vf::Function = haskey(vecopmap, f) ? vecopmap[f] : f
	eltype(vf(ones(T1, 1), ones(T2, 1)))
end

for f in [+, -, abs, abs2, sqrt, cbrt, 
	floor, ceil, round, trunc,
	ifloor, iceil, iround, itrunc,
    exp, log, log10, exp2, log2, expm1, log1p,
    sin, cos, tan, asin, acos, atan,
    sinh, cosh, tanh, asinh, acosh, atanh,
    erf, erfc, gamma, lgamma]

	for t in [Bool, Int32, Uint32, Int64, Uint64, Float32, Float64]
		# println("testing result type of $f on $t")
		@test resulttype(f, t) == base_tyinfer(f, t)
	end
end

for f in [+, -, *, /, ^, ==, !=, >, >=, <, <=, max, min, div, mod]

	for t1 in [Bool, Int32, Uint32, Int64, Uint64, Float32, Float64]
		for t2 in [Bool, Int32, Uint32, Int64, Uint64, Float32, Float64]
			# println("testing result type of $f on $t1 and $t2")
			@test resulttype(f, t1, t2) == base_tyinfer(f, t1, t2)
		end
	end 
end

for t in [Bool, Int32, Uint32, Int64, Uint64]
	# println("testing result type of ~ on $t")
	@test resulttype(~, t) == base_tyinfer(~, t)
end

for f in [&, |]
	for t1 in [Bool, Int32, Uint32, Int64, Uint64]
		for t2 in [Bool, Int32, Uint32, Int64, Uint64]
			# println("testing result type of $f on $t1 and $t2")
			@test resulttype(f, t1, t2) == base_tyinfer(f, t1, t2)
		end
	end 
end



