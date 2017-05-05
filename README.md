# Inkel Pentiun processor
"Blocking is for cowards, but it always works" - Development Team, 2017

## Etapas de implementación
1. Set completo de instrucciones sin caché (directamente memoria)
2. Caché
 * Instrucciones: Caché directa
 * Datos: Caché totalmente asociativa con política de reemplazo LRU y copy-back
3. Set completo de bypasses
4. Excepciones
5. Reorder Buffer and Store Buffer
6. Memoria virtual
7. Branch Predictor
8. Out of order execution

## Etapas del procesador segmentado
Fetch - Decode - ALU - Write Back

Fetch - Decode - ALU - Cache - Write Back

Fetch - Decode - M1 - M2 - M3 - M4 - M5 - Write Back
