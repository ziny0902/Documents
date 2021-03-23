using Printf
using ForwardDiff

function ex_mesh_graph()
  f(x,y)=x^3+2*x^2*y

  x=zeros( (9, 9) )
  y=zeros( (9, 9) )

  for i in 1:9
    for j in 1:9
      x[i,j]= -1 + 0.5*j
      y[j,i]= -1 + 0.5*j
    end
  end
  for i in 1:9
    for j in 1:9
      z=f(x[i,j], y[i,j]);
      @printf("%f, %f, %f\n", x[i,j], y[i,j], z )
    end
    println("")
  end
end

function ex_partial_derivative()
  f(x,y)=√(4 - x^2 - y^2)
  f_v(v) = f(v[1], v[2])
  Δf(v) = ForwardDiff.gradient(f_v, v)
  Δf([1,1])
end
