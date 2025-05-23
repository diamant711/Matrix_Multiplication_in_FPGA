#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <math.h>

#define M_SIZE 53
#define E_SIZE 12
#define STRLEN_LIMIT 128

typedef struct
{
  char s;         // Segno vale '0' o '1'
  char m[M_SIZE]; // Mantissa definita come stringa
  char e[E_SIZE]; // Esponente definito come stringa '011' = 2^3
} FPX;

// Conversione Binario -> Decimale
int binaryToInteger(const char *);

// Conversione Decimale -> Binario
char* integerToBinary(int);

// Somma tra vettori di bit
char* BitVectorAdd(const char *, const char *);

// Prodotto tra vettori di bit
char* BitVectorProd(const char*, const char *);

// Shift vettore di bit
void BitVectorShift(char*, char);

// Conversione Double -> FPX
FPX doubleToFPX(double);

// Conversione FPX -> Double
double FPXToDouble(const FPX *);

// Prodotto tra FPX
FPX FPXProduct(const FPX *, const FPX *);

// Somma tra FPX
FPX FPXSum(const FPX *, const FPX *);

int main(int argc, char **argv)
{

  return 0;
}

// Conversione Binario -> Decimale
int binaryToInteger(const char *input)
{
  int output = 0;

  while (*input != '\0')
  {
    output <<= 1;
    output += (*input == '0') ? 0 : 1;
    input++;
  }

  return output;
}

// Conversione Decimale -> Binario
char* integerToBinary(int input)
{
  size_t size = sizeof(int) * 8;
  char* output = (char *)malloc(size + 1);
  if (output == NULL)
  {
    printf("Error: integerToBinary: Memory allocation failed\n");
    exit(1);
  }
  memset(output, '\0', size + 1);

  for (int i = 0; i < size; i++)
  {
    output[size - 1 - i] = ((input & 1) == 1) ? '1' : '0';
    input >>= 1;
  }
  return output;
}



char* BitVectorAdd(const char *inputA, const char *inputB)
{
  char carry = '0';
  int size;
  if  ((strnlen(inputA, STRLEN_LIMIT) == STRLEN_LIMIT)
     &&(strnlen(inputB, STRLEN_LIMIT) == STRLEN_LIMIT)) {
    fprintf(stderr, "Error: BitVectorAdd: input vector not null-terminated,\
                      check the caller function\n");
    exit(1);
  }
  if (strnlen(inputA, STRLEN_LIMIT) != strnlen(inputB, STRLEN_LIMIT)) {
    fprintf(stderr, "Error: BitVectorAdd: strlen(inputA) != strlen(inputB),\
                      check the caller function\n");
    exit(1);
  }
  size = strnlen(inputA, STRLEN_LIMIT);
  char* output = (char *)malloc((size + 1) * sizeof(char));
  if(output == NULL) {
    printf("Error: BitVectorAdd: Memory allocation failed\n");
    exit(1);
  }
  memset(output, '\0', size + 1);
  for (int i = 0; i < size; i++) {
    switch(((inputA[i]-48) + (inputB[i]-48) + (carry-48))) {
      case 0:
        output[i] = '0';
        carry = '0';
      break;
      case 1:
        output[i] = '1';
        carry = '0';
      break;
      case 2:
        output[i] = '0';
        carry = '1';
      break;
      case 3:
        output[i] = '1';
        carry = '1';
      break;
      default:
        fprintf(stderr, "Error: BitVectorAdd: Unexpected error\n");
        exit(1);
      break;
    }
  }
  return output;
}

char* BitVectorProd(const char *inputA, const char *inputB)
{
  int size;
  if  ((strnlen(inputA, STRLEN_LIMIT) == STRLEN_LIMIT)
     &&(strnlen(inputB, STRLEN_LIMIT) == STRLEN_LIMIT)) {
    fprintf(stderr, "Error: BitVectorAdd: input vector not null-terminated,\
                      check the caller function\n");
    exit(1);
  }
  if (strnlen(inputA, STRLEN_LIMIT) != strnlen(inputB, STRLEN_LIMIT)) {
    fprintf(stderr, "Error: BitVectorAdd: strlen(inputA) != strlen(inputB),\
                      check the caller function\n");
    exit(1);
  }
  size = strnlen(inputA, STRLEN_LIMIT);
  char summatrix[size][size];
  memset(summatrix, '0', sizeof(char) * size * size);
  char* output = (char *)malloc((size + 1) * sizeof(char));
  if(output == NULL) {
    printf("Error: BitVectorProd: Memory allocation failed\n");
    exit(1);
  }
  memset(output, '0', sizeof(char) * size);
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      if ((inputA[i] == '1') && (inputB[j] == '1')) {
        summatrix[i][i + j] = '1';
      } else {
        summatrix[i][i + j] = '0';
      }
    }
  }
  for (int i = 0; i < size; i++) {
    output = BitVectorAdd(output, summatrix[i]);
  }
  output[size + 1] = '\0';
  return output;
}

// Shift vettore di bit
void BitVectorShift(char* vett, char mode) {
  size_t size = strnlen(vett, STRLEN_LIMIT);
  if (size == STRLEN_LIMIT) {
    fprintf(stderr, "Error: BitVectorShift: caller sent a non null-terminated bit vector\n");
  }
  switch(mode) {
    case 'd':
      for(int i = (size - 1); i > 0; i--) {
        vett[i] = vett[i-1];
      }
      vett[0] = '0';
    break;
    case 's':
      for(int i = 0; i < (size - 1); i++) {
        vett[i] = vett[i+1];
      }
      vett[size - 1] = '0';
    break;
    default:
      fprintf(stderr, "Error: BitVectorShift: caller sent a char mode undefined\n");
      exit(1);
    break;
  }
  return;
}

// Conversione Double -> FPX
FPX doubleToFPX(double input)
{
  int mantissa = 0, exponent = 0;
  FPX output;
 output.s = (input > 0) ? '1' : '0';
  output.m[52] = '\0';
  output.e[11] = '\0';

  // int64_t input_bits = *((int64_t *)&input); // Porto nella rappresentazione binaria il double
  // Found better way to do this
  union {
    double f;
    uint64_t i;
  } input_bits = {.f = input};

  mantissa = input_bits.i & 0x000FFFFFFFFFFFFF;         // Mantissa
  exponent = (input_bits.i & 0xEFF0000000000000) >> 52; // Esponente

  char* tmp = NULL;
  tmp = integerToBinary(mantissa);
  strcpy(output.m, tmp);
  free(tmp);
  tmp = integerToBinary(exponent);
  strcpy(output.e, tmp);
  free(tmp);

  return output;
}

// Conversione FPX -> Double
double FPXToDouble(const FPX *input)
{
  double output;
  double mantissa = 0;
  int size = strlen(input->m);
  for (int i = 0; i < size; i++) {
    mantissa += (input->m)[i] * pow(2, (-1) * i);
  }
  output = ((input->s == '1') ? -1 : 1)
           * (1.0 + mantissa)
           * pow(2, 1024 - binaryToInteger(input->e));
  return output;
}

// Prodotto tra FPX
FPX FPXProduct(const FPX *inputA, const FPX *inputB)
{
  FPX output;
  output.s = (inputA->s == inputB->s) ? '0' : '1';
  char* tmp = NULL;
  tmp = BitVectorProd(inputA->m, inputB->m);
  strcpy(output.m, tmp);
  free(tmp);
  tmp = BitVectorAdd(inputA->e, inputB->e);
  strcpy(output.e, tmp);
  free(tmp);
  return output;
}

// Somma tra FPX
FPX FPXSum(const FPX *inputA, const FPX *inputB)
{
  FPX output;

  return output;
}
