# Implementazione di un moltiplicatore tra matrici in VHDL

Progetto per il corso di metodi computazionali per la fisica presso UniMi di Stefano Pilosio (RandDouble) e Riccardo Osvaldo Nana (diamant).

## Obbiettivo

Realizzare una struttura che sfrutta più moltiplicatori per eseguire la moltiplicazione tra matrici, sfruttando la struttura fortemente parallela delle FPGA.

## Struttura del progetto

Il progetto è diviso in due parti: 
- un codice C
- l'effettiva implementazione in VHDL.

Il codice C è una proof of concept per verificare anche le eventuali problematiche prima dell'implementazione in VHDL.
Serve inoltre a testare la struttura di base che si rende necessaria per le macchine a stati presenti nel moltiplicatore.

Il codice in VHDL è stato pensato per FPGA Xilinx AMD, usando il sintetizzatore messo a disposizione in Xilinx AMD Vivado 2024.2.

## Funzionalità

Al momento il progetto è funzionante nelle singole componenti, vi sono tuttavia problemi nell'accesso alla memoria dei moltiplicatori, probabilmente legato al controller implementato.
Vi sono inoltre delle problematiche nella comunicazione con il computer.

