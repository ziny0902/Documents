using CSV
using DataFrames
using LinearAlgebra

function read_data(path)
  csv_file = CSV.File(path; header=false, type=Float64)
  size(csv_file)
  df = DataFrame(csv_file)
  return df
end

# A: Matrix
# r: start row
# c: start col
# inc: increment
# e : end condition
function find_nonzero_row(A, r, c, inc, e)
  for i in r:inc:e
    if A[i, c] != 0 
      return i
    end
  end
  return -1
end

# 1. Swap the rows so that all rows 
# with all zero entries are on the bottom
# 2. Swap the rows so that the row with the largest, 
# leftmost nonzero entry is on top
# A: Matrix
# r: start row
# inc: increment
# e : end condition
function swap_zero_nonzero!(A, r, inc, e)
  row, col= size(A)
  if A[r,r] !=0
    return
  end
  for j in r:inc:e - inc
    for i in j:inc:e - inc
      nonzero = -1;
      if A[i, j] == 0
        nonzero = find_nonzero_row(A, i+1, j, inc, e)
      end
      if nonzero > 0
        tmp = A[nonzero, : ]
        A[nonzero, : ] .= A[i, : ] 
        A[i, : ] .= tmp
        j = i = nonzero - 1
      end
    end
  end
end

function gauss_jordan(A)
  (r, c) = size(A)
  A_I=[A Matrix(1.0I, r, c)]
  # forward elimination
  for i in 1:r
    swap_zero_nonzero!(A_I, i, 1, r)
    # 3. Multiply the top row by a scalar 
    # so that top row' leading entry becomes 1
    if A_I[i,i] != 0
      A_I[i, :] = A_I[i, :]/A_I[i,i]
    end
    # 4. Add/subtract multiples of the top row to the other rows
    # so that all other entries in column containing the top row's
    # leading entry are all zero
    for j in i+1:r
      A_I[j, :] = -1*A_I[j,i] * A_I[i, :] + A_I[j, :]
    end
  end
  # backward elimination
  for i in r:-1:2
    swap_zero_nonzero!(A_I, i, -1, 1)
    # 3. Multiply the bottom row by a scalar 
    # so that bottom row' leading entry becomes 1
    if A_I[i,i] != 0
      A_I[i, :] = A_I[i, :]/A_I[i,i]
    end
    # 4. Add/subtract multiples of the bottom row to the other rows
    # so that all other entries in column containing the bottom row's
    # leading entry are all zero
    for j in i-1:-1:1
      A_I[j, :] = -1*A_I[j,i] * A_I[i, :] + A_I[j, :]
    end
  end
  return A_I
end

function test_suit()
  df = read_data("data.csv")
  A = Matrix(df)
  return gauss_jordan(A)
end
