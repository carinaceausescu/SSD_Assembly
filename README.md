# Allocator de Memorie — Proiect Assembly

## Descriere Proiect
Acest proiect implementează un **simulator de gestionare a memoriei**, inspirat de modul în care sunt administrate blocurile într-un dispozitiv de tip SSD. Programul este scris în Assembly (sintaxă AT&T / GAS) și gestionează un spațiu de memorie liniar, în care blocurile pot fi alocate, căutate, șterse și compactate.

Fiecare bloc este identificat printr-un **file descriptor (`fd`)** și are o dimensiune exprimată în kilobytes, rotunjită automat la multipli de 8.

## Operații Implementate
- **ADD(fd, size_kb)** – alocă un bloc de memorie
- **GET(fd)** – returnează intervalul de memorie ocupat de bloc
- **DELETE(fd)** – șterge toate aparițiile unui bloc
- **DEFRAG()** – compactează memoria eliminând spațiile libere dintre blocuri

Programul citește o serie de operații din input și afișează rezultatul fiecărei comenzi.

## Structura Repository-ului
- `task.asm` – implementarea principală în Assembly
- `generator.py` – script pentru generarea de input pentru testare
- `checker.py` – script pentru verificarea output-ului
- `input.txt` – exemplu de input

## Autor

**Carina Ceaușescu**
- [GitHub](https://github.com/carinaceausescu)
- [LinkedIn](https://www.linkedin.com/in/carina-ceausescu/)
