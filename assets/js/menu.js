// Menu principal: boton para celulares y submenus desplegables.
document.addEventListener('DOMContentLoaded', function () {
  var botonMenu = document.querySelector('.abrir-menu');
  var menu = document.getElementById('menu-principal');

  botonMenu.addEventListener('click', function () {
    var abierto = botonMenu.getAttribute('aria-expanded') === 'true';
    botonMenu.setAttribute('aria-expanded', String(!abierto));
    menu.classList.toggle('abierto', !abierto);
  });

  // Campos de formulario que solo aceptan digitos (por ejemplo, el telefono de Contacto)
  document.querySelectorAll('[data-solo-numeros]').forEach(function (campo) {
    campo.addEventListener('input', function () {
      var limpio = campo.value.replace(/\D/g, '');
      if (limpio !== campo.value) campo.value = limpio;
    });
  });

  document.querySelectorAll('.abrir-sub').forEach(function (boton) {
    boton.addEventListener('click', function () {
      var abierto = boton.getAttribute('aria-expanded') === 'true';
      boton.setAttribute('aria-expanded', String(!abierto));
      boton.parentElement.classList.toggle('sub-abierto', !abierto);
    });
  });
});
