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
| Menú, cabecera, pie, portada, página Acceso Quintino, accesos y enlaces | `herramientas/plantilla.pm` |
| Colores, tipografía y diseño | `assets/css/estilos.css` |
| Menú en celular | `assets/js/menu.js` |
| Imágenes (máximo 1600 px de ancho, con texto `alt`) | `assets/img/` |
| Descripción de cada página para Google y redes sociales | `%DESCRIPCIONES` en `herramientas/plantilla.pm` |
| Datos de la compañía para Google (dirección, coordenadas, correo, redes, fundación) | constantes al inicio de `herramientas/plantilla.pm` |

Para regenerar todas las páginas:

```bash
perl herramientas/generar.pl
```

Para retirar una página del sitio sin perderla, en `herramientas/plantilla.pm` cámbiale la ruta a `archivo/<nombre>/` y la sección a `Archivo`, quítala del menú y corrige las rutas relativas de su archivo en `herramientas/contenido/` (un `../` más). Aparece sola en la página Archivo. Borra la carpeta antigua antes de regenerar.

El contenido se extrajo una sola vez del sitio antiguo (WordPress), ya limpio y sin Noticias. El sitio no depende de funfte.cl antiguo ni guarda copia de él.

### 5. Publicar: flujo de trabajo

| Rama | Quién sube | Dónde se ve |
|---|---|---|
| Tu rama personal (tu apellido en minúsculas) | Tú | `https://<rama>-funfte-web.funfteit.workers.dev/` |
| `master` | Solo el owner, juntando las ramas ya probadas | Sitio oficial `https://funfte.cl` |

1. **Siempre antes de empezar: ponte en tu rama personal y actualízala** con lo último de `master`. No te saltes este paso aunque el cambio sea pequeño: otros suben cambios a diario. Cada colaborador tiene una rama con su apellido en minúsculas, creada por el owner (por ejemplo `delgado`):

   ```bash
   git fetch origin
   git checkout delgado
   git pull
   git merge origin/master
   perl herramientas/generar.pl
   ```

2. **Haz el cambio, regenera y revisa:**

   ```bash
   perl herramientas/generar.pl
   perl herramientas/revisar.pl
   ```

   `revisar.pl` avisa si quedaron páginas sin regenerar o enlaces internos rotos. Con `perl herramientas/revisar.pl --externos` también prueba los enlaces a otros sitios (tarda un par de minutos); GitHub lo hace solo el día 1 de cada mes y abre un issue si alguno está caído.

3. **Sube tu rama y pruébala** en su vista previa, que se actualiza en uno o dos minutos (en el ejemplo, `https://delgado-funfte-web.funfteit.workers.dev/`). GitHub también corre la revisión automática; mira que salga ✅.

   ```bash
   git add -A
   git commit -m "Describe el cambio"
   git push -u origin delgado
   ```

4. **Cuando esté probada, avisa al owner** (o abre un Pull Request de tu rama hacia `master`). El owner la junta con `master` y queda en `funfte.cl` en uno o dos minutos.

   Si al actualizar tu rama `git merge` avisa de conflictos en páginas `index.html`, no los resuelvas a mano: quédate con cualquiera de las dos versiones, ejecuta `perl herramientas/generar.pl` y termina el merge.

No hagas push directo ni force push a `master`.

### Usarlo con asistentes de IA
Las reglas para asistentes de IA (Codex, Cursor, Copilot, Gemini, Claude Code, etc.) están en `AGENTS.md`. Si tu asistente no lo lee solo, pídele que lo lea antes de empezar. Si cambian las convenciones del sitio, actualiza `AGENTS.md`.

---

## Estructura

```
index.html                 Portada
la-quinta/ historia/ cuartel/ confederacion/
dotacion/                  Oficialidad y Voluntarios
material-mayor/ (b-5/, bx-5/, harbor-28/)
archivo/                   Páginas en desarrollo (Dotación con fotos) y retiradas (Historia anterior, Nuestro Trabajo, Capacitación, Guardia Nocturna, Redes Sociales, Directorio, Socios Colaboradores); enlace «Archivo» en el pie
contacto/
acceso-quintino/           Ingreso a la intranet (placeholder) y accesos internos
assets/css, assets/js, assets/img
herramientas/              Generador (Perl), contenido de las páginas, revisor y servidor local
.github/workflows/         Revisión automática de cada Pull Request
wrangler.jsonc             Configuración de Cloudflare (qué se publica)
_headers / _redirects       Cabeceras de caché y seguridad / redirecciones del sitio antiguo
404.html robots.txt sitemap.xml   Generados por herramientas/generar.pl
.assetsignore              Archivos del repositorio que no se publican
```

---

## Pendientes

- La nómina de Dotación es la lista de compañía de abril de 2026; actualizarla en `herramientas/contenido/dotacion.html` cuando cambie.
- Confederación: falta la compañía de Iquique y las fechas de fundación de Paillaco y Los Bajos.
- Optimizar imágenes (`assets/img` pesa unos 17 MB).
- Biblioteca Virtual e intranet: hoy son solo placeholders.
