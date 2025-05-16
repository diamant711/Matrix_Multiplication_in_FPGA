#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#define M_SIZE 32
#define E_SIZE 32

typedef struct
{
  char s;         // Segno vale '0' o '1'
  char m[M_SIZE]; // Mantissa definita come stringa
  char e[E_SIZE]; // Esponente definito come stringa '010' = 2^2
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

// Conversione Double -> FPX
FPX doubleToFPX(double input)
{
  int mantissa = 0, exponent = 0;
  FPX output = {.s = (input > 0) ? '1' : '0', .m = NULL, .e = NULL};

  int64_t input_bits = *((int64_t *)&input);

  mantissa = input_bits & 0x000FFFFFFFFFFFFF;         // Mantissa
  exponent = (input_bits & 0xEFF0000000000000) >> 52; // Esponente

  integerToBinary(mantissa, output.m);
  integerToBinary(exponent, output.e);

  return output;
}

// Conversione FPX -> Double
double FPXToDouble(const FPX *input)
{
  double output;

  return output;
}

// Prodotto tra FPX
FPX FPXProduct(const FPX *inputA, const FPX *inputB)
{
  FPX output;

  return output;
}

void BitVectorAdd(const char *inputA, const char *inputB, char *output)
{
  // Implementing Carry Addition
  char carry = '0';

  return;
}

void BitVectorProd(const char *first, const char *second, char *out)
{

  return;
}

// Somma tra FPX
FPX FPXSum(const FPX *inputA, const FPX *inputB)
{
  FPX output;

  return output;
}
