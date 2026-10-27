// Calendario de actividades (Acceso Quintino): pensado para dejarlo en pantalla completa
// en un televisor del cuartel. Muestra las actividades de hoy y las proximas, y se
// actualiza solo. Tambien se puede ver como lista de los proximos doce meses y filtrar por
// categoria; los filtros y la vista quedan en la direccion (?filtros=quinta,cbt&vista=lista).
// Para probar otro dia: ?fecha=MM-DD (por ejemplo ?fecha=11-08).
document.addEventListener('DOMContentLoaded', function () {
  var datos = document.getElementById('actividades');
  var pantalla = document.getElementById('pantalla');
  var zonaLista = document.getElementById('calendario-lista');
  if (!datos || !pantalla || !zonaLista) return;

  var MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
               'septiembre', 'octubre', 'noviembre', 'diciembre'];
  var DIAS = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
  var CATEGORIAS = { quinta: 'Quinta', cbt: 'CBT', confederacion: 'Confederación', otros: 'Otros' };
  var PROXIMOS = 8;   // en pantalla completa, si no caben todas, se muestran las que caben (ver ajustar)
  var todas = JSON.parse(datos.textContent);
  var parametros = new URLSearchParams(location.search);
  var prueba = /^(\d{2})-(\d{2})$/.exec(parametros.get('fecha') || '');

  // filtros y vista: de la direccion, o todas las categorias en pantalla
  var activas = (parametros.get('filtros') || '').split(',').filter(function (c) { return CATEGORIAS[c]; });
  if (!activas.length) activas = Object.keys(CATEGORIAS);
  var vista = parametros.get('vista') === 'lista' ? 'lista' : 'pantalla';

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

  // fecha de la actividad en un año: dia fijo, o el ultimo <dia de la semana> del mes; con
  // «domingo», corrida al domingo siguiente si no cae en domingo
  function fechaEn(c, anio) {
    var f;
    if (c.ultimo == null) {
      f = new Date(anio, c.mes - 1, c.dia);
    } else {
      f = new Date(anio, c.mes, 0);
      f.setDate(f.getDate() - (f.getDay() - c.ultimo + 7) % 7);
    }
    if (c.domingo) f.setDate(f.getDate() + (7 - f.getDay()) % 7);
    return f;
  }

  // proxima fecha de cada actividad a partir de hoy (hoy incluido), solo las categorias activas
  function calcular(ahora) {
    var dia = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate());
    return todas.filter(function (c) { return activas.indexOf(c.categoria) >= 0; }).map(function (c) {
      var fecha = fechaEn(c, dia.getFullYear());
      if (fecha < dia) fecha = fechaEn(c, dia.getFullYear() + 1);
      return { c: c, fecha: fecha, faltan: Math.round((fecha - dia) / 86400000),
               anios: c.anio ? fecha.getFullYear() - c.anio : null };
    }).sort(function (a, b) { return a.faltan - b.faltan || nombre(a.c).localeCompare(nombre(b.c), 'es'); });
  }

  function cuando(a) {
    return a.faltan === 0 ? 'hoy' : a.faltan === 1 ? 'mañana' : 'en ' + a.faltan + ' días';
  }

  function detalle(a) {
    return [a.anios != null ? a.anios + ' años' : '', cuando(a), a.c.nota || ''].filter(Boolean).join(' · ');
  }

  function dibujarPantalla(todos) {
    var deHoy = todos.filter(function (a) { return a.faltan === 0; });
    var siguientes = todos.filter(function (a) { return a.faltan > 0; });

    // Hoy: las actividades del dia; si no hay, la proxima en grande
    var zonaHoy = document.getElementById('pantalla-hoy');
    zonaHoy.textContent = '';
    var destacados = deHoy.length ? deHoy : siguientes.slice(0, 1);
    var soloAniversarios = deHoy.every(function (a) { return a.anios != null; });
    zonaHoy.appendChild(elemento('p', 'pantalla-etiqueta',
      deHoy.length ? (soloAniversarios ? '¡Feliz aniversario!' : 'Hoy') : 'Próxima actividad'));
    destacados.forEach(function (a) {
      var tarjeta = elemento('div', 'pantalla-destacado');
      tarjeta.appendChild(escudo(a.c, 'pantalla-escudo'));
      var texto = elemento('div');
      texto.appendChild(elemento('p', 'pantalla-nombre', nombre(a.c)));
      if (a.anios != null) texto.appendChild(elemento('p', 'pantalla-anios', a.anios + ' años'));
      if (!deHoy.length) texto.appendChild(elemento('p', 'pantalla-cuando',
        [a.fecha.getDate() + ' de ' + MESES[a.fecha.getMonth()], cuando(a), a.c.nota || ''].filter(Boolean).join(' · ')));
      tarjeta.appendChild(texto);
      zonaHoy.appendChild(tarjeta);
    });
    if (!destacados.length) zonaHoy.appendChild(elemento('p', 'pantalla-cuando', 'No hay actividades en las categorías elegidas.'));
    if (!deHoy.length) siguientes = siguientes.slice(1);

    var ol = document.getElementById('pantalla-proximos');
    ol.textContent = '';
    siguientes.slice(0, PROXIMOS).forEach(function (a) {
      var li = elemento('li');
      var fecha = elemento('span', 'pantalla-dia');
      fecha.appendChild(elemento('strong', '', String(a.fecha.getDate())));
      fecha.appendChild(elemento('span', '', MESES[a.fecha.getMonth()].slice(0, 3)));
      li.appendChild(fecha);
      li.appendChild(escudo(a.c, 'pantalla-mini'));
      var texto = elemento('div');
      texto.appendChild(elemento('p', 'pantalla-mini-nombre', nombre(a.c)));
      texto.appendChild(elemento('p', 'pantalla-mini-detalle', detalle(a)));
      li.appendChild(texto);
      ol.appendChild(li);
    });
    ajustar();
  }

  // En pantalla completa, quita del final las proximas que no caben en el televisor
  function ajustar() {
    if (document.fullscreenElement !== pantalla) return;
    var ol = document.getElementById('pantalla-proximos');
    var limite = pantalla.getBoundingClientRect().bottom - parseFloat(getComputedStyle(pantalla).paddingBottom);
    while (ol.lastChild && ol.lastChild.getBoundingClientRect().bottom > limite) ol.removeChild(ol.lastChild);
  }

  // Lista: los proximos doce meses, agrupados por mes
  function dibujarLista(todos) {
    zonaLista.textContent = '';
    if (!todos.length) {
      zonaLista.appendChild(elemento('p', '', 'No hay actividades en las categorías elegidas.'));
      return;
    }
    var mesActual = '', ol;
    todos.forEach(function (a) {
      var mes = MESES[a.fecha.getMonth()] + ' de ' + a.fecha.getFullYear();
      if (mes !== mesActual) {
        mesActual = mes;
        zonaLista.appendChild(elemento('h2', 'calendario-mes', mes));
        ol = zonaLista.appendChild(elemento('ol'));
      }
      var li = elemento('li', a.faltan === 0 ? 'hoy' : '');
      var fecha = elemento('span', 'calendario-dia');
      fecha.appendChild(elemento('strong', '', String(a.fecha.getDate())));
      fecha.appendChild(elemento('span', '', DIAS[a.fecha.getDay()].slice(0, 3)));
      li.appendChild(fecha);
      li.appendChild(escudo(a.c, 'calendario-escudo'));
      var texto = elemento('div');
      texto.appendChild(elemento('p', 'calendario-nombre', nombre(a.c)));
      var info = elemento('p', 'calendario-detalle');
      info.appendChild(elemento('span', 'calendario-categoria', CATEGORIAS[a.c.categoria]));
      info.appendChild(document.createTextNode(' ' + detalle(a)));
      texto.appendChild(info);
      li.appendChild(texto);
      ol.appendChild(li);
    });
  }

  var ultimoDia = '';
  function dibujar(forzar) {
    var ahora = hoy();
    var hh = String(ahora.getHours()).padStart(2, '0') + ':' + String(ahora.getMinutes()).padStart(2, '0');
    document.getElementById('pantalla-hora').textContent = hh;
    var clave = ahora.toDateString();
    if (clave === ultimoDia && !forzar) return;   // el resto solo cambia cuando cambia el dia
    ultimoDia = clave;

    document.getElementById('pantalla-fecha').textContent =
      DIAS[ahora.getDay()] + ' ' + ahora.getDate() + ' de ' + MESES[ahora.getMonth()] + ' de ' + ahora.getFullYear();
    var todos = calcular(ahora);
    dibujarPantalla(todos);
    dibujarLista(todos);
  }

  // Botones de filtros y vista; el estado queda en la direccion para poder guardarla
  var botones = document.querySelectorAll('[data-categoria], [data-vista]');
  var completa = document.getElementById('pantalla-completa');
  function aplicar() {
    Array.prototype.forEach.call(botones, function (b) {
      b.setAttribute('aria-pressed', b.dataset.categoria ? activas.indexOf(b.dataset.categoria) >= 0 : b.dataset.vista === vista);
    });
    pantalla.hidden = vista !== 'pantalla';
    zonaLista.hidden = vista !== 'lista';
    if (completa) completa.hidden = vista !== 'pantalla' || !pantalla.requestFullscreen;
    var p = new URLSearchParams(location.search);
    if (activas.length === Object.keys(CATEGORIAS).length) p.delete('filtros'); else p.set('filtros', activas.join(','));
    if (vista === 'pantalla') p.delete('vista'); else p.set('vista', vista);
    var q = p.toString();
    history.replaceState(null, '', location.pathname + (q ? '?' + q : '') + location.hash);
    dibujar(true);
  }
  Array.prototype.forEach.call(botones, function (b) {
    b.addEventListener('click', function () {
      if (b.dataset.vista) {
        vista = b.dataset.vista;
      } else {
        var i = activas.indexOf(b.dataset.categoria);
        if (i < 0) activas.push(b.dataset.categoria);
        else if (activas.length > 1) activas.splice(i, 1);   // siempre queda al menos una
        activas = Object.keys(CATEGORIAS).filter(function (c) { return activas.indexOf(c) >= 0; });
      }
      aplicar();
    });
  });

  aplicar();
  setInterval(dibujar, 20000);

  // al entrar o salir de pantalla completa cambia el espacio: se vuelve a armar
  document.addEventListener('fullscreenchange', function () { dibujar(true); });

  if (completa && pantalla.requestFullscreen) {
    completa.addEventListener('click', function () {
      pantalla.requestFullscreen();
      // que el televisor o el computador no apaguen la pantalla mientras se muestra
      if (navigator.wakeLock) navigator.wakeLock.request('screen').catch(function () {});
    });
  }
});
