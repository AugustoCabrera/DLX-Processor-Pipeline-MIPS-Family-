# Registros del MIPS 🧮

## Introducción
MIPS (Microprocessor without Interlocked Pipeline Stages) es una arquitectura de conjunto de instrucciones (ISA) ampliamente utilizada en sistemas embebidos y académicos. En esta arquitectura, los registros son un componente esencial para el almacenamiento temporal de datos y el control de la ejecución de instrucciones.

Este documento detalla todos los registros del MIPS, incluyendo su nombre, propósito y convenciones de uso.

---

## Tabla de registros

<p align="center"> <img src="../img/image21.png" alt=""> </p>

### Registros de Propósito General (GPR)

| Número | Nombre | Alias  | Uso principal                                                                 |
|---------|--------|--------|------------------------------------------------------------------------------|
| $0      | zero   | -      | Siempre contiene el valor 0.                                               |
| $1      | at     | -      | Registrador temporal reservado para el ensamblador.                        |
| $2-$3   | v0-v1  | -      | Valores de retorno para funciones.                                         |
| $4-$7   | a0-a3  | -      | Argumentos para funciones (los primeros cuatro).                           |
| $8-$15  | t0-t7  | -      | Temporales (no preservados entre llamadas a funciones).                    |
| $16-$23 | s0-s7  | -      | Temporales preservados (mantienen su valor entre llamadas a funciones).     |
| $24-$25 | t8-t9  | -      | Temporales adicionales (no preservados entre llamadas a funciones).         |
| $26-$27 | k0-k1  | -      | Reservados para el kernel (usados por el sistema operativo).                |
| $28     | gp     | -      | Global pointer (puntero a datos globales).                                 |
| $29     | sp     | -      | Stack pointer (puntero a la pila).                                         |
| $30     | fp     | s8     | Frame pointer (puntero al marco actual).                                   |
| $31     | ra     | -      | Return address (almacena la dirección de retorno para funciones).           |

### Registros Especiales

| Nombre  | Descripción                                                                                   |
|---------|-----------------------------------------------------------------------------------------------|
| HI      | Acumulador alto para resultados de multiplicación y división.                                |
| LO      | Acumulador bajo para resultados de multiplicación y división.                                |
| PC      | Program Counter, apunta a la siguiente instrucción a ejecutar.                               |

---

## Descripción detallada

### Registros de Propósito General (GPR)

1. **$zero ($0)**:
   - Valor constante de 0. Utilizado para operaciones que requieren un cero constante, como inicialización de registros o comparaciones.

2. **$at ($1)**:
   - Reservado para el ensamblador y no debe ser usado directamente en programas.

3. **$v0-$v1 ($2-$3)**:
   - Utilizados para almacenar valores de retorno de funciones. Por ejemplo, si una función devuelve un entero, este se almacenará en $v0.

4. **$a0-$a3 ($4-$7)**:
   - Contienen los argumentos de las funciones (hasta cuatro argumentos). Si hay más de cuatro, se pasan por la pila.

5. **$t0-$t7 ($8-$15) y $t8-$t9 ($24-$25)**:
   - Registros temporales que pueden ser sobrescritos en cualquier momento. Usados para cálculos intermedios.

6. **$s0-$s7 ($16-$23)**:
   - Registros preservados. Su valor debe mantenerse constante entre llamadas a funciones, y es responsabilidad del programador o del compilador guardar y restaurar estos valores cuando se usen.

7. **$gp ($28)**:
   - Puntero global. Facilita el acceso a variables globales en programas.

8. **$sp ($29)**:
   - Puntero a la pila. Usado para gestionar el almacenamiento temporal y las llamadas a funciones.

9. **$fp ($30)**:
   - Puntero al marco actual. Es un registro opcional, pero útil para simplificar el acceso a variables locales en funciones.

10. **$ra ($31)**:
    - Dirección de retorno. Contiene la dirección a la que debe regresar el programa después de una llamada a función.

### Registros Especiales

1. **HI y LO**:
   - Estos registros se utilizan para almacenar los resultados de operaciones de multiplicación y división:
     - Multiplicación: el resultado de 64 bits se divide entre HI (bits altos) y LO (bits bajos).
     - División: el cociente se almacena en LO y el residuo en HI.

2. **PC (Program Counter)**:
   - Contiene la dirección de la próxima instrucción a ejecutar. Es gestionado automáticamente por el hardware.

---

## Convenciones de uso

En MIPS, las convenciones de llamada especifican cómo deben usarse los registros en el contexto de funciones:

- **Registros preservados** ($s0-$s7, $sp, $fp, $ra):** El llamador espera que mantengan su valor original. Si una función los modifica, debe restaurarlos antes de regresar.
- **Registros no preservados** ($t0-$t9, $a0-$a3, $v0-$v1):** Estos pueden ser sobrescritos libremente por las funciones llamadas.
- **Pila**: Los valores que no caben en los registros deben guardarse en la pila.


---

## Referencias
- Manual de Referencia MIPS
- Documentación del ensamblador MIPS

---

Esperamos que esta información sea útil para tu aprendizaje y proyectos con MIPS. Si tienes preguntas, no dudes en consultarnos.

