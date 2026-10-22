// Dotacion con fotos (Archivo): la generacion y el numero de registro de cada voluntario vienen
// cifrados y se muestran al ingresar la contraseña. El cifrado es el de "openssl enc -aes-256-cbc
// -pbkdf2 -md sha256" (ver herramientas/cifrar_privados.pl): "Salted__", 8 bytes de sal y el texto.
document.addEventListener('DOMContentLoaded', function () {
  var datos = document.getElementById('privados');
  var form = document.getElementById('desbloqueo');
  if (!datos || !form) return;
  if (!window.crypto || !crypto.subtle) { form.hidden = true; return; }

  var cifrado = JSON.parse(datos.textContent);
  var bytes = Uint8Array.from(atob(cifrado.datos), function (c) { return c.charCodeAt(0); });
  var sal = bytes.slice(8, 16);
  var texto = bytes.slice(16);
  var aviso = document.getElementById('desbloqueo-aviso');

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

  // agrega debajo del nombre de cada tarjeta su generacion y su numero de registro
  function mostrar(voluntarios) {
    document.querySelectorAll('.nomina.fotos li').forEach(function (li) {
      var nombre = Array.prototype.filter.call(li.childNodes, function (n) { return n.nodeType === 3; })
        .map(function (n) { return n.textContent; }).join('').trim();
      var v = voluntarios[nombre];
      if (!v) return;
      [['generacion', 'Generación '], ['registro', 'Registro N° ']].forEach(function (dato) {
        if (!v[dato[0]]) return;
        var s = document.createElement('small');
        s.textContent = dato[1] + v[dato[0]];
        li.appendChild(s);
      });
    });
    form.hidden = true;
  }

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    aviso.textContent = 'Revisando…';
    descifrar(form.clave.value).then(mostrar, function () {
      aviso.textContent = 'Contraseña incorrecta.';
      form.clave.select();
    });
  });
});
