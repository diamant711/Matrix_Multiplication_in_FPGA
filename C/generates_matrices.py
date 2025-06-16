import numpy as np
import pandas as pd

# Dimensione della matrice
N = 100

# Genera due matrici 100x100 con valori casuali tra 0 e 100
A = np.random.rand(N, N) * 100
B = np.random.rand(N, N) * 100

# Salva le matrici come file CSV
file_A = 'matrice_A.csv'
file_B = 'matrice_B.csv'

pd.DataFrame(A).to_csv(file_A, header=False, index=False)
pd.DataFrame(B).to_csv(file_B, header=False, index=False)

print(f"Matrice A salvata in {file_A}")
print(f"Matrice B salvata in {file_B}")
