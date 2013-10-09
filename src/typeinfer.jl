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
import Base.~, Base.&, Base.|
import Base.==, Base.!=, Base.>, Base.>=, Base.<, Base.<=

import Base.max, Base.min, Base.div, Base.mod, Base.rem
import Base.floor, Base.ceil, Base.round, Base.trunc
import Base.ifloor, Base.iceil, Base.iround, Base.itrunc
import Base.abs, Base.abs2, Base.sqrt, Base.cbrt, Base.hypot
import Base.exp, Base.exp2, Base.exp10, Base.expm1
import Base.log, Base.log2, Base.log10, Base.log1p
import Base.sin, Base.cos, Base.tan, Base.asin, Base.acos, Base.atan, Base.atan2
import Base.sinh, Base.cosh, Base.tanh, Base.asinh, Base.acosh, Base.atanh
import Base.erf, Base.erfc, Base.gamma, Base.lgamma, Base.digamma


# convert a numeric type to floating point

for t in [:Bool, :Int8, :Uint8, :Int16, :Uint16]
	@eval fptype(::Type{$t}) = Float32
end

for t in [:Int32, :Uint32, :Int64, :Uint64]
	@eval fptype(::Type{$t}) = Float64
end

fptype{T<:FloatingPoint}(::Type{T}) = T


# unary functions

for op in [:+, :-, :floor, :ceil, :round, :trunc]
	@eval ($op){T1<:Real}(I::Type{NumTypeInference}, ::Type{T1}) = T1
end

for op in [:ifloor, :iceil, :iround, :itrunc]
	@eval ($op){T1<:Integer}(I::Type{NumTypeInference}, ::Type{T1}) = T1
	@eval ($op){T1<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T1}) = Int64
end


- (I::Type{NumTypeInference}, T::Type{Bool}) = Int

~ {T<:Integer}(I::Type{NumTypeInference}, ::Type{T}) = T

abs_rtype{T<:Real}(::Type{T}) = T
abs_rtype(::Type{Int8}) = Int
abs_rtype(::Type{Int16}) = Int
abs_rtype(::Type{Int32}) = Int
abs_rtype(::Type{Int64}) = Int64
abs_rtype(::Type{Uint8}) = Uint8
abs_rtype(::Type{Uint16}) = Uint16
abs_rtype(::Type{Uint32}) = Uint32
abs_rtype(::Type{Uint64}) = Uint64

abs{T<:Real}(I::Type{NumTypeInference}, ::Type{T}) = abs_rtype(T)

abs2_rtype{T<:Real}(::Type{T}) = T
abs2_rtype(::Type{Int8}) = Int
abs2_rtype(::Type{Int16}) = Int
abs2_rtype(::Type{Int32}) = Int
abs2_rtype(::Type{Int64}) = Int64
abs2_rtype(::Type{Uint8}) = Uint
abs2_rtype(::Type{Uint16}) = Uint
abs2_rtype(::Type{Uint32}) = Uint
abs2_rtype(::Type{Uint64}) = Uint64

abs2{T<:Real}(I::Type{NumTypeInference}, ::Type{T}) = abs2_rtype(T)

for op in [:sqrt, :cbrt, :rcp,
    :exp, :log, :log10, :exp2, :log2, :expm1, :log1p,
    :sin, :cos, :tan, :asin, :acos, :atan,
    :sinh, :cosh, :tanh, :asinh, :acosh, :atanh,
    :erf, :erfc, :gamma, :lgamma, :digamma]

    @eval ($op){T<:Real}(I::Type{NumTypeInference}, ::Type{T}) = fptype(T)
end


# binary operators 

for op in [:+, :-, :*, :^, :max, :min, :div, :mod, :rem]
	@eval ($op){T<:Real}(::Type{NumTypeInference}, ::Type{T}, ::Type{T}) = T
	@eval ($op){T1<:Real, T2<:Real}(::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(T1, T2)
end

+ (I::Type{NumTypeInference}, ::Type{Bool}, ::Type{Bool}) = Int
- (I::Type{NumTypeInference}, ::Type{Bool}, ::Type{Bool}) = Int

^ {T<:Integer}(I::Type{NumTypeInference}, ::Type{Bool}, ::Type{T}) = Bool

for op in [:/, :hypot, :atan2]
	@eval ($op){T<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T}, ::Type{T}) = T
	@eval ($op){T1<:FloatingPoint,T2<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(T1, T2)
	@eval ($op){T1<:FloatingPoint,T2<:Integer}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = T1
	@eval ($op){T1<:Integer,T2<:FloatingPoint}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = T2
	@eval ($op){T1<:Integer,T2<:Integer}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(fptype(T1), fptype(T2))
end

for op in [:&, :|]
	@eval ($op){T<:Integer}(I::Type{NumTypeInference}, ::Type{T}, ::Type{T}) = T
	@eval ($op){T1<:Integer, T2<:Integer}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = promote_type(T1, T2)
end

for op in [:(==), :(!=), :(>), :(>=), :(<), :(<=)]
	@eval ($op){T1<:Real, T2<:Real}(I::Type{NumTypeInference}, ::Type{T1}, ::Type{T2}) = Bool
end

