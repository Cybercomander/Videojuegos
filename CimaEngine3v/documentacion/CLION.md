# CimaEngine3v en CLion (macOS / Apple Silicon)

Guía de la configuración que ya está aplicada en este repo: perfiles de build,
configuraciones de Run/Debug, profiling de CPU y RAM, y las herramientas de
calidad de código integradas al IDE.

---

## 0. Primer arranque (una sola vez)

1. **Reinicia CLion.** Se cambió `.idea/misc.xml`, y CLion sólo lee ese archivo
   al abrir el proyecto.
2. Al abrir, CLion detecta `CimaEngine3v/CMakePresets.json` y ofrece habilitar
   los presets: acepta. Si no aparece el aviso:
   *Settings ▸ Build, Execution, Deployment ▸ CMake* → pestaña de presets →
   habilita `Debug`, `Release`, `RelWithDebInfo` y `ASan`.
3. `Tools ▸ CMake ▸ Reset Cache and Reload Project`.

> **Por qué el reinicio:** antes CLion tenía la raíz de CMake apuntando a
> `CimaEngine3v/src`, que no es un proyecto CMake válido por sí solo (no tiene
> `cmake_minimum_required` ni las dependencias). Ahora apunta a `CimaEngine3v/`.

---

## 1. Perfiles de build (`CMakePresets.json`)

Cada perfil tiene su propio folder de build y su propio ejecutable, así que
nunca se pisan entre sí.

| Perfil           | Folder de build              | Ejecutable            | Para qué sirve |
|------------------|------------------------------|-----------------------|----------------|
| `Debug`          | `cmake-build-debug`          | `bin/Debug`           | Día a día. Editor ImGui activo (`DEBUG=1`), `-g -Wall -Wextra -Werror`. |
| `Release`        | `cmake-build-release`        | `bin/Release`         | Entrega. `-O2`, sin editor (`DEBUG=0`). |
| `RelWithDebInfo` | `cmake-build-relwithdebinfo` | `bin/RelWithDebInfo`  | **Profiling de CPU.** `-O2 -g -fno-omit-frame-pointer`: rápido pero con símbolos y stacks legibles. |
| `ASan`           | `cmake-build-asan`           | `bin/ASan`            | **Cacería de bugs de memoria.** AddressSanitizer + UndefinedBehaviorSanitizer, con el editor activo. |

Todos comparten las fuentes de ImGui e ImGui-SFML en `.cache/deps/`
(`FETCHCONTENT_SOURCE_DIR_*`), así que **ningún perfil vuelve a clonar los
139 MB de ImGui**. SFML viene de Homebrew (`find_package`), como ya hacía el
`CMakeLists.txt`.

Desde la terminal siguen funcionando igual:

```bash
cmake --preset Debug && cmake --build --preset Debug
```

---

## 2. Run / Debug

Cuatro configuraciones en el selector de la barra superior. En CLion **Run y
Debug son el mismo config**: ▶ lo corre, 🐞 lo corre bajo LLDB con breakpoints.

| Configuración                 | Perfil que usa   | Notas |
|-------------------------------|------------------|-------|
| `CimaEngine3v Debug`          | `Debug`          | La de todos los días. |
| `CimaEngine3v Release`        | `Release`        | Para ver el juego sin editor. |
| `CimaEngine3v Profile CPU`    | `RelWithDebInfo` | Pensada para `Run ▸ Profile`. |
| `CimaEngine3v ASan UBSan`     | `ASan`           | Trae `ASAN_OPTIONS`, `UBSAN_OPTIONS` y `MallocNanoZone=0` ya puestos. |

El *working directory* de las cuatro es `CimaEngine3v/`, para que el
`imgui.ini` (layout del editor) se guarde siempre en el mismo lugar. Los assets
no dependen del working dir: entran por el define `ASSETS` con ruta absoluta.

---

## 3. CPU

### 3.1 Profiler integrado de CLion
1. Selecciona `CimaEngine3v Profile CPU`.
2. `Run ▸ Profile 'CimaEngine3v Profile CPU'` (o el ícono del cronómetro).
3. Juega unos segundos y cierra la ventana.
4. Se abre la ventana **Profiler** con el flame graph, *Call Tree* y *Method List*.

En macOS el profiler de CLion usa **DTrace**, así que te va a pedir la
contraseña de administrador. Con SIP activado (que es tu caso) DTrace sí puede
instrumentar binarios propios como éste; si aun así falla, usa Instruments (3.2)
— da la misma información.

### 3.2 Instruments (Xcode)
Configuración `Instruments CPU Time Profiler`: compila `RelWithDebInfo`, graba
la traza y la abre en Instruments al cerrar el juego.
También está `Instruments Game Performance`, que muestra CPU, GPU y frames
juntos — es la vista más útil para un motor.

Las trazas quedan en `CimaEngine3v/.cache/traces/`.

> **Ojo al medir:** `Render.cpp` hace `setFramerateLimit(65)`. Con ese tope, el
> profiler va a mostrar mucho tiempo dormido y los porcentajes se aplastan. Para
> medir el costo real de un sistema, sube o quita ese límite mientras perfilas.

---

## 4. RAM

macOS/ARM no tiene Valgrind y **LeakSanitizer no existe en Apple Silicon**
(`detect_leaks is not supported on this platform`), así que la detección de
fugas va por las herramientas nativas. Hay cuatro caminos, de más barato a más
completo:

| Configuración                 | Qué te dice | Cuándo usarla |
|-------------------------------|-------------|---------------|
| `RAM monitor en vivo`         | RSS actual y pico, %CPU, barra en tiempo real dentro de la ventana Run | Siempre: arranca el juego y luego esto. Es la respuesta rápida a "¿se está inflando la memoria?". |
| `CimaEngine3v ASan UBSan`     | Use-after-free, doble free, desbordes de heap/stack, UB — con stack trace y línea exacta | Cuando algo truena raro o se corrompen datos. |
| `RAM fugas (leaks)`           | Bloques nunca liberados al salir, agrupados por tipo, con su stack de asignación | Cuando el RSS sube y no baja. |
| `Instruments RAM Allocations` | Timeline de asignaciones: quién pide memoria, cuánta sigue viva, generaciones | Cuando ya sabes que hay fuga y necesitas ver el patrón. |

Notas:
- **No** combines ASan con `leaks`: ASan reemplaza `malloc`, el reporte sale vacío.
- Los errores de ASan aparecen en la ventana **Sanitizers** de CLion, con los
  frames clicables al código.
- `RAM monitor en vivo` se engancha por nombre de proceso, así que primero corre
  el juego con cualquier configuración y luego lanza el monitor.

---

## 5. Herramientas de código ya integradas

| Archivo | Qué hace en CLion |
|---------|-------------------|
| `.clang-format` | Formato del proyecto: llaves Allman, 4 espacios, namespaces indentados, sin reordenar includes. CLion lo detecta solo; `⌥⌘L` formatea con estas reglas. |
| `.clang-tidy` | Análisis estático en vivo (subrayado mientras escribes) con `bugprone-*`, `performance-*` y modernizaciones útiles. Sólo analiza `src/Motor`, `src/Juego` y `src/Main` — nunca ImGui ni SFML. |
| `.editorconfig` | Indentación y encoding consistentes para quien abra el repo en otro editor. |
| `CimaEngine3v.natvis` | Vistas del depurador para los tipos propios: `Vector2D` se ve como `(x, y)` y `Lista<T>` se expande como lista real en lugar de una cadena de `shared_ptr`. Requiere *Settings ▸ Build… ▸ Debugger ▸ Data Views ▸ C/C++ ▸ Enable NatVis renderers*. |
| `compile_commands.json` | El post-build ahora lo copia a la raíz del proyecto desde **cualquier** folder de build (antes estaba clavado a `build/`). Es lo que usa clangd para autocompletado y navegación. |

Extra: `Doxygen documentacion` genera el HTML con el `Doxyfile` existente y lo
abre. Requiere `brew install doxygen graphviz`.

---

## 6. Scripts

Todo lo de profiling vive en `CimaEngine3v/tools/perf/` y funciona igual desde
la terminal que desde el IDE:

```bash
tools/perf/ram-monitor.sh                              # monitor en vivo
tools/perf/leaks-check.sh Debug                        # fugas
tools/perf/instruments.sh "Time Profiler" RelWithDebInfo
tools/perf/instruments.sh "Allocations"  RelWithDebInfo
tools/perf/doxygen.sh
```
