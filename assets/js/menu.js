// Menu principal: boton para celulares y submenus desplegables.
document.addEventListener('DOMContentLoaded', function () {
  var botonMenu = document.querySelector('.abrir-menu');
  var menu = document.getElementById('menu-principal');

  botonMenu.addEventListener('click', function () {
    var abierto = botonMenu.getAttribute('aria-expanded') === 'true';
    botonMenu.setAttribute('aria-expanded', String(!abierto));
    menu.classList.toggle('abierto', !abierto);
  });

  document.querySelectorAll('.abrir-sub').forEach(function (boton) {
    boton.addEventListener('click', function () {
      var abierto = boton.getAttribute('aria-expanded') === 'true';
      boton.setAttribute('aria-expanded', String(!abierto));
      boton.parentElement.classList.toggle('sub-abierto', !abierto);
    });
  });
});
