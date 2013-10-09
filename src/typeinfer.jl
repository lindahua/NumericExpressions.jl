# Type inference for numeric functions

type NumTypeInference 
end

function resulttype(f::Function, t1::Type)
	if applicable(f, NumTypeInference, t1)
		return f(NumTypeInference, t1)
	else
		error("Numeric type inference is not defined for $f on $t1.")
	end
end

function resulttype(f::Function, t1::Type, t2::Type)
	if applicable(f, NumTypeInference, t1, t2)
		return f(NumTypeInference, t1, t2)
	else
		error("Numeric type inference is not defined for $f on ($t1, $t2).")
	end
end

function resulttype(f::Function, t1::Type, t2::Type, t3::Type)
	if applicable(f, NumTypeInference, t1, t2, t3)
		return f(NumTypeInference, t1, t2, t3)
	else
		error("Numeric type inference is not defined for $f on ($t1, $t2, $t3).")
	end
end


# import math functions

import Base.+, Base.-, Base.*, Base./, Base.^

# convert a numeric type to floating point

for t in [:Bool, :Int8, :Uint8, :Int16, :Uint16]
	@eval fptype(::Type{$t}) = Float32
end

for t in [:Int32, :Uint32, :Int64, :Uint64]
	@eval fptype(::Type{$t}) = Float64
end

fptype{T<:FloatingPoint}(::Type{T}) = T


# unary operators

for op in [:+, :-]
	@eval ($op){T1<:Number}(I::Type{NumTypeInference}, ::Type{T1}) = T1
end

- (I::Type{NumTypeInference}, T::Type{Bool}) = Int

~ {T<:Integer}(I::Type{NumTypeInference}, ::Type{T}) = T


# binary operators 

for op in [:+, :-, :*, :^]
	@eval ($op){T<:Number}(::Type{NumTypeInference}, ::Type{T}, ::Type{T}) = T
	@eval ($op){T1<:Number, T2<:Number}(::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(T1, T2)
end

+ (I::Type{NumTypeInference}, ::Type{Bool}, ::Type{Bool}) = Int
- (I::Type{NumTypeInference}, ::Type{Bool}, ::Type{Bool}) = Int

^ {T<:Integer}(I::Type{NumTypeInference}, ::Type{Bool}, ::Type{T}) = Bool

/ {T<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T}, ::Type{T}) = T
/ {T1<:FloatingPoint,T2<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(T1, T2)
/ {T1<:FloatingPoint,T2<:Integer}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = T1
/ {T1<:Integer,T2<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = T2
/ {T1<:Integer,T2<:Integer}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(fptype(T1), fptype(T2))

for op in [:&, :|]
	@eval ($op){T<:Integer}(::Type{NumTypeInference}, ::Type{T}, ::Type{T}) = T
	@eval ($op){T1<:Integer, T2<:Integer}(::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(T1, T2)
end

