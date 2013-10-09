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

base_tyinfer(f::Function, T1::Type) = eltype(f(ones(T1, 1)))
function base_tyinfer(f::Function, T1::Type, T2::Type)
	if f == *
		eltype(ones(T1, 1) .* ones(T2, 1))
	elseif f == /
		eltype(ones(T1, 1) ./ ones(T2, 1))
	elseif f == ^
		eltype(ones(T1, 1) .^ ones(T2, 1))
	else
		eltype(f(ones(T1, 1), ones(T2, 1)))
	end
end

for f in [+, -]
	for t in [Bool, Int32, Uint32, Int64, Uint64, Float32, Float64]
		# println("testing result type of $f on $t")
		@test resulttype(f, t) == base_tyinfer(f, t)
	end
end

for f in [+, -, *, /, ^]
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



