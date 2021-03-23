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
  U=Matrix(A)
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
