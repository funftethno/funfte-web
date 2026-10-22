// Dotacion con fotos (Archivo): la generacion de cada voluntario viene cifrada y se muestra
// al ingresar la contraseña. El cifrado es el de "openssl enc -aes-256-cbc -pbkdf2 -md sha256"
// (ver herramientas/cifrar_generaciones.pl): "Salted__", 8 bytes de sal y el texto cifrado.
document.addEventListener('DOMContentLoaded', function () {
  var datos = document.getElementById('generaciones');
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

  // agrega a cada tarjeta su numero de registro (sobre el nombre) y su generacion (debajo)
  function mostrar(generaciones) {
    document.querySelectorAll('.nomina.fotos li[data-registro]').forEach(function (li) {
      var registro = li.getAttribute('data-registro');
      var span = document.createElement('span');
      span.textContent = registro;
      li.querySelector('.foto').after(span);
      if (!generaciones[registro]) return;
      var s = document.createElement('small');
      s.textContent = 'Generación ' + generaciones[registro];
      li.appendChild(s);
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
