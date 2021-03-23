using Printf

function simple_diff(f, x, delta)
  return ( f(x+delta) - f(x-delta) )/(delta+delta) 
end
function diff2(f, x, delta)
  return ( f(x+delta) -2*f(x) + f(x-delta) )/(delta*delta)
end
# forward differantiation
function fdiff(f, x, delta)
  return ( f(x + delta) - f(x) )/delta - ( delta*diff2(f, x, delta) )/2
end
#partial derivative
function pdiff(f, v)
  z=[0.0,0.0]
  f_x(x) = f(x, v[2])
  f_y(x) = f(v[1], x)
  z[1] = fdiff(f_x, v[1], 0.001)
  z[2] = fdiff(f_y, v[2], 0.001)
  return z
end

function diff_test()
  eq(x) = sin(x^2)^2 
  delta = 0.02
  for x in 0:delta:pi
    @printf("%f,%f, %f,%f \n", x, eq(x), simple_diff(eq, x, delta), fdiff(eq, x, delta))
  end
end
