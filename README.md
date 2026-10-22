# funfte-web

Sitio web de la **Quinta Compañía de Bomberos «Bomba Chile» de Talcahuano** (Fünfte Deutsche Feuerwehrkompanie Talcahuano), `funfte.cl`.

Es un sitio **HTML estático**: no usa WordPress, base de datos ni servidor propio. Se edita en local y se publica subiendo los cambios a GitHub.

> No guardes contraseñas en este repositorio ni en este archivo.

---

## Trabajar desde otro PC

### 1. Requisitos
- **Git para Windows** (https://git-scm.com). Incluye **Git Bash** y **Perl**, que es todo lo que usa el sitio. No hace falta Node ni Python.
- Una cuenta de GitHub con permiso de escritura en `funftethno/funfte-web` (pídeselo a un administrador).

### 2. Descargar el proyecto
En Git Bash:

```bash
git clone https://github.com/funftethno/funfte-web.git
```

Git pedirá iniciar sesión en GitHub la primera vez. Usa **tu cuenta personal**, que debe ser miembro de `funftethno`, no la cuenta de la compañía.

### 3. Ver el sitio en local
Desde la carpeta del proyecto, en Git Bash:

```bash
perl herramientas/servidor.pl
```

Abre http://localhost:8080 en el navegador. Para detenerlo, `Ctrl + C`.

### 4. Hacer cambios
Las páginas (`index.html` de cada carpeta) **se generan**. No se editan a mano: los cambios se hacen en estos archivos y luego se regenera.

| Qué cambiar | Archivo |
|---|---|
| Texto de cada página (La Quinta, Historia, Contacto, etc.) | `herramientas/contenido/<página>.html` |
| Menú, cabecera, pie, portada, páginas Formación y Acceso Quintino, accesos y enlaces | `herramientas/plantilla.pm` |
| Colores, tipografía y diseño | `assets/css/estilos.css` |
| Menú en celular | `assets/js/menu.js` |
| Imágenes | `assets/img/` |

Para regenerar todas las páginas:

```bash
perl herramientas/generar.pl
```

Para retirar una página del sitio sin perderla, en `herramientas/plantilla.pm` cámbiale la ruta a `archivo/<nombre>/` y la sección a `Archivo`, quítala del menú y corrige las rutas relativas de su archivo en `herramientas/contenido/` (un `../` más). Aparece sola en la página Archivo. Borra la carpeta antigua antes de regenerar.

El contenido se extrajo una sola vez del sitio antiguo (WordPress), ya limpio y sin Noticias. El sitio no depende de funfte.cl antiguo ni guarda copia de él.

### 5. Publicar: flujo de trabajo

| Rama | Quién sube | Dónde se ve |
|---|---|---|
| `desarrollo` | Cualquier colaborador, directamente | Vista previa: `https://desarrollo-funfte-web.funfteit.workers.dev` |
| `master` | Nadie directamente: solo por Pull Request aprobado | Sitio oficial `https://funfte.cl` |

1. Trabaja en la rama `desarrollo`:

   ```bash
   git checkout desarrollo
   git pull
   ```

2. Haz el cambio, regenera y revisa:

   ```bash
   perl herramientas/generar.pl
   perl herramientas/revisar.pl
   ```

   `revisar.pl` avisa si quedaron páginas sin regenerar o enlaces internos rotos.

3. Sube a `desarrollo`. En uno o dos minutos se ve en la vista previa:

   ```bash
   git add -A
   git commit -m "Describe el cambio"
   git push
   ```

4. Cuando esté listo para publicarse, abre un **Pull Request** de `desarrollo` hacia `master` en GitHub. GitHub ejecuta la misma revisión automáticamente; si pasa y un administrador lo aprueba, se acepta y el cambio queda en `funfte.cl` en uno o dos minutos.

Si trabajas en paralelo con otra persona, puedes crear tu propia rama (`git checkout -b mi-cambio`); también tendrá su vista previa en `https://mi-cambio-funfte-web.funfteit.workers.dev`.

### Usarlo con asistentes de IA
Las reglas para asistentes de IA (Codex, Cursor, Copilot, Gemini, Claude Code, etc.) están en `AGENTS.md`. Si tu asistente no lo lee solo, pídele que lo lea antes de empezar. Si cambian las convenciones del sitio, actualiza `AGENTS.md`.

---

## Estructura

```
index.html                 Portada
la-quinta/ historia/ cuartel/ confederacion/
dotacion/                  Oficialidad y Voluntarios
formacion/
material-mayor/ (b-5/, bx-5/, harbor-28/)
archivo/                   Páginas retiradas (Nuestro Trabajo, Capacitación, Guardia Nocturna, Redes Sociales, Directorio, Socios Colaboradores); enlace «Archivo» en el pie
contacto/
acceso-quintino/           Ingreso a la intranet (placeholder) y accesos internos
assets/css, assets/js, assets/img
herramientas/              Generador (Perl), contenido de las páginas, revisor y servidor local
.github/workflows/         Revisión automática de cada Pull Request
wrangler.jsonc             Configuración de Cloudflare (qué se publica)
.assetsignore              Archivos del repositorio que no se publican
```

---

## Pendientes

- La nómina de Dotación es la lista de compañía de abril de 2026; actualizarla en `herramientas/contenido/dotacion.html` cuando cambie.
- Confederación: falta la compañía de Iquique y las fechas de fundación de Paillaco y Los Bajos.
- Optimizar imágenes (`assets/img` pesa unos 17 MB).
- Biblioteca Virtual e intranet: hoy son solo placeholders.
