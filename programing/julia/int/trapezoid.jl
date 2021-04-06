using Printf
# v := [start, end]
function trapezoid(f, v, m)
  f_s = f(v[1])
  f_e = f(v[2])
  sum = 0
  h = (v[2] - v[1]) / m
  for x in v[1] + h : h : v[2] - h 
    sum = sum + f(x)
  end
  return (f_s + 2*sum + f_e)*h/2
end

# adaptive Gauss-Kronrod quadrature
using QuadGK
function test_suit()
  integral = trapezoid(x->1/x, [1,3], 10)
  @printf("%f\n", integral)
  integral, err = quadgk(x -> 1/x, 1, 3, rtol=1e-8)
  @printf("%f\n", integral)
end
