#include<stdio.h>

#define M_SIZE 32
#define E_SIZE 32

typedef struct {
  char s;
  char m[M_SIZE];
  char e[E_SIZE];
} FPX;

//Conversione Binario -> Decimale
int binaryToInteger(const char*);

//Conversione Decimale -> Binario
void integerToBinary(int, char*);

//Conversione Double -> FPX
FPX doubleToFPX(double);

//Conversione FPX -> Double
double FPXToDouble(const FPX*);

//Prodotto tra FPX
FPX FPXProduct(const FPX*, const FPX*);

//Somma tra FPX
FPX FPXSum(const FPX*, const FPX*);

int main(int argc, char** argv) {

  return 0;
}

//Conversione Binario -> Decimale
int binaryToInteger(const char* input) {
  int output;

  return output;
}

//Conversione Decimale -> Binario
void integerToBinary(int input, char* output) {

}

//Conversione Double -> FPX
FPX doubleToFPX(double input) {
  FPX output;

  return output;
}

//Conversione FPX -> Double
double FPXToDouble(const FPX* input) {
  double output;

  return output;
}

//Prodotto tra FPX
FPX FPXProduct(const FPX* inputA, const FPX* inputB) {
  FPX output;

  return output;
}

//Somma tra FPX
FPX FPXSum(const FPX* inputA, const FPX* inputB) {
  FPX output;

  return output;
}
