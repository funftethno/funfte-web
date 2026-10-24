// Menu principal: boton para celulares y submenus desplegables.
document.addEventListener('DOMContentLoaded', function () {
  var botonMenu = document.querySelector('.abrir-menu');
  var menu = document.getElementById('menu-principal');

  botonMenu.addEventListener('click', function () {
    var abierto = botonMenu.getAttribute('aria-expanded') === 'true';
    botonMenu.setAttribute('aria-expanded', String(!abierto));
    menu.classList.toggle('abierto', !abierto);
  });

  // Telefonos de los formularios: solo digitos, maximo 9, agrupados como 9 1234 5678
  document.querySelectorAll('[data-telefono]').forEach(function (campo) {
    campo.addEventListener('input', function () {
      var d = campo.value.replace(/\D/g, '');
      if (d.length > 9 && d.indexOf('56') === 0) d = d.slice(2);  // pegado con +56
      d = d.slice(0, 9);
      var formato = [d.slice(0, 1), d.slice(1, 5), d.slice(5)].filter(Boolean).join(' ');
      if (formato !== campo.value) campo.value = formato;
    });
  });

  // RUT: agrega puntos y guion (12.345.678-9) y revisa el digito verificador (modulo 11)
  function digitoVerificador(cuerpo) {
    var suma = 0, factor = 2;
    for (var i = cuerpo.length - 1; i >= 0; i--) {
      suma += Number(cuerpo[i]) * factor;
      factor = factor === 7 ? 2 : factor + 1;
    }
    var dv = 11 - (suma % 11);
    return dv === 11 ? '0' : dv === 10 ? 'K' : String(dv);
  }
  document.querySelectorAll('[data-rut]').forEach(function (campo) {
    campo.addEventListener('input', function () {
      var limpio = campo.value.toUpperCase().replace(/[^0-9K]/g, '');
      // la K solo puede ser el digito verificador (el ultimo caracter)
      limpio = limpio.slice(0, -1).replace(/K/g, '') + limpio.slice(-1);
      limpio = limpio.slice(0, 9);
      var formato = limpio;
      if (limpio.length > 1) {
        var cuerpo = limpio.slice(0, -1);
        formato = cuerpo.replace(/\B(?=(\d{3})+(?!\d))/g, '.') + '-' + limpio.slice(-1);
      }
      if (formato !== campo.value) campo.value = formato;
      var completo = /^\d{7,8}[0-9K]$/.test(limpio);
      campo.setCustomValidity(completo && digitoVerificador(limpio.slice(0, -1)) !== limpio.slice(-1)
        ? 'El RUT no es válido: revisa el dígito verificador.' : '');
    });
  });

  document.querySelectorAll('.abrir-sub').forEach(function (boton) {
    boton.addEventListener('click', function () {
      var abierto = boton.getAttribute('aria-expanded') === 'true';
      boton.setAttribute('aria-expanded', String(!abierto));
      boton.parentElement.classList.toggle('sub-abierto', !abierto);
    });
  });

  // Portada: saludo a las compañias que estan de aniversario hoy (DIAS_SALUDO permite
  // mantenerlo unos dias mas). Para probar otro dia: ?fecha=MM-DD (por ejemplo ?fecha=11-08).
  var datos = document.getElementById('aniversarios');
  var saludos = document.getElementById('saludos');
  if (datos && saludos) {
    var MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
                 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    var DIAS_SALUDO = 0;   // dias que sigue visible despues del aniversario
    var hoy = new Date();
    var prueba = /[?&]fecha=(\d{2})-(\d{2})/.exec(location.search);
    if (prueba) hoy = new Date(hoy.getFullYear(), +prueba[1] - 1, +prueba[2]);
    hoy.setHours(0, 0, 0, 0);
    JSON.parse(datos.textContent).map(function (c) {
      // el aniversario mas reciente (este año, o el anterior si aun no llega)
      var fecha = new Date(hoy.getFullYear(), c.mes - 1, c.dia);
      if (fecha > hoy) fecha.setFullYear(fecha.getFullYear() - 1);
      c.hace = Math.round((hoy - fecha) / 86400000);
      c.anios = fecha.getFullYear() - c.anio;
      return c;
    }).filter(function (c) {
      return c.hace <= DIAS_SALUDO;
    }).sort(function (a, b) {
      return a.hace - b.hace;
    }).forEach(function (c) {
      var anios = c.anios;
      var cuando = c.hace === 0 ? null : 'el ' + c.dia + ' de ' + MESES[c.mes - 1];
      var tarjeta = document.createElement(c.enlace ? 'a' : 'div');
      tarjeta.className = 'saludo';
      if (c.enlace) { tarjeta.href = c.enlace; tarjeta.target = '_blank'; tarjeta.rel = 'noopener'; }
      if (c.escudo) {
        var img = document.createElement('img');
        img.src = c.escudo;
        img.alt = '';
        tarjeta.appendChild(img);
      }
      var texto = document.createElement('p');
      if (c.propia) {
        texto.innerHTML = cuando
          ? '<strong>¡La Quinta estuvo de aniversario!</strong> ' + cuando[0].toUpperCase() + cuando.slice(1) + ' cumplimos ' + anios + ' años al servicio de Talcahuano.'
          : '<strong>¡Hoy la Quinta está de aniversario!</strong> Cumplimos ' + anios + ' años al servicio de Talcahuano.';
      } else {
        texto.appendChild(document.createTextNode(cuando ? 'Saludamos a la ' : 'Hoy saludamos a la '));
        var nombre = document.createElement('strong');
        nombre.textContent = c.nombre;
        texto.appendChild(nombre);
        texto.appendChild(document.createTextNode(cuando
          ? ', que ' + cuando + ' cumplió ' + anios + ' años.'
          : ' por su aniversario de ' + anios + ' años.'));
      }
      tarjeta.appendChild(texto);
      saludos.appendChild(tarjeta);
      saludos.hidden = false;
    });
  }

  // Carrusel de fotos de las fichas de Material Mayor: las flechas avanzan de a un ancho y
  // se esconden en los extremos. Sin JavaScript, la pista igual se desplaza con el dedo.
  document.querySelectorAll('.carrusel').forEach(function (carrusel) {
    var pista = carrusel.querySelector('.carrusel-pista');
    var anterior = carrusel.querySelector('.anterior');
    var siguiente = carrusel.querySelector('.siguiente');
    function flechas() {
      anterior.hidden = pista.scrollLeft <= 4;
      siguiente.hidden = pista.scrollLeft + pista.clientWidth >= pista.scrollWidth - 4;
    }
    anterior.addEventListener('click', function () { pista.scrollBy({ left: -pista.clientWidth, behavior: 'smooth' }); });
    siguiente.addEventListener('click', function () { pista.scrollBy({ left: pista.clientWidth, behavior: 'smooth' }); });
    pista.addEventListener('scroll', flechas);
    window.addEventListener('resize', flechas);
    // carrusel de unidades: parte centrado en la unidad de la ficha
    var actual = pista.querySelector('.actual');
    if (actual) pista.scrollLeft = actual.offsetLeft - pista.offsetLeft - (pista.clientWidth - actual.offsetWidth) / 2;
    flechas();
  });

  // Visor de fotos: tocar una foto de una ficha o de Historia la muestra en grande, con
  // flechas para recorrer las demas fotos de la misma ficha o del mismo hito.
  var FOTOS = '.ficha-foto img, .carrusel-pista > img, .hito-fotos img, .miniatura img';
  var visor = document.createElement('dialog');
  visor.className = 'visor';
  visor.innerHTML = '<figure><img alt=""><figcaption></figcaption></figure>'
    + '<button type="button" class="visor-cerrar" aria-label="Cerrar">×</button>'
    + '<button type="button" class="carrusel-boton anterior" aria-label="Foto anterior">‹</button>'
    + '<button type="button" class="carrusel-boton siguiente" aria-label="Foto siguiente">›</button>';
  document.body.appendChild(visor);
  var grupo = [], actual = 0;
  var grande = visor.querySelector('img'), leyenda = visor.querySelector('figcaption');
  function mostrar(i) {
    actual = (i + grupo.length) % grupo.length;
    grande.src = grupo[actual].src;
    grande.alt = leyenda.textContent = grupo[actual].alt;
  }
  document.addEventListener('click', function (e) {
    var foto = e.target.closest('.ficha-foto img, .carrusel-pista > img, .hito-fotos img, .galeria-principal');
    if (!foto || visor.open) return;
    grupo = [].slice.call((foto.closest('.hito, article') || document).querySelectorAll(FOTOS));
    var i = 0;
    grupo.forEach(function (f, n) { if (f.src === foto.src) i = n; });
    visor.querySelector('.anterior').hidden = visor.querySelector('.siguiente').hidden = grupo.length < 2;
    mostrar(i);
    visor.showModal();
  });
  visor.querySelector('.visor-cerrar').addEventListener('click', function () { visor.close(); });
  visor.querySelector('.anterior').addEventListener('click', function () { mostrar(actual - 1); });
  visor.querySelector('.siguiente').addEventListener('click', function () { mostrar(actual + 1); });
  // tocar fuera de la foto cierra; las flechas del teclado cambian de foto
  visor.addEventListener('click', function (e) { if (e.target === visor || e.target.tagName === 'FIGURE') visor.close(); });
  visor.addEventListener('keydown', function (e) {
    if (grupo.length < 2) return;
    if (e.key === 'ArrowLeft') mostrar(actual - 1);
    if (e.key === 'ArrowRight') mostrar(actual + 1);
  });

  // Galeria de un hito de Historia: tocar una miniatura la deja como foto principal
  document.querySelectorAll('.hito-galeria').forEach(function (galeria) {
    var principal = galeria.querySelector('.galeria-principal');
    galeria.querySelectorAll('.miniatura').forEach(function (miniatura) {
      miniatura.addEventListener('click', function () {
        var foto = miniatura.querySelector('img');
        principal.src = foto.src;
        principal.alt = foto.alt;
        galeria.querySelector('.miniatura.actual').classList.remove('actual');
        miniatura.classList.add('actual');
      });
    });
  });
});
