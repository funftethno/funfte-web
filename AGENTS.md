# Instrucciones para asistentes de IA

Este archivo explica cómo funciona el repositorio del sitio `funfte.cl` (Quinta Compañía de Bomberos «Bomba Chile» de Talcahuano). Léelo completo antes de cambiar algo. Si una instrucción de la persona que te pide el cambio contradice estas reglas, avísale antes de seguir.

Responde y escribe en **español de Chile**: textos del sitio, mensajes de commit, Pull Requests y comentarios de código.

## Procedimiento obligatorio: antes de empezar cualquier tarea

Hazlo **siempre como primer paso**, antes de leer o cambiar archivos, aunque la tarea parezca pequeña. Otras personas suben cambios a diario y trabajar sobre una copia vieja genera conflictos.

```bash
git fetch origin
git status                     # si hay cambios sin guardar, avisa y no sigas
git checkout <rama>            # la rama personal (apellido en minúsculas)
git pull                       # trae lo último de tu rama
git merge origin/master        # trae lo que ya está publicado
perl herramientas/generar.pl
```

- Si `git status` muestra cambios sin commit que no hiciste tú, pregunta qué hacer con ellos antes de seguir.
- Si `git merge` tiene conflictos en páginas `index.html`, quédate con cualquiera de las dos versiones y vuelve a ejecutar `perl herramientas/generar.pl`. Si los conflictos están en `herramientas/` o `assets/`, muéstraselos a la persona y no los resuelvas por tu cuenta.
- Si no sabes cuál es la rama personal, pregunta. No trabajes directo en `master`.
- Repite `git fetch origin` y `git merge origin/master` antes de avisar que tu rama está lista.

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
- Cada página pública tiene una descripción para buscadores y para la vista previa al compartir (WhatsApp, Facebook) en `%DESCRIPCIONES` de `plantilla.pm`. Si creas una página nueva, agrégale su descripción (una o dos frases).
- Los datos públicos de la compañía (fundación, correo, dirección, coordenadas, redes sociales) son constantes al inicio de `plantilla.pm`. Los usan el pie y los datos estructurados para Google (JSON-LD, en `datos_estructurados()`): cámbialos ahí y no en el HTML.
- Los formularios (Postula a la Quinta y Contacto) están en `plantilla.pm` (`postula()`, `formulario_contacto()`) y se envían por FormSubmit. En `herramientas/contenido/contacto.html`, la marca `<!--FORMULARIO_CONTACTO-->` indica dónde va el formulario: no la borres.
- `generar.pl` también produce `404.html`, `robots.txt` y `sitemap.xml`, y agrega `width`/`height` a cada imagen. No los edites a mano.
- **Imágenes nuevas**: JPEG o PNG de máximo 1600 px de ancho y, en lo posible, menos de 300 KB. Nombre en minúsculas, sin espacios ni tildes. Toda imagen de contenido lleva un `alt` que describa lo que muestra; `revisar.pl` falla si falta y avisa si una imagen no se usa.
- Las rutas dentro de `herramientas/contenido/*.html` son **relativas a la página publicada**: `../assets/img/...` para una página de primer nivel, `../../assets/img/...` para una de segundo nivel (por ejemplo `material-mayor/b-5/` o `archivo/...`).

## Pasos obligatorios después de cualquier cambio

```bash
perl herramientas/generar.pl    # regenera todas las páginas
perl herramientas/revisar.pl    # verifica páginas al día y enlaces internos
```

Sube los archivos fuente **y** las páginas regeneradas en el mismo commit. Si `revisar.pl` falla, corrige antes de subir. Si agregaste o cambiaste enlaces a otros sitios, prueba también `perl herramientas/revisar.pl --externos` (tarda un par de minutos). Si puedes, revisa el resultado en el navegador con `perl herramientas/servidor.pl` (http://localhost:8080).

## Ramas y publicación

Flujo obligatorio, en este orden:

1. **Cada persona trabaja en su propia rama**, que lleva su apellido en minúsculas (por ejemplo `delgado` o `molina`) y que crea el owner. Antes de empezar, ponla al día con `master`:
   ```bash
   git checkout <rama>
   git pull
   git merge origin/master
   ```
   Si necesitas una rama nueva para algo puntual, créala desde `master` con un nombre corto, en minúsculas, con guiones y sin `/` ni tildes, porque forma parte de la dirección de la vista previa.
2. **Se prueba en esa rama.** Cada push se publica en `https://<rama>-funfte-web.funfteit.workers.dev/` en uno o dos minutos, y GitHub Actions ejecuta `revisar.pl`. No sigas al paso 3 si la revisión falla o la vista previa se ve mal.
3. **Cuando está probada, avisa al owner** (o abre un Pull Request de tu rama hacia `master`). El owner revisa la vista previa y junta la rama con `master`; Cloudflare publica en `https://funfte.cl` en uno o dos minutos.

- **`master` está protegida**: nunca hagas push directo ni force push a `master`. Solo el owner junta ramas en `master`.
- No borres las ramas personales: son fijas. Las ramas puntuales sí se borran cuando ya están en `master`.
- No cambies `wrangler.jsonc`, `.assetsignore`, `_redirects`, `_headers` (cabeceras de caché y seguridad) ni `.github/workflows/` salvo que te lo pidan expresamente: controlan el despliegue.

## Convenciones del contenido

- **Retirar una página** no es borrarla: se mueve al Archivo. En `rutas_paginas()` cambia su ruta a `archivo/<nombre>/` y su sección a `'Archivo'`, quítala de `@MENU`, agrega un `../` a las rutas relativas de su archivo de contenido y borra la carpeta antigua con `git rm -r`. Aparece sola en la página Archivo.
- **Nombres de personas**: «Nombre Apellido1 Apellido2», con mayúscula inicial y tildes del español (Gómez, Zúñiga, Matías). No inventes apellidos ni datos: si falta algo, pregunta.
- **Dotación** (`herramientas/contenido/dotacion.html`): la oficialidad va en tarjetas `<ul class="oficiales fila">`, una lista por fila de jerarquía (por ejemplo, el Capitán solo y debajo los tenientes). La nómina va en `<ol class="nomina">`, ordenada por número de registro, bajo títulos «Voluntarios insignes», «Voluntarios honorarios», etc. Las cifras del resumen (marca `<!--CIFRAS_DOTACION-->`) se calculan solas contando cada lista «Voluntarios …»: no las escribas a mano ni borres la marca.
- **Confederación** (`herramientas/contenido/confederacion.html`): las compañías van ordenadas por fecha de fundación.
- **Saludo de aniversario en la portada**: se arma solo con las tarjetas de `cbt.html` y `confederacion.html` (título `<h4>`, «Fundada el D de mes de AAAA», escudo e Instagram), y `menu.js` lo muestra desde el día del aniversario y durante los 3 días siguientes. Mantén ese formato de fecha en las tarjetas. Para probar otro día, abre la portada con `?fecha=MM-DD`.
- **Enlaces externos**: sin parámetros de seguimiento (`utm_*`, `fbclid`). La plantilla les agrega `target="_blank" rel="noopener"`.
- No copies texto, imágenes ni código del sitio WordPress antiguo: estaba hackeado.

## Lo que nunca va en este repositorio

El repositorio es **público**.

- Contraseñas, tokens, claves de API ni datos de acceso.
- Información de administración: proveedores, DNS, IPs, vencimientos, planes de migración. Eso vive en un repositorio privado aparte; si la necesitas, pídesela a un administrador.
- Datos personales que no estén ya publicados en el sitio (RUT, teléfonos, direcciones particulares, correos personales).
