package plantilla;
# Plantilla comun (cabecera, menu, pie) y lista de paginas del sitio.
use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw(pagina rutas_paginas);

my $NOMBRE  = 'Quinta Compañía de Bomberos de Talcahuano';
my $SUBUPLOADS = 'http://www.funfte.cl/sitio/wp-content/uploads';

# clave => origen (consulta en el sitio antiguo), ruta nueva, titulo, seccion del menu.
# Las paginas sin origen tienen contenido propio definido en este archivo.
sub rutas_paginas {
    my %p = (
        inicio        => [undef,                        '',                          'Inicio',              ''],
        laquinta      => ['?page_id=1195',              'la-quinta/',                'La Quinta',           'La Quinta'],
        historia      => ['?page_id=1670',              'historia/',                 'Historia',            'La Quinta'],
        cuartel       => ['?page_id=1792',              'cuartel/',                  'Cuartel',             'La Quinta'],
        confederacion => ['?page_id=1738',              'confederacion/',            'Confederación',       'La Quinta'],
        socios        => ['?page_id=1826',              'socios-colaboradores/',     'Socios Colaboradores','La Quinta'],
        dotacion      => ['?page_id=1899',              'dotacion/',                 'Dotación',            'Dotación'],
        directorio    => ['?page_id=1911',              'directorio/',               'Directorio',          'Dotación'],
        trabajo       => ['?page_id=1928',              'nuestro-trabajo/',          'Nuestro Trabajo',     'Nuestro Trabajo'],
        capacitacion  => ['?page_id=1940',              'capacitacion/',             'Capacitación',        'Nuestro Trabajo'],
        guardia       => ['?page_id=1946',              'guardia-nocturna/',         'Guardia Nocturna',    'Nuestro Trabajo'],
        formacion     => [undef,                        'formacion/',                'Formación',           'Nuestro Trabajo'],
        acceso        => [undef,                        'acceso-quintino/',          'Acceso Quintino',     ''],
        material      => ['?page_id=1097',              'material-mayor/',           'Material Mayor',      'Material Mayor'],
        bx5           => ['?portfolio=lorem-ipsum',     'material-mayor/bx-5/',      'Unidad BX-5',         'Material Mayor'],
        b5            => ['?portfolio=unidad-br-5',     'material-mayor/b-5/',       'Unidad B-5',          'Material Mayor'],
        harbor        => ['?portfolio=unidad-harbor-28','material-mayor/harbor-28/', 'Unidad Harbor 28',    'Material Mayor'],
        contacto      => ['?page_id=1167',              'contacto/',                 'Contacto',            'Contacto'],
        redes         => ['?page_id=1962',              'redes-sociales/',           'Redes Sociales',      'Contacto'],
    );
    return map { $_ => { origen => $p{$_}[0], ruta => $p{$_}[1], titulo => $p{$_}[2], seccion => $p{$_}[3] } } keys %p;
}

my $WEBMAIL = 'https://mail.google.com/a/funfte.cl/';
my $AULA    = 'https://aula.anb.cl/moodle/login/index.php';
my $ANB     = 'https://www.anb.cl';

# Pagina "Acceso Quintino":[titulo, detalle, enlace, icono] (sin enlace = pronto)
my @ACCESOS = (
    ['Webmail',                          'Correo electrónico institucional @funfte.cl mediante la plataforma de Google.', $WEBMAIL, 'correo'],
    ['Plataforma de Registro y Control', 'Plataforma de administración y gestión interna de bomberos SISAB.', 'http://www.sisab.cl', 'sisab'],
    ['Registro Nacional de Bomberos',    'Acceso RNB a los sistemas de la Junta Nacional de Bomberos.', 'https://www.bomberos.cl/sist/escritorio_virtual/', 'documento'],
    ['Aula Virtual ANB',                 'Cursos en línea de la Academia Nacional de Bomberos.', $AULA, 'birrete'],
    ['Convocatorias para Bomberos',      'Cursos abiertos y fechas de postulación de la ANB.', "$ANB/convocatorias-para-bomberos", 'convoca'],
    ['Cuerpo de Bomberos de Talcahuano', 'Sitio oficial del Cuerpo de Bomberos de Talcahuano.', 'https://cbt.cl', 'web'],
    ['Bomberos de Chile',                'Sitio de la Junta Nacional de Cuerpos de Bomberos de Chile.', 'https://www.bomberos.cl', 'web'],
    ['Biblioteca Virtual',               'Material de trabajo interno, oficios y manuales operativos.', undef, 'libro'],
);

my @MENU = (
    ['Inicio', ''],
    ['La Quinta', 'la-quinta/', [['Historia','historia/'], ['Cuartel','cuartel/'], ['Confederación','confederacion/'], ['Socios Colaboradores','socios-colaboradores/']]],
    ['Dotación', 'dotacion/', [['Directorio','directorio/']]],
    ['Nuestro Trabajo', 'nuestro-trabajo/', [['Capacitación','capacitacion/'], ['Formación','formacion/'], ['Guardia Nocturna','guardia-nocturna/']]],
    ['Material Mayor', 'material-mayor/', [['Unidad B-5','material-mayor/b-5/'], ['Unidad BX-5','material-mayor/bx-5/'], ['Unidad Harbor 28','material-mayor/harbor-28/']]],
    ['Contacto', 'contacto/', [['Redes Sociales','redes-sociales/'], ['Webmail', $WEBMAIL]]],
);

my %ICONOS = (
    redes    => 'M18 16a3 3 0 0 0-2.4 1.2l-6.7-3.4a3 3 0 0 0 0-1.6l6.7-3.4A3 3 0 1 0 15 7l-6.7 3.4a3 3 0 1 0 0 3.2L15 17a3 3 0 1 0 3-1z',
    sisab    => 'M12 2 4 5v6c0 5 3.4 9.7 8 11 4.6-1.3 8-6 8-11V5l-8-3zm-1 14-4-4 1.4-1.4L11 13.2l4.6-4.6L17 10l-6 6z',
    correo   => 'M3 5h18v14H3V5zm2 2v.5l7 4.5 7-4.5V7H5zm14 2.9-7 4.5-7-4.5V17h14V9.9z',
    libro    => 'M5 3h11a3 3 0 0 1 3 3v15H7a2 2 0 0 1-2-2V3zm2 14v2h10v-2H7zm0-12v10h10V6a1 1 0 0 0-1-1H7z',
    camion   => 'M2 6h11v9h1V9h4l4 4v4h-2a2.5 2.5 0 0 1-5 0H9a2.5 2.5 0 0 1-5 0H2V6zm14 5v2h4l-2-2h-2zM6.5 16a1 1 0 1 0 0 2 1 1 0 0 0 0-2zm10 0a1 1 0 1 0 0 2 1 1 0 0 0 0-2z',
    corazon  => 'M12 21s-7.5-4.6-9.5-9.3C1.2 8.6 3.2 5 6.7 5c2 0 3.4 1 4.3 2.4h2C13.9 6 15.3 5 17.3 5c3.5 0 5.5 3.6 4.2 6.7C19.5 16.4 12 21 12 21z',
    reloj    => 'M12 2a10 10 0 1 1 0 20 10 10 0 0 1 0-20zm0 2a8 8 0 1 0 0 16 8 8 0 0 0 0-16zm1 3v5.4l3.5 2.1-1 1.7L11 13.5V7h2z',
    birrete  => 'M12 3 1 9l11 6 9-4.9V17h2V9L12 3zM5 13.2V17c0 1.7 3.1 3 7 3s7-1.3 7-3v-3.8l-7 3.8-7-3.8z',
    convoca  => 'M7 2h2v2h6V2h2v2h3v18H4V4h3V2zm-1 8v10h12V10H6zm2 2h3v3H8v-3z',
    documento=> 'M6 2h8l6 6v14H6V2zm7 1.5V9h5.5L13 3.5zM8 12v2h8v-2H8zm0 4v2h8v-2H8z',
    validar  => 'M12 2a10 10 0 1 1 0 20 10 10 0 0 1 0-20zm-1.2 13.6 6.4-6.4-1.4-1.4-5 5-2.4-2.4L7 11.8l3.8 3.8z',
    web      => 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm6.9 6h-3a15 15 0 0 0-1.3-3.9A8 8 0 0 1 18.9 8zM12 4c.8 1.1 1.5 2.5 1.9 4h-3.8c.4-1.5 1.1-2.9 1.9-4zM4.3 14a8 8 0 0 1 0-4h3.4a16 16 0 0 0 0 4H4.3zm.8 2h3a15 15 0 0 0 1.3 3.9A8 8 0 0 1 5.1 16zm3-8h-3a8 8 0 0 1 4.3-3.9C8.7 5.3 8.3 6.6 8.1 8zM12 20c-.8-1.1-1.5-2.5-1.9-4h3.8c-.4 1.5-1.1 2.9-1.9 4zm2.3-6H9.7a14 14 0 0 1 0-4h4.6a14 14 0 0 1 0 4zm.3 5.9a15 15 0 0 0 1.3-3.9h3a8 8 0 0 1-4.3 3.9zM16.3 14a16 16 0 0 0 0-4h3.4a8 8 0 0 1 0 4h-3.4z',
    candado  =>'M12 2a5 5 0 0 1 5 5v3h2v12H5V10h2V7a5 5 0 0 1 5-5zm0 2a3 3 0 0 0-3 3v3h6V7a3 3 0 0 0-3-3zm0 9a2 2 0 0 0-1 3.7V19h2v-2.3A2 2 0 0 0 12 13z',
);

sub icono { qq(<svg viewBox="0 0 24 24" aria-hidden="true"><path d="$ICONOS{$_[0]}"/></svg>) }

sub externo { $_[0] =~ /^https?:/ }

sub enlace {
    my ($p, $ruta) = @_;
    return externo($ruta) ? qq(href="$ruta" target="_blank" rel="noopener") : qq(href="$p$ruta");
}

# Tarjeta con icono; sin enlace muestra "Pronto"
sub tarjeta {
    my ($p, $icono, $titulo, $texto, $href, $boton) = @_;
    my $pie = $href ? '<a class="boton" ' . enlace($p, $href) . ">$boton</a>" : '<span class="pronto">Pronto</span>';
    return qq(<article class="tarjeta">) . icono($icono) . qq(<h3>$titulo</h3><p>$texto</p>$pie</article>\n);
}

sub menu {
    my ($p, $actual, $seccion) = @_;
    my $h = '';
    my $n = 0;
    for my $m (@MENU) {
        my ($texto, $ruta, $sub) = @$m;
        my $activo = ($texto eq $seccion || ($ruta eq '' && $actual eq '')) ? ' class="activo"' : '';
        my $cur = $ruta eq $actual ? ' aria-current="page"' : '';
        if ($sub) {
            $n++;
            $h .= qq(<li$activo><a ) . enlace($p, $ruta) . qq($cur>$texto</a><button class="abrir-sub" aria-expanded="false" aria-controls="sub$n" aria-label="Ver submenú de $texto"></button>\n<ul class="submenu" id="sub$n">\n);
            for my $s (@$sub) {
                my $c = $s->[1] eq $actual ? ' aria-current="page"' : '';
                $h .= qq(<li><a ) . enlace($p, $s->[1]) . qq($c>$s->[0]</a></li>\n);
            }
            $h .= "</ul></li>\n";
        } else {
            $h .= qq(<li$activo><a ) . enlace($p, $ruta) . qq($cur>$texto</a></li>\n);
        }
    }
    return $h;
}

sub acceso_personal {
    my ($p) = @_;
    # La intranet aun no tiene servidor: el formulario queda deshabilitado hasta conectarlo.
    my $h = qq(<section class="wrap bloque">
<div class="intranet">
<div class="intranet-texto">
) . icono('candado') . qq(
<h2>Intranet Quintina</h2>
</div>
<form class="intranet-form" action="#" onsubmit="return false" aria-describedby="intranet-aviso">
<fieldset disabled>
<legend>Ingresar a la intranet</legend>
<label for="usuario">RUT o correo \@funfte.cl</label>
<input id="usuario" name="usuario" type="text" autocomplete="username" placeholder="12.345.678-9">
<label for="clave">Contraseña</label>
<input id="clave" name="clave" type="password" autocomplete="current-password">
<button class="boton" type="submit">Ingresar</button>
<p id="intranet-aviso" class="intranet-ayuda">¿Problemas para ingresar? Escribe a <a href="mailto:correo\@funfte.cl">correo\@funfte.cl</a>.</p>
</fieldset>
</form>
</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Otros accesos</h2>
<div class="grilla-tarjetas">
);
    $h .= tarjeta($p, $_->[3], $_->[0], $_->[1], $_->[2], 'Ingresar') for @ACCESOS;
    return $h . "</div>\n</section>";
}

sub inicio {
    my ($p, $imagen) = @_;
    my $portada = $imagen->("$SUBUPLOADS/2011/12/DSC0103-1030x688.jpg");
    my $escudo  = $imagen->("$SUBUPLOADS/2013/04/Sin-t%C3%ADtulo-3.png");
    return
qq(<section class="portada" style="background-image:url('${p}assets/img/$portada')">
<div class="wrap">
<p class="antetitulo">Fünfte Deutsche Feuerwehrkompanie Talcahuano</p>
<h1>Quinta Compañía de Bomberos<br>«Bomba Chile» de Talcahuano</h1>
<p class="bajada">Fundada el 29 de enero de 1908. Especialidad en agua y rescate integral al servicio de Talcahuano.</p>
<div class="acciones"><a class="boton" href="${p}la-quinta/">Conoce la Quinta</a><a class="boton secundario" href="${p}socios-colaboradores/">Hazte socio</a></div>
</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Accesos</h2>
<div class="grilla-tarjetas">
) . tarjeta($p, 'redes', 'Redes Sociales', 'Te invitamos a participar e interactuar con nosotros mediante las redes sociales: Facebook, Instagram, Twitter y YouTube.', 'redes-sociales/', 'Ingresar')
  . tarjeta($p, 'birrete', 'Formación', 'Aula virtual, convocatorias y material de estudio de la Academia Nacional de Bomberos.', 'formacion/', 'Ver más')
  . tarjeta($p, 'sisab', 'Plataforma de Registro y Control', 'Ingreso a la plataforma de administración y gestión interna de bomberos SISAB.', 'http://www.sisab.cl', 'Ingresar')
  . tarjeta($p, 'correo', 'Webmail', 'Ingreso al correo electrónico institucional mediante la plataforma de Google.', $WEBMAIL, 'Ir al webmail')
  . qq(</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">La Quinta</h2>
<div class="grilla-tarjetas tres">
) . tarjeta($p, 'camion', 'Nuestras unidades', 'Conoce nuestras máquinas BX-5 y B-5 y sus especificaciones.', 'material-mayor/', 'Ver más')
  . tarjeta($p, 'corazon', 'Hazte socio', 'Colabora con la Quinta y hazte socio cooperador. Con tu ayuda continuaremos salvando vidas.', 'socios-colaboradores/', 'Ver más')
  . tarjeta($p, 'reloj', 'Sitio centenario', 'Navega a través de la historia de nuestra compañía en el especial del centenario.')
  . qq(</div>
</section>
<section class="lema">
<div class="wrap">
<img src="${p}assets/img/$escudo" alt="" loading="lazy">
<blockquote><p lang="de">«Gott zur Ehr, dem Nächsten zur Wehr»</p><p>«En honor a Dios y ayuda del prójimo»</p></blockquote>
<p class="anios">1908 – 2020</p>
</div>
</section>);
}

sub formacion {
    my ($p) = @_;
    return
qq(<section class="wrap bloque">
<p class="intro">La formación permanente es uno de los pilares de la Quinta. Aquí reunimos los accesos a las plataformas de capacitación de la Academia Nacional de Bomberos (ANB) y otros recursos de estudio para nuestros voluntarios.</p>
<div class="destacado">
) . icono('birrete') . qq(
<div>
<h2>Aula Virtual ANB</h2>
<p>Plataforma de cursos en línea de la Academia Nacional de Bomberos. Ingresa con tu usuario del Registro Nacional de Bomberos.</p>
</div>
<a class="boton" href="$AULA" target="_blank" rel="noopener">Entrar al aula virtual</a>
</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Academia Nacional de Bomberos</h2>
<div class="grilla-tarjetas tres">
) . tarjeta($p, 'convoca', 'Convocatorias para Bomberos', 'Cursos abiertos y fechas de postulación de la ANB.', "$ANB/convocatorias-para-bomberos", 'Ver convocatorias')
  . tarjeta($p, 'birrete', 'Programas académicos', 'Niveles inicial, operativo y profesional, y especialidades.', "$ANB/programas-academicos-nivel-inicial", 'Ver programas')
  . tarjeta($p, 'documento', 'Material académico', 'Manuales y material de apoyo para los cursos de la Academia.', "$ANB/material-academico", 'Ver material')
  . tarjeta($p, 'libro', 'Guías de autoinstrucción', 'Guías para estudiar de forma autónoma antes de cada curso.', "$ANB/guias-de-autoinstruccion", 'Ver guías')
  . tarjeta($p, 'documento', 'Artículos técnicos', 'Publicaciones técnicas para la actualización de conocimientos.', "$ANB/articulos-tecnicos", 'Ver artículos')
  . tarjeta($p, 'validar', 'Validador de cursos', 'Verifica la validez de certificados de cursos de la ANB.', "$ANB/validador_cursos", 'Validar')
  . qq(</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Más recursos</h2>
<div class="grilla-tarjetas tres">
) . tarjeta($p, 'sisab', 'Capacitación en la Quinta', 'Cómo se organiza la instrucción de cadetes, brigadieres y voluntarios en nuestra compañía.', 'capacitacion/', 'Ver más')
  . tarjeta($p, 'libro', 'Bibliotecas de Bomberos de Chile', 'Publicaciones, revistas y documentos de la Junta Nacional de Bomberos.', 'https://www.bomberos.cl/bibliotecas', 'Ir a bibliotecas')
  . tarjeta($p, 'candado', 'Biblioteca Virtual de la Quinta', 'Material de trabajo interno, oficios y manuales operativos de la compañía.')
  . qq(</div>
</section>);
}

sub pagina {
    my %a = @_;
    my $p = '../' x ($a{ruta} =~ tr{/}{});
    my $es_inicio = $a{clave} eq 'inicio';
    my $titulo = $es_inicio ? "$NOMBRE | Fünfte Deutsche Feuerwehrkompanie" : "$a{titulo} | $NOMBRE";
    my $cabecera = qq(<section class="cabecera-pagina"><div class="wrap">)
        . ($a{seccion} && $a{seccion} ne $a{titulo} ? qq(<p class="antetitulo">$a{seccion}</p>) : '')
        . qq(<h1>$a{titulo}</h1></div></section>\n);
    my $cuerpo = $es_inicio                 ? inicio($p, $a{imagen})
               : $a{clave} eq 'formacion'   ? $cabecera . formacion($p)
               : $a{clave} eq 'acceso'      ? $cabecera . acceso_personal($p)
               : $cabecera . qq(<article class="wrap contenido">\n$a{contenido}\n</article>);
    my $menu = menu($p, $a{ruta}, $a{seccion});
    my $acceso_actual = $a{clave} eq 'acceso' ? ' aria-current="page"' : '';
    my $candado = icono('candado');
    my $anio = (localtime)[5] + 1900;
    return <<"HTML";
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$titulo</title>
<meta name="description" content="Quinta Compañía de Bomberos «Bomba Chile» de Talcahuano, fundada en 1908. Fünfte Deutsche Feuerwehrkompanie Talcahuano.">
<link rel="icon" href="${p}assets/img/logo.png">
<link rel="stylesheet" href="${p}assets/css/estilos.css">
<script src="${p}assets/js/menu.js" defer></script>
</head>
<body>
<a class="saltar" href="#principal">Saltar al contenido</a>
<header class="cabecera">
<div class="wrap cabecera-fila">
<a class="marca" href="$p"><img src="${p}assets/img/logo.png" alt="Fünfte – Quinta Compañía de Bomberos de Talcahuano"></a>
<nav aria-label="Principal">
<ul class="menu" id="menu-principal">
$menu</ul>
</nav>
<a class="boton-acceso" href="${p}acceso-quintino/"$acceso_actual>$candado<span>Acceso Quintino</span></a>
<button class="abrir-menu" aria-expanded="false" aria-controls="menu-principal">Menú</button>
</div>
</header>
<main id="principal">
$cuerpo
</main>
<footer class="pie">
<div class="wrap pie-grilla">
<div>
<h2>Contacto</h2>
<p><strong>Quinta Compañía de Bomberos de Talcahuano</strong><br>Fünfte Deutsche Feuerwehrkompanie Stadt Talcahuano</p>
<p>Avenida Río Maule 5383, Villa Independencia<br>Sector Denavi Sur, Talcahuano, Chile</p>
</div>
<div>
<h2>Comunícate</h2>
<p>Fono-fax: <a href="tel:+56412588000">+56 41 258 8000</a><br><a href="mailto:correo\@funfte.cl">correo\@funfte.cl</a></p>
<p class="emergencia">Emergencias: <a href="tel:132">132</a></p>
</div>
<div>
<h2>Enlaces</h2>
<ul class="pie-enlaces">
<li><a href="${p}historia/">Historia</a></li>
<li><a href="${p}material-mayor/">Material Mayor</a></li>
<li><a href="${p}formacion/">Formación</a></li>
<li><a href="${p}socios-colaboradores/">Socios Colaboradores</a></li>
<li><a href="${p}contacto/">Contacto</a></li>
<li><a href="https://cbt.cl" target="_blank" rel="noopener">Cuerpo de Bomberos de Talcahuano</a></li>
</ul>
</div>
</div>
<p class="wrap derechos">© $anio Fünfte Deutsche Feuerwehrkompanie Talcahuano – Quinta Compañía de Bomberos de Talcahuano</p>
</footer>
</body>
</html>
HTML
}

1;
