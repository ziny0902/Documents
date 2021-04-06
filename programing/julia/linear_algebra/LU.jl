using LinearAlgebra

# A: Matrix
# r: start row
# c: start col
# inc: increment
# e : end condition
function find_max_row(A, r, c, inc, e)
  tmp = 0
  idx = r
  for i in r:inc:e
    v = abs(A[i, c])
    if tmp < v
      tmp = v
      idx = i
    end
  end
  return idx 
end

function lu_factorization(A)
  (r, c) = size(A)
  # Initialize U=A, L=I
  U=Matrix{Float64}(A)
  L=Matrix(1.0I, r, c)
  p=collect(1:3)
  for k in 1:r-1
    # find i>= k to maximize |U(i,k)|
    i = find_max_row(U, k, k, 1, r)
    if k != i
      # U(k, k:m) <--> U(i, k:m)
      # L(k, 1:k-1) <--> L(i, 1:k-1)
      # P(k,:) <--> p(i,:)
      tmp = U[k, k:r]
      U[k, k:r] = U[i, k:r ]
      U[i, k:r ] = tmp
      tmp = L[k, 1 : k-1]
      L[k, 1 : k-1] = L[i, 1 : k-1]
      L[i, 1 : k-1] = tmp
      tmp = p[k]
      p[k] = p[i]
      p[i] = tmp
    end
    for j in k+1:r
      if U[k,k] != 0
        L[j,k] = U[j,k]/U[k,k]
        U[j,k:r] = U[j, k:r] - L[j,k]*U[k, k:r]
      end
    end
  end
  return L,U, p 
end

function diagonal_err(A, B)
  n, m = size(A)
  err = 0
  for i = 1:n
    err = err + abs(A[i,i] - B[i,i])
  end
  return err
end

function lu_eigenvalue(A)
  n,m = size(A)
  for i in 1:100
    L,U,p = lu_factorization(A)
    A=U*L
    if diagonal_err(U, A) < 0.1
      break
    end
  end
  eigenval=zeros(Float64, m)
  # eigenvalue is diagonal value of matrix A
  for i in 1:m
    eigenval[i] = A[i, i]
  end
  return eigenval, U, L
end

# julia basic expression : U\(L\b[p])
# forward_sub : Ly=b 
function lu_forward_sub(L, p, b)
  (n,) = size(p)
  b=Array{Float64}(b[p])
  x = zeros(Float64, n)
  for i in 1:n
    tmp = b[i]
    for j in 1:i-1
      tmp = tmp - L[i, j]*x[j]
    end
    x[i] = tmp/L[i,i]
  end
  return x
end

# backword sub: Ux=y
function lu_backward_sub(U, y)
  (n,) = size(p)
  b=Array{Float64}(y)
  x = zeros(Float64, n)
  for i in n:-1:1 
    tmp = b[i]
    for j in i+1:n 
      tmp = tmp - U[i, j]*x[j]
    end
    x[i] = tmp/U[i,i]
  end
  return x
end
