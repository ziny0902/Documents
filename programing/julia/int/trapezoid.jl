using Printf
# v := [start, end]
function trapezoid(f, v, delta)
  f_s = f(v[1])
  f_e = f(v[2])
  sum = 0
  for x in v[1]+delta:delta:v[2] - delta
    sum = sum + f(x)
  end
  return (f_s/2 + sum + f_e/2)*delta
end

# adaptive Gauss-Kronrod quadrature
using QuadGK
function test_suit()
  integral = trapezoid(x->1/x, [1,3], 0.1)
  @printf("%f\n", integral)
  integral, err = quadgk(x -> 1/x, 1, 3, rtol=1e-8)
  @printf("%f\n", integral)
end
