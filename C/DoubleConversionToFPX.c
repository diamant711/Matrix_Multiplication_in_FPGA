#include <stdio.h>

#define N 100

typedef __uint128_t vbit;

void print_uint128_bin(vbit);
void load_memory(vbit**, vbit*, vbit, vbit);
vbit sum(vbit, vbit);
vbit prod(vbit, vbit);
vbit sum_vm(vbit, vbit);
vbit prod_vm(vbit, vbit);
void inner_product(vbit*, vbit*, vbit**, vbit, vbit);

int main(void) {
  vbit matA[N][N];
  vbit matB[N][N];
  vbit matC[N][N];
  vbit row[N];
  vbit col[N];
  for(vbit i = 0; i < N; i++) {
    for(vbit j = 0; j < N; j++) {
      load_memory(matA, row, i, 0);
      load_memory(matB, col, j, 1);
      inner_product(row, col, matC, i, j);
    }
  }
  return 0;
}

// IA Generated
void print_uint128_bin(__uint128_t value) {
    int started = 0; // Flag per evitare di stampare zeri iniziali non significativi
    for (int i = 127; i >= 0; i--) {
        int bit = (value >> i) & 1;
        if (bit || started || i == 0) {
            putchar(bit ? '1' : '0');
            started = 1;
        }
    }
    putchar('\n');
}

void load_memory(vbit** mat, vbit* vet, vbit i, vbit mode) {
  if(mode == 0) { //Row
    for (vbit j = 0; j < N; j++) {
      vet[j] = mat[i][j];
    }
  } else if (mode == 1) { //Col
    for (vbit j = 0; j < N; j++) {
      vet[j] = mat[i][j];
    }
  } else {
    fprintf(stderr, "Error: load_memory: error on mode selction\n");
  }
  return;
}

vbit sum(vbit a, vbit b) {
  vbit r = 0;
  vbit mask = 1;
  vbit carry = 0;
  for (vbit i = 0; i < (sizeof(vbit) * 8); i++) {
    r = r | (((a & mask) ^ (b & mask)) ^ carry);
    carry = (a & b) & carry;
    mask <<= 1;
  }
  return r;
}
vbit prod(vbit a, vbit b) {
  vbit r = 0;
  vbit pr = 0;
  vbit mask = 1;
  for (vbit i = 0; i < (sizeof(vbit) * 8); i++) {
    for (vbit j = 0; j < (sizeof(vbit) * 8); j++) {
      pr = pr | ((a & (mask << j)) & (b & (mask << i)));
    }
    pr <<= i;
    r = sum(r, pr);
  }
  r >>= 64;
  return (vbit)r;
}

vbit sum_vm(vbit a, vbit b) {
  vbit r = 0;
  return r;
}

vbit prod_vm(vbit a, vbit b) {
  vbit r = 0;
  return r;
}

void inner_product(vbit* row, vbit* col, vbit** matC, vbit i, vbit j) {
  vbit partial = 0;
  for (vbit k = 0; k < N; k++) {
    partial = sum_vm(partial, prod_vm(row[i], col[i]));
  }
  return;
}
