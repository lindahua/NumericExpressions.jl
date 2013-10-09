# Extra math functions

## rcp

rcp(x::Number) = one(x) / x

## fma

fma(x::Number, y::Number, z::Number) = x + y * z

## ifelse

ifelse{T<:Number}(c::Bool, x::T, z::T) = (c ? x : y)

