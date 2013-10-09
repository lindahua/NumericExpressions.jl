## Expression types

abstract AbstractNumExpr{NArgs} 

immutable NumLiteral{T<:Number} <: AbstractNumExpr{0}
	value::T
end

immutable NumSymbol <: AbstractNumExpr{0}
	sym::Symbol
end

immutable NumFunc
	sym::Symbol
end

type UnaryNumExpr{A1<:AbstractNumExpr} <: AbstractNumExpr{1}
	fun::NumFunc
	arg1::A1
end

type BinaryNumExpr{A1<:AbstractNumExpr,A2<:AbstractNumExpr} <: AbstractNumExpr{2}
	fun::NumFunc
	arg1::A1
	arg2::A2
end

type TernaryNumExpr{A1<:AbstractNumExpr,A2<:AbstractNumExpr,A3<:AbstractNumExpr} <: AbstractNumExpr{3}
	fun::NumFunc
	arg1::A1
	arg2::A2
	arg3::A3
end

## uniform constructor: numexpr

numexpr{T<:Number}(v::T) = NumLiteral{T}(v)
numexpr(s::Symbol) = NumSymbol(s)

function numexpr{A1<:AbstractNumExpr}(f::NumFunc, a1::A1)
	UnaryNumExpr{A1}(f, a1)
end

function numexpr{A1<:AbstractNumExpr,A2<:AbstractNumExpr}(f::NumFunc, a1::A1, a2::A2)
	BinaryNumExpr{A1,A2}(f, a1, a2)
end

function numexpr{A1<:AbstractNumExpr,A2<:AbstractNumExpr,A3<:AbstractNumExpr}(f::NumFunc, a1::A1, a2::A2, a3::A3)
	TernaryNumExpr{A1,A2,A3}(f, a1, a2, a3)
end

numexpr(f::Symbol, a1::AbstractNumExpr) = numexpr(NumFunc(f), a1)
numexpr(f::Symbol, a1::AbstractNumExpr, a2::AbstractNumExpr) = numexpr(NumFunc(f), a1, a2)
numexpr(f::Symbol, a1::AbstractNumExpr, a2::AbstractNumExpr, a3::AbstractNumExpr) = numexpr(NumFunc(f), a1, a2, a3)

