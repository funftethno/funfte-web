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

  // Portada: saludo a las compañias que estan de aniversario hoy o lo estuvieron en la
  // ultima semana. Para probar otro dia: ?fecha=MM-DD (por ejemplo ?fecha=11-08).
  var datos = document.getElementById('aniversarios');
  var saludos = document.getElementById('saludos');
  if (datos && saludos) {
    var MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
                 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    var DIAS_SALUDO = 7;
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
});
