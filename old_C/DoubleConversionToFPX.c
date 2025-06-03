#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define N 100

#define S_MASK 0x8000000000000000ULL
#define E_MASK 0x7FF0000000000000ULL
#define M_MASK 0x000FFFFFFFFFFFFFULL

typedef uint64_t vbit;
typedef __uint128_t vbit_ext;

typedef union {
  vbit input;
  double output;
} conv;

void from_PC(vbit**, vbit**, char*, char*);
void print_uint128_bin(vbit);
void print_uint128_vm(vbit);
void load_memory(vbit**, vbit*, vbit, vbit);
vbit sum(vbit, vbit);
vbit prod(vbit, vbit, vbit);
vbit sum_vm(vbit, vbit);
vbit prod_vm(vbit, vbit);
void inner_product(vbit*, vbit*, vbit**, vbit, vbit);

int main(int argc, char** argv) {
  vbit matA[N][N];
  vbit matB[N][N];
  vbit matC[N][N];
  vbit row[N];
  vbit col[N];
  if(argc != 3) {
    printf("./main fileA fileB\n");
    exit(1);
  }
  from_PC(matA, matB, argv[0], argv[1]);
  for(vbit i = 0; i < N; i++) {
    for(vbit j = 0; j < N; j++) {
      load_memory(matA, row, i, 0);
      load_memory(matB, col, j, 1);
      inner_product(row, col, matC, i, j);
    }
  }
  return 0;
}

void from_PC(vbit** matA, vbit** matB, char* fileA, char* fileB) {
  FILE* fpA = fopen(fileA, "r");
  FILE* fpB = fopen(fileB, "r");
  char lineA[800];
  char lineB[800];
  char* tokenA;
  char* tokenB;
  double tmp = 0;
  if ((fpA == NULL) || (fpB == NULL)) {
    exit(1);
  }
  for (int i = 0; i < N; i++) {
    fgets(lineA, 800, fpA);
    fgets(lineB, 800, fpB);
    for (int j = 0; j < N; j++) {
      tokenA = strtok(lineA, ",");
      tokenB = strtok(lineB, ",");
      matA[i][j] = atof(tokenA);
      matB[i][j] = atof(tokenB);
      free(tokenA);
      free(tokenB);
    }
  }
  fclose(fpA);
  fclose(fpB);
  return;
}

// IA Generated
void print_vbit_bin(vbit value) {
  int started = 0; // Flag per evitare di stampare zeri iniziali non significativi
  for (int i = 63; i >= 0; i--) {
    int bit = (value >> i) & 1;
    if (bit || started || i == 0) {
      putchar(bit ? '1' : '0');
      started = 1;
    }
  }
}

void print_vbit_vm(vbit value) {
  conv c;
  vbit ieee = ((value<<1) & M_MASK);
  ieee |= (value & (E_MASK | S_MASK));
  c.input = ieee;
  printf("%lf", c.output*2);
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
    r |= (a & mask) ^ (b & mask) ^ carry;
    carry = (a & b) | (carry & (a ^ b));
    mask <<= 1;
  }
  return r;
}

vbit prod(vbit a, vbit b, vbit len) {
  vbit_ext r = 0;
  vbit_ext pr = 0;
  vbit mask = 1;
  vbit output_mask = 0x000FFFFFFFFFFFFF;
  for (vbit i = 0; i < (sizeof(vbit) * 8); i++) {
    for (vbit j = 0; j < (sizeof(vbit) * 8); j++) {
      pr = pr | ((a & (mask << j)) & (b & (mask << i)));
    }
    pr <<= i;
    r = sum(r, pr);
  }
  if((r & (3ull<<50)) == (1ull<<50)) {
    r <<= 1;
  }
  r >>= 63;
  r &= output_mask;
  return (vbit)r;
}

vbit sum_vm(vbit a, vbit b) {
  vbit r = 0;
  vbit a_s = (a & S_MASK) >> 63;
  vbit b_s = (b & S_MASK) >> 63;
  vbit a_m = (a & M_MASK) >> 0;
  vbit b_m = (b & M_MASK) >> 0;
  vbit a_e = (a & E_MASK) >> 52;
  vbit b_e = (b & E_MASK) >> 52;
  if (a_e > b_e) {
    b_m >>= sum(a_e, ~b_e);
  } else if (a_e < b_e) {
    a_m >>= sum(b_e, ~a_e);
  }
  //xor
  if (((a_s==1ull)&&(!(b_s==1ull)))||((!(a_s==1ull))&&(b_s==1ull))) {
    //discordi
    if (a_s == 1) {
      if (a_m > b_m) {
        r |= (~sum(b_m, ~a_m)) << 0;
        r |= (1ull<<63);
      } else if (b_m > a_m) {
        r |= sum(b_m, ~a_m) << 0;
        r |= 0;
      }
    } else if (b_s == 1) {
      if (a_m > b_m) {
        r |= sum(a_m, ~b_m) << 0;
        r |= 0;
      } else if (b_m > a_m) {
        r |= (~sum(a_m, ~b_m)) << 0;
        r |= (1ull<<63);
      }
    }
    r |= a_e;
  } else {
    //concordi
    r |= (a_s == 1ull) ? (1ull<<63) : 0;
    r |= sum(a_m, b_m) << 0;
    r |= a_e;
  }
  return r;
}

vbit prod_vm(vbit a, vbit b) {
  vbit r = 0;
  r |= (sum((a & S_MASK) >> 63,(b & S_MASK) >> 63) == 1ull) ? (1ull<<63) : 0;
  r |= prod((a & M_MASK)>>0, (b & M_MASK)>>0, 52) << 0;
  r |= sum((a & E_MASK) >> 51, (b & E_MASK) >> 51) << 51;
  return r;
}

void inner_product(vbit* row, vbit* col, vbit** matC, vbit i, vbit j) {
  vbit partial = 0;
  for (vbit k = 0; k < N; k++) {
    partial = sum_vm(partial, prod_vm(row[k], col[k]));
  }
  matC[i][j] = partial;
  return;
}
