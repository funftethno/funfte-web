// Dotacion con fotos (Archivo): la generacion y el numero de registro de cada voluntario vienen
// cifrados y se muestran al ingresar la contraseña. El cifrado es el de "openssl enc -aes-256-cbc
// -pbkdf2 -md sha256" (ver herramientas/cifrar_privados.pl): "Salted__", 8 bytes de sal y el texto.
// No hay formulario a la vista: la contraseña se escribe con el teclado en cualquier parte de la
// pagina, como un truco de videojuego. En el celular, cinco toques seguidos al titulo abren el
// teclado sobre un campo invisible.
document.addEventListener('DOMContentLoaded', function () {
  var datos = document.getElementById('privados');
  var campo = document.getElementById('truco');
  if (!datos || !campo || !window.crypto || !crypto.subtle) return;

  var cifrado = JSON.parse(datos.textContent);
  var bytes = Uint8Array.from(atob(cifrado.datos), function (c) { return c.charCodeAt(0); });
  var sal = bytes.slice(8, 16);
  var texto = bytes.slice(16);

  function descifrar(clave) {
    return crypto.subtle.importKey('raw', new TextEncoder().encode(clave), 'PBKDF2', false, ['deriveBits'])
      .then(function (k) {
        return crypto.subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt: sal, iterations: cifrado.iteraciones }, k, 384);
      })
      .then(function (bits) {
        var b = new Uint8Array(bits);   // 32 bytes de clave AES y 16 de vector inicial
        return crypto.subtle.importKey('raw', b.slice(0, 32), 'AES-CBC', false, ['decrypt'])
          .then(function (k) { return crypto.subtle.decrypt({ name: 'AES-CBC', iv: b.slice(32) }, k, texto); });
      })
      .then(function (claro) { return JSON.parse(new TextDecoder().decode(claro)); });
  }

  // agrega al pie de cada tarjeta su generacion y su numero de registro
  function mostrar(voluntarios) {
    document.querySelectorAll('.nomina.fotos li').forEach(function (li) {
      var nombre = Array.prototype.filter.call(li.childNodes, function (n) { return n.nodeType === 3; })
        .map(function (n) { return n.textContent; }).join('').trim();
      var v = voluntarios[nombre];
      if (!v) return;
      var dl = document.createElement('dl');
      dl.className = 'privados';
      [['generacion', 'Generación'], ['registro', 'Registro']].forEach(function (dato) {
        if (!v[dato[0]]) return;
        var div = document.createElement('div');
        var dt = document.createElement('dt');
        var dd = document.createElement('dd');
        dt.textContent = dato[1];
        dd.textContent = (dato[0] === 'registro' ? 'N° ' : '') + v[dato[0]];
        div.append(dt, dd);
        dl.appendChild(div);
      });
      li.appendChild(dl);
    });
    listo = true;
    campo.blur();
  }

  // lo escrito se prueba cuando se deja de teclar un momento; si no sirve, se olvida sin avisar
  var escrito = '', espera, listo = false;
  function probar() {
    var clave = escrito;
    escrito = '';
    campo.value = '';
    if (clave) descifrar(clave).then(mostrar, function () {});
  }
  function tecla(texto) {
    if (listo) return;
    escrito = texto;
    clearTimeout(espera);
    espera = setTimeout(probar, 900);
  }
  document.addEventListener('keydown', function (e) {
    if (e.target === campo || e.ctrlKey || e.metaKey || e.altKey) return;
    if (e.key.length === 1) tecla(escrito + e.key);
    else if (e.key === 'Backspace') tecla(escrito.slice(0, -1));
  });
  campo.addEventListener('input', function () { tecla(campo.value); });

  var titulo = document.querySelector('h1'), toques = 0, reinicio;
  if (titulo) titulo.addEventListener('click', function () {
    clearTimeout(reinicio);
    reinicio = setTimeout(function () { toques = 0; }, 1500);
    if (++toques >= 5) { toques = 0; campo.focus(); }
  });
});
