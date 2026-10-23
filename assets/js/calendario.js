// Calendario de aniversarios (Acceso Quintino): pensado para dejarlo en pantalla completa
// en un televisor del cuartel. Muestra los aniversarios de hoy y los proximos, y se
// actualiza solo. Para probar otro dia: ?fecha=MM-DD (por ejemplo ?fecha=11-08).
document.addEventListener('DOMContentLoaded', function () {
  var datos = document.getElementById('aniversarios');
  var pantalla = document.getElementById('pantalla');
  if (!datos || !pantalla) return;

  var MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
               'septiembre', 'octubre', 'noviembre', 'diciembre'];
  var DIAS = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
  var PROXIMOS = 8;
  var lista = JSON.parse(datos.textContent);
  var prueba = /[?&]fecha=(\d{2})-(\d{2})/.exec(location.search);

  function hoy() {
    var d = new Date();
    if (prueba) d = new Date(d.getFullYear(), +prueba[1] - 1, +prueba[2], d.getHours(), d.getMinutes());
    return d;
  }

  function nombre(c) {
    return c.propia ? 'Quinta Compañía «Bomba Chile» de Talcahuano' : c.nombre;
  }

  function elemento(etiqueta, clase, texto) {
    var e = document.createElement(etiqueta);
    if (clase) e.className = clase;
    if (texto) e.textContent = texto;
    return e;
  }

  function escudo(c, clase) {
    if (!c.escudo) return elemento('span', clase + ' sin-escudo', nombre(c).replace(/ª.*/, ''));
    var img = elemento('img', clase);
    img.src = c.escudo;
    img.alt = '';
    return img;
  }

  // proximo aniversario de cada compania a partir de hoy (hoy incluido)
  function calcular(ahora) {
    var dia = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate());
    return lista.map(function (c) {
      var fecha = new Date(dia.getFullYear(), c.mes - 1, c.dia);
      if (fecha < dia) fecha.setFullYear(fecha.getFullYear() + 1);
      return { c: c, fecha: fecha, faltan: Math.round((fecha - dia) / 86400000), anios: fecha.getFullYear() - c.anio };
    }).sort(function (a, b) { return a.faltan - b.faltan; });
  }

  function cuando(a) {
    return a.faltan === 0 ? 'hoy' : a.faltan === 1 ? 'mañana' : 'en ' + a.faltan + ' días';
  }

  var ultimoDia = '';
  function dibujar() {
    var ahora = hoy();
    var hh = String(ahora.getHours()).padStart(2, '0') + ':' + String(ahora.getMinutes()).padStart(2, '0');
    document.getElementById('pantalla-hora').textContent = hh;
    var clave = ahora.toDateString();
    if (clave === ultimoDia) return;   // el resto solo cambia cuando cambia el dia
    ultimoDia = clave;

    document.getElementById('pantalla-fecha').textContent =
      DIAS[ahora.getDay()] + ' ' + ahora.getDate() + ' de ' + MESES[ahora.getMonth()] + ' de ' + ahora.getFullYear();

    var todos = calcular(ahora);
    var deHoy = todos.filter(function (a) { return a.faltan === 0; });
    var siguientes = todos.filter(function (a) { return a.faltan > 0; });

    // Hoy: los que estan de aniversario; si no hay, el proximo en grande
    var zonaHoy = document.getElementById('pantalla-hoy');
    zonaHoy.textContent = '';
    var destacados = deHoy.length ? deHoy : siguientes.slice(0, 1);
    zonaHoy.appendChild(elemento('p', 'pantalla-etiqueta', deHoy.length ? '¡Feliz aniversario!' : 'Próximo aniversario'));
    destacados.forEach(function (a) {
      var tarjeta = elemento('div', 'pantalla-destacado');
      tarjeta.appendChild(escudo(a.c, 'pantalla-escudo'));
      var texto = elemento('div');
      texto.appendChild(elemento('p', 'pantalla-nombre', nombre(a.c)));
      texto.appendChild(elemento('p', 'pantalla-anios', a.anios + ' años'));
      if (!deHoy.length) texto.appendChild(elemento('p', 'pantalla-cuando',
        a.c.dia + ' de ' + MESES[a.c.mes - 1] + ' · ' + cuando(a)));
      tarjeta.appendChild(texto);
      zonaHoy.appendChild(tarjeta);
    });
    if (!deHoy.length) siguientes = siguientes.slice(1);

    var ol = document.getElementById('pantalla-proximos');
    ol.textContent = '';
    siguientes.slice(0, PROXIMOS).forEach(function (a) {
      var li = elemento('li');
      var fecha = elemento('span', 'pantalla-dia');
      fecha.appendChild(elemento('strong', '', String(a.c.dia)));
      fecha.appendChild(elemento('span', '', MESES[a.c.mes - 1].slice(0, 3)));
      li.appendChild(fecha);
      li.appendChild(escudo(a.c, 'pantalla-mini'));
      var texto = elemento('div');
      texto.appendChild(elemento('p', 'pantalla-mini-nombre', nombre(a.c)));
      texto.appendChild(elemento('p', 'pantalla-mini-detalle', a.anios + ' años · ' + cuando(a)));
      li.appendChild(texto);
      ol.appendChild(li);
    });
  }

  dibujar();
  setInterval(dibujar, 20000);

  var boton = document.getElementById('pantalla-completa');
  if (boton && pantalla.requestFullscreen) {
    boton.addEventListener('click', function () {
      pantalla.requestFullscreen();
      // que el televisor o el computador no apaguen la pantalla mientras se muestra
      if (navigator.wakeLock) navigator.wakeLock.request('screen').catch(function () {});
    });
  } else if (boton) {
    boton.hidden = true;
  }
});
