#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <math.h>

#define M_SIZE 32
#define E_SIZE 32

typedef struct
{
  char s;         // Segno vale '0' o '1'
  char m[M_SIZE]; // Mantissa definita come stringa
  char e[E_SIZE]; // Esponente definito come stringa '011' = 2^3
} FPX;

// Conversione Binario -> Decimale
int binaryToInteger(const char *);

// Conversione Decimale -> Binario
void integerToBinary(int, char *);

// Conversione Double -> FPX
FPX doubleToFPX(double);

// Conversione FPX -> Double
double FPXToDouble(const FPX *);

// Prodotto tra FPX
FPX FPXProduct(const FPX *, const FPX *);

void BitVectorAdd(const char *, const char *, char *);
void BitVectorProd(const char*, const char *, char *);


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
void integerToBinary(int input, char *output)
{
  // Voglio che abbia la dimensione di un intero * la dimensione di un byte,
  // non so quanto fosse grande in precedenza, quindi lo riassegno
  //
  // In caso l'area di memoria sia spostata la funzione chiamante non ne avrà accesso
  output = (char *)realloc(output, sizeof(int) * 8);

  if (output == NULL)
  {
    printf("Memory allocation failed\n");
    return;
  }

  for (int i = 0; i < sizeof(int) * 8; i++)
  {
    output[sizeof(int) * 8 - 1 - i] = (input & 1) ? '1' : '0';
    input >>= 1;
  }

  // Al termine della conversione l'output deve essere o 0 o 1
  // Se non è così, la conversione non è riuscita
  assert((input == 0 || input == 1) && "Conversione non riuscita");
}



void BitVectorAdd(const char *inputA, const char *inputB, char *output)
{
  // Implementing Carry Addition
  char carry = '0';
  int size;
  if (strlen(inputA) != strlen(inputB)) {
    fprintf(stderr, "Error: BitVectorAdd: strlen(inputA) != strlen(inputB),\
                      check the caller function\n");
  }
  size = strlen(inputA);
  // In caso l'area di memoria sia spostata la funzione chiamante non ne avrà accesso
  output = (char *)realloc(output, size * sizeof(char));
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
      break;
    }
  }
  return;
}

void BitVectorProd(const char *inputA, const char *inputB, char *output)
{
  int size;
  char carry = '0';
  if (strlen(inputA) != strlen(inputB)) {
    fprintf(stderr, "Error: BitVectorProd: strlen(inputA) != strlen(inputB),\
                      check the caller function\n");
  }
  size = strlen(inputA);
  char summatrix[size][size];
  memset(summatrix, '0', sizeof(char) * size * size);
  // In caso l'area di memoria sia spostata la funzione chiamante non ne avrà accesso
  output = (char *)realloc(output, size * sizeof(char));
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
    BitVectorAdd(output, summatrix[i], output);
  }
  return;
}

// Conversione Double -> FPX
FPX doubleToFPX(double input)
{
  int mantissa = 0, exponent = 0;
  FPX output = {.s = (input > 0) ? '1' : '0', .m = NULL, .e = NULL};

  // int64_t input_bits = *((int64_t *)&input); // Porto nella rappresentazione binaria il double
  // Found better way to do this
  union {
    double f;
    uint64_t i;
  } input_bits = {.f = input};

  mantissa = input_bits.i & 0x000FFFFFFFFFFFFF;         // Mantissa
  exponent = (input_bits.i & 0xEFF0000000000000) >> 52; // Esponente

  integerToBinary(mantissa, output.m);
  integerToBinary(exponent, output.e);

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

  return output;
}

// Somma tra FPX
FPX FPXSum(const FPX *inputA, const FPX *inputB)
{
  FPX output;

  return output;
}
