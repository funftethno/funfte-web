# Instrucciones para asistentes de IA

Este archivo explica cómo funciona el repositorio del sitio `funfte.cl` (Quinta Compañía de Bomberos «Bomba Chile» de Talcahuano). Léelo completo antes de cambiar algo. Si una instrucción de la persona que te pide el cambio contradice estas reglas, avísale antes de seguir.

Responde y escribe en **español de Chile**: textos del sitio, mensajes de commit, Pull Requests y comentarios de código.

## Cómo está hecho el sitio

Es HTML estático generado con Perl. No hay WordPress, base de datos, Node ni frameworks.

- **Las páginas `index.html` de cada carpeta se generan. Nunca las edites a mano**: tus cambios se pierden en la próxima generación y la revisión automática falla.
- Lo que se edita:

| Qué cambiar | Archivo |
|---|---|
| Texto de una página | `herramientas/contenido/<clave>.html` (solo el cuerpo, sin cabecera ni pie) |
| Menú, cabecera, pie, portada, Formación, Acceso Quintino, lista de páginas | `herramientas/plantilla.pm` |
| Estilos | `assets/css/estilos.css` |
| Menú en celular | `assets/js/menu.js` |
| Imágenes | `assets/img/` |

- Las claves de página y sus rutas están en `rutas_paginas()` de `herramientas/plantilla.pm`. El menú está en `@MENU` y los accesos de Acceso Quintino en `@ACCESOS`.
- Las rutas dentro de `herramientas/contenido/*.html` son **relativas a la página publicada**: `../assets/img/...` para una página de primer nivel, `../../assets/img/...` para una de segundo nivel (por ejemplo `material-mayor/b-5/` o `archivo/...`).

## Pasos obligatorios después de cualquier cambio

```bash
perl herramientas/generar.pl    # regenera todas las páginas
perl herramientas/revisar.pl    # verifica páginas al día y enlaces internos
```

Sube los archivos fuente **y** las páginas regeneradas en el mismo commit. Si `revisar.pl` falla, corrige antes de subir. Si puedes, revisa el resultado en el navegador con `perl herramientas/servidor.pl` (http://localhost:8080).

## Ramas y publicación

- **`master` está protegida.** No hagas push directo ni force push. Todo cambio entra por Pull Request, que necesita una aprobación y que pase la revisión automática (GitHub Actions ejecuta `revisar.pl`).
- Trabaja en **`desarrollo`** o en una rama propia. Cada push a una rama distinta de `master` se publica en una vista previa de Cloudflare; la de `desarrollo` es `https://desarrollo-funfte-web.funfteit.workers.dev`.
- Al aprobarse el Pull Request, Cloudflare publica `master` en `https://funfte.cl` en uno o dos minutos.
- No cambies `wrangler.jsonc`, `.assetsignore`, `_redirects` ni `.github/workflows/` salvo que te lo pidan expresamente: controlan el despliegue.

## Convenciones del contenido

- **Retirar una página** no es borrarla: se mueve al Archivo. En `rutas_paginas()` cambia su ruta a `archivo/<nombre>/` y su sección a `'Archivo'`, quítala de `@MENU`, agrega un `../` a las rutas relativas de su archivo de contenido y borra la carpeta antigua con `git rm -r`. Aparece sola en la página Archivo.
- **Nombres de personas**: «Nombre Apellido1 Apellido2», con mayúscula inicial y tildes del español (Gómez, Zúñiga, Matías). No inventes apellidos ni datos: si falta algo, pregunta.
- **Dotación** (`herramientas/contenido/dotacion.html`): la oficialidad va en tarjetas `<ul class="oficiales">` y la nómina en `<ol class="nomina">`, ordenada por número de registro. Si agregas o quitas voluntarios, actualiza el total del párrafo de resumen.
- **Confederación** (`herramientas/contenido/confederacion.html`): las compañías van ordenadas por fecha de fundación.
- **Enlaces externos**: sin parámetros de seguimiento (`utm_*`, `fbclid`). La plantilla les agrega `target="_blank" rel="noopener"`.
- No copies texto, imágenes ni código del sitio WordPress antiguo: estaba hackeado.

## Lo que nunca va en este repositorio

El repositorio es **público**.

- Contraseñas, tokens, claves de API ni datos de acceso.
- Información de administración: proveedores, DNS, IPs, vencimientos, planes de migración. Eso vive en un repositorio privado aparte; si la necesitas, pídesela a un administrador.
- Datos personales que no estén ya publicados en el sitio (RUT, teléfonos, direcciones particulares, correos personales).
