package plantilla;
# Plantilla comun (cabecera, menu, pie) y lista de paginas del sitio.
use strict;
use warnings;
use utf8;
use Exporter 'import';
use Digest::MD5 qw(md5_hex);
use FindBin;
our @EXPORT_OK = qw(pagina rutas_paginas);

my $NOMBRE  = 'Quinta Compañía de Bomberos de Talcahuano';

# Huella del contenido de CSS y JS: cambia la URL cuando cambia el archivo, para que
# el navegador no use una version vieja guardada en cache (ver _headers).
sub huella {
    open my $fh, '<:raw', "$FindBin::Bin/../$_[0]" or return '';
    local $/;
    return '?v=' . substr(md5_hex(<$fh>), 0, 8);
}
my $V_CSS = huella('assets/css/estilos.css');
my $V_JS  = huella('assets/js/menu.js');
my $V_CAL = huella('assets/js/calendario.js');

# Direccion publica del sitio (enlaces canonicos, Open Graph y sitemap)
our $SITIO = 'https://funfte.cl/';

# Datos publicos de la compania: el pie y los datos estructurados para Google los usan
my $FUNDACION = '1908-01-29';
my $CORREO    = 'correo@funfte.cl';
my %DIRECCION = (calle => 'Río Maule 5383, Villa Independencia', comuna => 'Talcahuano',
                 region => 'Región del Biobío', pais => 'CL');
my @COORDENADAS = (-36.763267, -73.092603);   # las mismas del mapa de Contacto
my @REDES = (['Instagram', 'https://www.instagram.com/funftetalcahuano/'],
             ['Facebook',  'https://www.facebook.com/funfte']);

# Texto para buscadores y para la vista previa al compartir un enlace (WhatsApp,
# Facebook). Las paginas sin descripcion propia usan $DESCRIPCION.
my $DESCRIPCION = 'Quinta Compañía de Bomberos «Bomba Chile» de Talcahuano, fundada en 1908. Fünfte Deutsche Feuerwehrkompanie Talcahuano.';
my %DESCRIPCIONES = (
    inicio        => 'Sitio oficial de la Quinta Compañía de Bomberos «Bomba Chile» de Talcahuano, fundada el 29 de enero de 1908. Especialidad en agua y rescate integral.',
    laquinta      => 'Quiénes somos: la Quinta Compañía «Bomba Chile» del Cuerpo de Bomberos de Talcahuano, fundada en 1908 por inmigrantes alemanes.',
    historia      => 'La historia de la Quinta Compañía de Bomberos de Talcahuano desde su fundación en 1908 por la colonia alemana del puerto.',
    cuartel       => 'Nuestro cuartel en Villa Independencia, ingreso sur de Talcahuano: instalaciones, guardia nocturna y área de acción.',
    cbt           => 'El Cuerpo de Bomberos de Talcahuano y sus diez compañías: nombres, fundación, especialidad y sector de cada una.',
    confederacion => 'La Confederación de Compañías Chileno-Alemanas de Bomberos: directorio y las compañías confederadas de todo Chile.',
    dotacion      => 'Oficialidad 2026–2028 y nómina de voluntarios de la Quinta Compañía de Bomberos de Talcahuano.',
    formacion     => 'Formación de voluntarios: convocatorias, Aula Virtual, malla curricular y material de la Academia Nacional de Bomberos.',
    postula       => 'Postula como bombero voluntario de la Quinta Compañía de Bomberos de Talcahuano. Completa el formulario y te contactaremos.',
    acceso        => 'Acceso Quintino: intranet y plataformas internas para voluntarios de la Quinta Compañía de Bomberos de Talcahuano.',
    material      => 'Material mayor de la Quinta: unidades en servicio y fotografías de sus unidades históricas desde 1908.',
    bx5           => 'Unidad BX-5: Iveco Magirus FF150E30W 4x4 de 2012, unidad mixta de incendio y rescate de la Quinta Compañía de Talcahuano.',
    b5            => 'Unidad B-5: Iveco Magirus FF150E30 de 2018, unidad de control de incendios de la Quinta Compañía de Talcahuano.',
    harbor        => 'Unidad Harbor 28: embarcación de rescate medioambiental para descontaminación de aguas de la Quinta Compañía de Talcahuano.',
    gallo         => 'Gallo, 1908: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    beduwe        => 'Usines Beduwé «Bomba Chile», 1911: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    hansa         => 'Hansa Lloyd Bomba Flanders, 1927: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    ford          => 'Ford Bomba Champion, 1941: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    berliet       => 'Berliet-Camiva, 1973: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    magirus       => 'Magirus Deutz, 1954: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    s170          => 'Renault Camiva S-170, 1990: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    b110          => 'Renault Camiva B-110, 1994: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    s150          => 'Renault Camiva S-150, 1999: fotografías del material mayor histórico de la Quinta Compañía de Bomberos de Talcahuano.',
    contacto      => 'Contacto de la Quinta Compañía de Bomberos de Talcahuano: Río Maule 5383, Villa Independencia. Correo, formulario de contacto y mapa.',
    error404      => 'La página que buscas no existe o cambió de dirección.',
);

# clave => ruta, titulo, seccion del menu.
# El contenido de cada pagina esta en herramientas/contenido/<clave>.html; portada,
# formacion y acceso quintino tienen su contenido en este archivo.
sub rutas_paginas {
    my %p = (
        inicio        => ['',                          'Inicio',              ''],
        laquinta      => ['la-quinta/',                'La Quinta',           'La Quinta'],
        historia      => ['historia/',                 'Historia',            'La Quinta'],
        cuartel       => ['cuartel/',                  'Cuartel',             'La Quinta'],
        cbt           => ['cuerpo-de-bomberos/',        'Cuerpo de Bomberos',  'La Quinta'],
        confederacion => ['confederacion/',            'Confederación',       'La Quinta'],
        dotacion      => ['dotacion/',                 'Dotación',            'Dotación'],
        formacion     => ['formacion/',                'Formación',           'Formación'],
        # Paginas retiradas del sitio: solo se llega a ellas desde el enlace ARCHIVO del pie
        archivo       => ['archivo/',                  'Archivo',             ''],
        trabajo       => ['archivo/nuestro-trabajo/',  'Nuestro Trabajo',     'Archivo'],
        capacitacion  => ['archivo/capacitacion/',     'Capacitación',        'Archivo'],
        guardia       => ['archivo/guardia-nocturna/', 'Guardia Nocturna',    'Archivo'],
        redes         => ['archivo/redes-sociales/',   'Redes Sociales',      'Archivo'],
        directorio    => ['archivo/directorio/',       'Directorio',          'Archivo'],
        socios        => ['archivo/socios-colaboradores/', 'Socios Colaboradores', 'Archivo'],
        acceso        => ['acceso-quintino/',          'Acceso Quintino',     ''],
        calendario    => ['acceso-quintino/calendario/', 'Calendario de cumpleaños', 'Acceso Quintino'],
        postula       => ['postula/',                   'Postula a la Quinta', ''],
        gracias       => ['postula/gracias/',           '¡Gracias por postular!', ''],
        enviado       => ['contacto/gracias/',          '¡Mensaje enviado!',  ''],
        material      => ['material-mayor/',           'Material Mayor',      'La Quinta'],
        bx5           => ['material-mayor/bx-5/',      'Unidad BX-5',         'La Quinta'],
        b5            => ['material-mayor/b-5/',       'Unidad B-5',          'La Quinta'],
        harbor        => ['material-mayor/harbor-28/', 'Unidad Harbor 28',    'La Quinta'],
        gallo         => ['material-mayor/gallo-1908/', 'Gallo, 1908', 'La Quinta'],
        beduwe        => ['material-mayor/usines-beduwe-1911/', 'Usines Beduwé «Bomba Chile», 1911', 'La Quinta'],
        hansa         => ['material-mayor/hansa-lloyd-1927/', 'Hansa Lloyd Bomba Flanders, 1927', 'La Quinta'],
        ford          => ['material-mayor/ford-champion-1941/', 'Ford Bomba Champion, 1941', 'La Quinta'],
        berliet       => ['material-mayor/berliet-camiva-1973/', 'Berliet-Camiva, 1973', 'La Quinta'],
        magirus       => ['material-mayor/magirus-deutz-1954/', 'Magirus Deutz, 1954', 'La Quinta'],
        s170          => ['material-mayor/renault-camiva-s-170-1990/', 'Renault Camiva S-170, 1990', 'La Quinta'],
        b110          => ['material-mayor/renault-camiva-b-110-1994/', 'Renault Camiva B-110, 1994', 'La Quinta'],
        s150          => ['material-mayor/renault-camiva-s-150-1999/', 'Renault Camiva S-150, 1999', 'La Quinta'],
        contacto      => ['contacto/',                 'Contacto',            'Contacto'],
    );
    return map { $_ => { ruta => $p{$_}[0], titulo => $p{$_}[1], seccion => $p{$_}[2],
                         descripcion => $DESCRIPCIONES{$_} // $DESCRIPCION } } keys %p;
}

my $WEBMAIL = 'https://mail.google.com/a/funfte.cl/';
my $COOPERADORES = 'https://5thno.cooperadores.cl/enrolamiento';
my $SOAP    = 'https://soapbomberos.cl/donacion/5-cia-talcahuano';
my $AULA    = 'https://aula.anb.cl/moodle/login/index.php';
my $ANB     = 'https://www.anb.cl';

# Pagina "Acceso Quintino": [titulo, detalle, enlace, icono] (sin enlace = pronto).
# @ACCESOS son las plataformas internas; @SITIOS, sitios institucionales de interes.
my @ACCESOS = (
    ['Webmail',                          'Correo electrónico institucional @funfte.cl mediante la plataforma de Google.', $WEBMAIL, 'correo'],
    ['SISPAR',                           'Plataforma de registro y control: administración y gestión interna de bomberos.', 'https://sispar.sisparnovenacbt.com/login.php', 'sisab'],
    ['Registro Nacional de Bomberos',    'Acceso RNB a los sistemas de la Junta Nacional de Bomberos.', 'https://www.bomberos.cl/sist/escritorio_virtual/', 'documento'],
);
my @SITIOS = (
    ['Cuerpo de Bomberos de Talcahuano', 'Sitio oficial del Cuerpo de Bomberos de Talcahuano.', 'https://cbt.cl', 'web'],
    ['Bomberos de Chile',                'Sitio de la Junta Nacional de Cuerpos de Bomberos de Chile.', 'https://www.bomberos.cl', 'web'],
);

my @MENU = (
    ['Inicio', ''],
    ['La Quinta', 'la-quinta/', [['Historia','historia/'], ['Cuartel','cuartel/'], ['Material Mayor','material-mayor/'], ['Cuerpo de Bomberos','cuerpo-de-bomberos/'], ['Confederación','confederacion/']]],
    ['Dotación', 'dotacion/', [['Oficialidad','dotacion/#oficialidad'], ['Dotación completa','dotacion/#dotacion-completa']]],
    ['Formación', 'formacion/'],
    ['Contacto', 'contacto/'],
);

my %ICONOS = (
    redes    => 'M18 16a3 3 0 0 0-2.4 1.2l-6.7-3.4a3 3 0 0 0 0-1.6l6.7-3.4A3 3 0 1 0 15 7l-6.7 3.4a3 3 0 1 0 0 3.2L15 17a3 3 0 1 0 3-1z',
    sisab    => 'M12 2 4 5v6c0 5 3.4 9.7 8 11 4.6-1.3 8-6 8-11V5l-8-3zm-1 14-4-4 1.4-1.4L11 13.2l4.6-4.6L17 10l-6 6z',
    correo   => 'M3 5h18v14H3V5zm2 2v.5l7 4.5 7-4.5V7H5zm14 2.9-7 4.5-7-4.5V17h14V9.9z',
    libro    => 'M5 3h11a3 3 0 0 1 3 3v15H7a2 2 0 0 1-2-2V3zm2 14v2h10v-2H7zm0-12v10h10V6a1 1 0 0 0-1-1H7z',
    corazon  => 'M12 21s-7.5-4.6-9.5-9.3C1.2 8.6 3.2 5 6.7 5c2 0 3.4 1 4.3 2.4h2C13.9 6 15.3 5 17.3 5c3.5 0 5.5 3.6 4.2 6.7C19.5 16.4 12 21 12 21z',
    auto     => 'M18.9 6c-.2-.6-.8-1-1.4-1h-11c-.7 0-1.2.4-1.4 1L3 12v8c0 .6.4 1 1 1h1c.6 0 1-.4 1-1v-1h12v1c0 .6.4 1 1 1h1c.6 0 1-.4 1-1v-8l-2.1-6zM6.5 16c-.8 0-1.5-.7-1.5-1.5S5.7 13 6.5 13s1.5.7 1.5 1.5S7.3 16 6.5 16zm11 0c-.8 0-1.5-.7-1.5-1.5s.7-1.5 1.5-1.5 1.5.7 1.5 1.5-.7 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z',
    birrete  => 'M12 3 1 9l11 6 9-4.9V17h2V9L12 3zM5 13.2V17c0 1.7 3.1 3 7 3s7-1.3 7-3v-3.8l-7 3.8-7-3.8z',
    convoca  => 'M7 2h2v2h6V2h2v2h3v18H4V4h3V2zm-1 8v10h12V10H6zm2 2h3v3H8v-3z',
    documento=> 'M6 2h8l6 6v14H6V2zm7 1.5V9h5.5L13 3.5zM8 12v2h8v-2H8zm0 4v2h8v-2H8z',
    web      => 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm6.9 6h-3a15 15 0 0 0-1.3-3.9A8 8 0 0 1 18.9 8zM12 4c.8 1.1 1.5 2.5 1.9 4h-3.8c.4-1.5 1.1-2.9 1.9-4zM4.3 14a8 8 0 0 1 0-4h3.4a16 16 0 0 0 0 4H4.3zm.8 2h3a15 15 0 0 0 1.3 3.9A8 8 0 0 1 5.1 16zm3-8h-3a8 8 0 0 1 4.3-3.9C8.7 5.3 8.3 6.6 8.1 8zM12 20c-.8-1.1-1.5-2.5-1.9-4h3.8c-.4 1.5-1.1 2.9-1.9 4zm2.3-6H9.7a14 14 0 0 1 0-4h4.6a14 14 0 0 1 0 4zm.3 5.9a15 15 0 0 0 1.3-3.9h3a8 8 0 0 1-4.3 3.9zM16.3 14a16 16 0 0 0 0-4h3.4a8 8 0 0 1 0 4h-3.4z',
    torta    => 'M12 2c1 1.3 1.5 2.3 1.5 3a1.5 1.5 0 0 1-3 0c0-.7.5-1.7 1.5-3zm-1 5h2v3h5a2 2 0 0 1 2 2v2.5c-1 0-1.5-.8-2.5-.8s-1.5.8-2.5.8-1.5-.8-2.5-.8-1.5.8-2.5.8-1.5-.8-2.5-.8-1.5.8-2.5.8V12a2 2 0 0 1 2-2h5V7zm-7 9c1 0 1.5-.8 2.5-.8s1.5.8 2.5.8 1.5-.8 2.5-.8 1.5.8 2.5.8 1.5-.8 2.5-.8 1.5.8 2.5.8V22H4v-6z',
    candado  =>'M12 2a5 5 0 0 1 5 5v3h2v12H5V10h2V7a5 5 0 0 1 5-5zm0 2a3 3 0 0 0-3 3v3h6V7a3 3 0 0 0-3-3zm0 9a2 2 0 0 0-1 3.7V19h2v-2.3A2 2 0 0 0 12 13z',
);

sub icono { qq(<svg viewBox="0 0 24 24" aria-hidden="true"><path d="$ICONOS{$_[0]}"/></svg>) }

sub externo { $_[0] =~ /^https?:/ }

sub enlace {
    my ($p, $ruta) = @_;
    return externo($ruta)        ? qq(href="$ruta" target="_blank" rel="noopener")
         : $ruta =~ /^mailto:/   ? qq(href="$ruta")
         :                         qq(href="$p$ruta");
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
<p class="aviso">En construcción</p>
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
<div class="destacado">
) . icono('torta') . qq(
<div>
<h2>Calendario de cumpleaños</h2>
<p>Aniversarios de las compañías del Cuerpo y de la Confederación, listo para mostrar en pantalla completa en el cuartel.</p>
</div>
<a class="boton" href="${p}acceso-quintino/calendario/">Ver calendario</a>
</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Accesos administrativos</h2>
<div class="grilla-tarjetas tres">
);
    $h .= tarjeta($p, $_->[3], $_->[0], $_->[1], $_->[2], 'Ingresar') for @ACCESOS;
    $h .= qq(</div>\n</section>\n<section class="wrap bloque">\n<h2 class="titulo-seccion">Sitios de interés</h2>\n<div class="grilla-tarjetas tres">\n);
    $h .= tarjeta($p, $_->[3], $_->[0], $_->[1], $_->[2], 'Visitar') for @SITIOS;
    return $h . "</div>\n</section>";
}

# Aniversarios de las companias del Cuerpo y de la Confederacion, sacados de sus tarjetas
# (h4, «Fundada el ...» y escudo). La portada los incluye y menu.js muestra el saludo del dia.
my %MESES = (enero => 1, febrero => 2, marzo => 3, abril => 4, mayo => 5, junio => 6, julio => 7,
             agosto => 8, septiembre => 9, octubre => 10, noviembre => 11, diciembre => 12);
sub aniversarios {
    my ($p) = @_;
    my (@lista, %visto);
    for my $archivo ('cbt', 'confederacion') {
        open my $fh, '<:utf8', "$FindBin::Bin/contenido/$archivo.html" or next;
        local $/;
        my $html = <$fh>;
        while ($html =~ m{<article class="cia">(.*?)</article>}gs) {
            my $t = $1;
            my ($nombre) = $t =~ m{<h4>(.*?)</h4>} or next;
            my ($dia, $mes, $anio) = $t =~ /Fundada el (\d+) de (\w+) de (\d{4})/ or next;
            next if $nombre =~ /«Bomba Chile»/ || $visto{$nombre}++;    # la Quinta: es nuestro propio aniversario
            $nombre =~ s/^(\d+ª) /$1 Compañía /;
            $nombre .= ' de Talcahuano' if $archivo eq 'cbt';
            my ($escudo) = $t =~ m{<img src="\.\./(assets/img/[^"]+)"};
            my ($enlace) = $t =~ m{<a href="(https://www\.instagram\.com/[^"]+)"};
            ($enlace) = $t =~ m{<a href="(https?://[^"]+)"} unless $enlace;
            push @lista, { nombre => $nombre, dia => $dia, mes => $MESES{$mes}, anio => $anio,
                           ($escudo ? (escudo => "$p$escudo") : ()), ($enlace ? (enlace => $enlace) : ()) };
        }
    }
    my @quinta = (1908, 1, 29);
    push @lista, { nombre => 'la Quinta', propia => 1, anio => $quinta[0], mes => $quinta[1], dia => $quinta[2],
                   escudo => "${p}assets/img/escudo-quinta.png" };
    return json([ sort { $a->{mes} <=> $b->{mes} || $a->{dia} <=> $b->{dia} } @lista ]);
}

sub inicio {
    my ($p) = @_;
    my $aniversarios = aniversarios($p);
    my $portada = '2011-12-DSC0103-1030x688.jpg';
    my $escudo  = '2013-04-Sin-titulo-3.png';
    return
qq(<section class="portada" style="background-image:url('${p}assets/img/$portada')">
<div class="wrap">
<p class="antetitulo">Fünfte Deutsche Feuerwehrkompanie Talcahuano</p>
<h1><span>Quinta Compañía de Bomberos</span> <span>«Bomba Chile» de Talcahuano</span></h1>
<p class="bajada">Fundada el 29 de enero de 1908. Especialidad en agua y rescate integral al servicio de Talcahuano.</p>
<div class="acciones"><a class="boton" href="${p}la-quinta/">Conoce la Quinta</a><a class="boton secundario" href="$REDES[0][1]" target="_blank" rel="noopener">Síguenos en Instagram</a></div>
</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">La Quinta</h2>
<div class="grilla-tarjetas tres">
) . tarjeta($p, 'sisab', 'Postula a la Quinta', '¿Quieres ser bombero voluntario? Únete a la Quinta y sirve a Talcahuano. Completa el formulario y te contactaremos.', 'postula/', 'Postular')
  . tarjeta($p, 'corazon', 'Hazte socio', 'Colabora con la Quinta y hazte socio cooperador. Con tu ayuda continuaremos salvando vidas.', $COOPERADORES, 'Inscríbete')
  . tarjeta($p, 'auto', 'Compra tu SOAP', 'Compra tu SOAP con Bomberos de Chile y elige a la Quinta: tu donación va directamente a nuestra compañía.', $SOAP, 'Comprar SOAP')
  . qq(</div>
</section>
<section class="wrap saludos" id="saludos" hidden></section>
<script type="application/json" id="aniversarios">$aniversarios</script>
<section class="lema">
<div class="wrap">
<img src="${p}assets/img/$escudo" alt="" loading="lazy">
<blockquote><p lang="de">«Gott zur Ehr, dem Nächsten zur Wehr»</p><p>«En honor a Dios y ayuda del prójimo»</p></blockquote>
<p class="anios">29 - 01 - 1908</p>
</div>
</section>);
}

# Calendario de cumpleaños para la pantalla del cuartel (Acceso Quintino). calendario.js
# lo arma con los mismos datos del saludo de la portada y lo actualiza solo cada minuto.
sub calendario {
    my ($p) = @_;
    my $aniversarios = aniversarios($p);
    return qq(<section class="wrap bloque">
<p class="intro">Aniversarios de las compañías del Cuerpo de Bomberos de Talcahuano y de la Confederación. Para mostrarlo en una pantalla del cuartel, presiona <strong>Pantalla completa</strong>; se actualiza solo cada día.</p>
<p><button class="boton" type="button" id="pantalla-completa">Pantalla completa</button></p>
</section>
<section class="wrap bloque">
<div class="pantalla" id="pantalla">
<header class="pantalla-cabecera">
<img src="${p}assets/img/escudo-quinta.png" alt="">
<div><p class="pantalla-titulo">Cumpleaños</p><p class="pantalla-fecha" id="pantalla-fecha"></p></div>
<p class="pantalla-hora" id="pantalla-hora"></p>
</header>
<div class="pantalla-cuerpo">
<section class="pantalla-hoy" id="pantalla-hoy" aria-live="polite"></section>
<section class="pantalla-proximos"><h2>Próximos</h2><ol id="pantalla-proximos"></ol></section>
</div>
</div>
</section>
<script type="application/json" id="aniversarios">$aniversarios</script>
<script src="${p}assets/js/calendario.js$V_CAL" defer></script>);
}

sub formacion {
    my ($p) = @_;
    return
qq(<section class="wrap bloque">
<p class="intro">La formación permanente es uno de los pilares de la Quinta. Aquí reunimos los accesos a las plataformas de capacitación de la Academia Nacional de Bomberos (ANB) y otros recursos de estudio para nuestros voluntarios.</p>
<div class="destacado">
) . icono('convoca') . qq(
<div>
<h2>Convocatorias para Bomberos</h2>
<p>Cursos abiertos y fechas de postulación de la Academia Nacional de Bomberos.</p>
</div>
<a class="boton" href="$ANB/convocatorias-para-bomberos" target="_blank" rel="noopener">Ver convocatorias</a>
</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Academia Nacional de Bomberos</h2>
<div class="grilla-tarjetas tres">
) . tarjeta($p, 'web', 'Aula Virtual ANB', 'Plataforma de cursos en línea. Ingresa con tu usuario del Registro Nacional de Bomberos.', $AULA, 'Entrar al aula virtual')
  . tarjeta($p, 'birrete', 'Malla curricular', 'Malla curricular 2025–2028 de la Academia Nacional de Bomberos (PDF).', "$ANB/documentos_sitio/43775_Malla_curricular_2025_2028.pdf", 'Ver malla')
  . tarjeta($p, 'documento', 'Material académico', 'Manuales y material de apoyo para los cursos de la Academia.', "$ANB/material-academico", 'Ver material')
  . tarjeta($p, 'libro', 'Guías de autoinstrucción', 'Guías para estudiar de forma autónoma antes de cada curso.', "$ANB/guias-de-autoinstruccion", 'Ver guías')
  . tarjeta($p, 'documento', 'Artículos técnicos', 'Publicaciones técnicas para la actualización de conocimientos.', "$ANB/articulos-tecnicos", 'Ver artículos')
  . qq(</div>
</section>
<section class="wrap bloque">
<h2 class="titulo-seccion">Más recursos</h2>
<div class="grilla-tarjetas tres">
) . tarjeta($p, 'libro', 'Bibliotecas de Bomberos de Chile', 'Publicaciones, revistas y documentos de la Junta Nacional de Bomberos.', 'https://www.bomberos.cl/bibliotecas', 'Ir a bibliotecas')
  . tarjeta($p, 'candado', 'Biblioteca Virtual de la Quinta', 'Material de trabajo interno, oficios y manuales operativos de la compañía.')
  . qq(</div>
</section>);
}

# Formulario de postulacion. El sitio es estatico: FormSubmit (formsubmit.co) recibe
# los datos y los envia por correo a funfteit@gmail.com con copia a correo@funfte.cl.
# FormSubmit pide activar una vez la direccion principal (correo a funfteit@gmail.com).
my $POSTULACION_PARA = 'funfteit@gmail.com';
my $POSTULACION_CC   = 'correo@funfte.cl';

sub postula {
    my ($p) = @_;
    return qq(<section class="wrap bloque">
<p class="intro">¿Quieres ser bombero voluntario? Déjanos tus datos y la Quinta se pondrá en contacto contigo para contarte cómo es el proceso de ingreso.</p>
<form class="formulario" action="https://formsubmit.co/$POSTULACION_PARA" method="POST">
<input type="hidden" name="_subject" value="Nueva postulación a la Quinta">
<input type="hidden" name="_cc" value="$POSTULACION_CC">
<input type="hidden" name="_template" value="table">
<input type="hidden" name="_next" value="${SITIO}postula/gracias/">
<input type="text" name="_honey" class="oculto" tabindex="-1" autocomplete="off" aria-hidden="true">
<label for="nombre">Nombre completo</label>
<input id="nombre" name="Nombre" type="text" autocomplete="name" required>
<label for="rut">RUT</label>
<input id="rut" name="RUT" type="text" inputmode="text" autocomplete="off" maxlength="12" placeholder="12.345.678-9" pattern="[0-9]{1,2}\.[0-9]{3}\.[0-9]{3}-[0-9K]" title="RUT con dígito verificador, por ejemplo 12.345.678-9" data-rut required>
<label for="nacimiento">Fecha de nacimiento</label>
<input id="nacimiento" name="Fecha de nacimiento" type="date" required>
<label for="correo">Correo electrónico</label>
<input id="correo" name="email" type="email" autocomplete="email" required>
<label for="telefono">Teléfono</label>
<div class="telefono"><span aria-hidden="true">+56</span><input id="telefono" name="Teléfono (+56)" type="tel" inputmode="numeric" autocomplete="tel-national" maxlength="11" pattern="[0-9] [0-9]{4} [0-9]{4}" placeholder="9 1234 5678" title="9 dígitos, sin el +56. Por ejemplo: 9 1234 5678" data-telefono aria-describedby="telefono-ayuda" required></div>
<p id="telefono-ayuda" class="campo-ayuda">9 dígitos.</p>
<label for="referencia">¿Cómo conociste a la Quinta? ¿Alguien te recomendó?</label>
<textarea id="referencia" name="Cómo conoció a la Quinta / referencia" rows="3" placeholder="Por ejemplo: un amigo voluntario, redes sociales, un evento de la compañía…" required></textarea>
<button class="boton" type="submit">Enviar postulación</button>
<p class="formulario-ayuda">Usaremos tus datos solo para contactarte por tu postulación. ¿Dudas? Escríbenos a <a href="mailto:correo\@funfte.cl">correo\@funfte.cl</a>.</p>
</form>
</section>);
}

sub gracias {
    my ($p, $texto) = @_;
    return qq(<section class="wrap bloque">
<p class="intro">$texto</p>
<p><a class="boton" href="$p">Volver a la portada</a></p>
</section>);
}

# Formulario de Contacto: tambien por FormSubmit, a la misma direccion principal ($POSTULACION_PARA).
# Se inserta en herramientas/contenido/contacto.html donde esta <!--FORMULARIO_CONTACTO-->.
my $CONTACTO_CC = 'correo@funfte.cl';

sub formulario_contacto {
    return qq(<form class="formulario" action="https://formsubmit.co/$POSTULACION_PARA" method="POST">
<input type="hidden" name="_subject" value="Nuevo mensaje desde funfte.cl">
<input type="hidden" name="_cc" value="$CONTACTO_CC">
<input type="hidden" name="_template" value="table">
<input type="hidden" name="_next" value="${SITIO}contacto/gracias/">
<input type="text" name="_honey" class="oculto" tabindex="-1" autocomplete="off" aria-hidden="true">
<label for="c-nombre">Nombre</label>
<input id="c-nombre" name="Nombre" type="text" autocomplete="name" required>
<label for="c-correo">Correo electrónico</label>
<input id="c-correo" name="email" type="email" autocomplete="email" required>
<label for="c-telefono">Teléfono</label>
<div class="telefono"><span aria-hidden="true">+56</span><input id="c-telefono" name="Teléfono (+56)" type="tel" inputmode="numeric" autocomplete="tel-national" maxlength="11" pattern="[0-9] [0-9]{4} [0-9]{4}" placeholder="9 1234 5678" title="9 dígitos, sin el +56. Por ejemplo: 9 1234 5678" data-telefono aria-describedby="c-telefono-ayuda"></div>
<p id="c-telefono-ayuda" class="campo-ayuda">9 dígitos.</p>
<label for="c-mensaje">Mensaje</label>
<textarea id="c-mensaje" name="Mensaje" rows="5" required></textarea>
<button class="boton" type="submit">Enviar mensaje</button>
</form>);
}

sub archivo {
    my ($p) = @_;
    my %pg = rutas_paginas();
    my @retiradas = sort { $a->{titulo} cmp $b->{titulo} } grep { $_->{seccion} eq 'Archivo' } values %pg;
    my $h = qq(<article class="wrap contenido">\n<p>Páginas retiradas del sitio. Se conservan aquí como referencia.</p>\n<ul>\n);
    $h .= qq(<li><a href="$p$_->{ruta}">$_->{titulo}</a></li>\n) for @retiradas;
    return $h . "</ul>\n</article>";
}

# Resumen de la dotacion en cifras: cuenta los nombres de cada lista "Voluntarios ..."
# de la pagina, asi el resumen nunca queda desactualizado al agregar o quitar voluntarios.
sub cifras_dotacion {
    my ($html) = @_;
    my $h = qq(<ul class="cifras">\n);
    while ($html =~ m{<h3>Voluntarios (\w+)</h3>\s*<ol[^>]*>(.*?)</ol>}gs) {
        my ($tipo, $lista) = (ucfirst $1, $2);
        my $n = () = $lista =~ /<li\b/g;
        $h .= qq(<li><strong>$n</strong>$tipo</li>\n);
    }
    return $h . '</ul>';
}

# Enlace canonico, Open Graph y Twitter Card: titulo, texto e imagen que muestran
# Google, WhatsApp y Facebook. La imagen es la primera foto del contenido o la portada.
sub meta_compartir {
    my %a = @_;
    my $url = $SITIO . $a{ruta};
    my ($foto) = ($a{contenido} // '') =~ m{assets/img/([^"']+\.(?:jpe?g|png))}i;
    my $imagen = $SITIO . 'assets/img/' . ($foto // '2011-12-DSC0103-1030x688.jpg');
    my $titulo = $a{clave} eq 'inicio' ? $NOMBRE : $a{titulo_completo};
    return qq(
<link rel="canonical" href="$url">
<meta property="og:type" content="website">
<meta property="og:site_name" content="$NOMBRE">
<meta property="og:locale" content="es_CL">
<meta property="og:title" content="$titulo">
<meta property="og:description" content="$a{descripcion}">
<meta property="og:url" content="$url">
<meta property="og:image" content="$imagen">
<meta property="og:image:alt" content="$titulo">
<meta name="twitter:card" content="summary_large_image">);
}

# JSON sin modulos externos; claves ordenadas para que la salida no cambie entre generaciones
sub json {
    my ($v) = @_;
    return '{' . join(',', map { json_texto($_) . ':' . json($v->{$_}) } sort keys %$v) . '}' if ref $v eq 'HASH';
    return '[' . join(',', map { json($_) } @$v) . ']' if ref $v eq 'ARRAY';
    return $v =~ /^-?\d+(?:\.\d+)?$/ ? $v : json_texto($v);
}
sub json_texto { my $t = shift; $t =~ s/(["\\])/\\$1/g; $t =~ s{</}{<\\/}g; return qq("$t") }

# Datos estructurados (schema.org) para Google: la compania en portada y Contacto, y la
# ruta de migas (Inicio > La Quinta > Historia) en el resto de las paginas publicas.
sub datos_estructurados {
    my %a = @_;
    my $org = "${SITIO}#organizacion";
    my @datos;
    if ($a{clave} eq 'inicio' || $a{clave} eq 'contacto') {
        push @datos, {
            '@type' => 'FireStation', '@id' => $org, name => $NOMBRE,
            alternateName => ['Bomba Chile', 'Fünfte Deutsche Feuerwehrkompanie Talcahuano'],
            url => $SITIO, logo => "${SITIO}assets/img/escudo-quinta.png",
            image => "${SITIO}assets/img/2011-12-DSC0103-1030x688.jpg",
            description => $DESCRIPCIONES{inicio}, foundingDate => $FUNDACION, email => $CORREO,
            address => { '@type' => 'PostalAddress', streetAddress => $DIRECCION{calle},
                         addressLocality => $DIRECCION{comuna}, addressRegion => $DIRECCION{region},
                         addressCountry => $DIRECCION{pais} },
            geo => { '@type' => 'GeoCoordinates', latitude => $COORDENADAS[0], longitude => $COORDENADAS[1] },
            sameAs => [map { $_->[1] } @REDES],
            parentOrganization => { '@type' => 'Organization', name => 'Cuerpo de Bomberos de Talcahuano', url => 'https://cbt.cl' },
            memberOf => { '@type' => 'Organization', name => 'Confederación de Compañías Chileno-Alemanas de Bomberos',
                          url => "${SITIO}confederacion/" },
        };
    }
    if ($a{clave} eq 'inicio') {
        push @datos, { '@type' => 'WebSite', name => $NOMBRE, url => $SITIO, inLanguage => 'es-CL',
                       publisher => { '@id' => $org } };
    } else {
        # migas: la seccion del menu y cada carpeta de la ruta que sea una pagina
        my %pg = rutas_paginas();
        my %por_ruta = map { $_->{ruta} => $_ } values %pg;
        my ($seccion) = grep { $_->{titulo} eq ($a{seccion} // '') } values %pg;
        my @rutas = ('', $seccion ? $seccion->{ruta} : ());
        my $acumulada = '';
        push @rutas, $acumulada .= $_ for $a{ruta} =~ m{([^/]+/)}g;
        my %visto;
        my @migas = grep { !$visto{$_->{ruta}}++ } map { $por_ruta{$_} // () } @rutas;
        my $n = 0;
        push @datos, { '@type' => 'BreadcrumbList', itemListElement => [ map { {
            '@type' => 'ListItem', position => ++$n, name => $_->{titulo}, item => $SITIO . $_->{ruta} } } @migas ] };
    }
    return join '', map { qq(\n<script type="application/ld+json">) . json({ '@context' => 'https://schema.org', %$_ }) . '</script>' } @datos;
}

sub pagina {
    my %a = @_;
    # la pagina 404 se sirve en cualquier direccion: usa rutas absolutas
    my $p = $a{prefijo} // '../' x ($a{ruta} =~ tr{/}{});
    my $es_inicio = $a{clave} eq 'inicio';
    my $titulo = $es_inicio ? "$NOMBRE | Fünfte Deutsche Feuerwehrkompanie" : "$a{titulo} | $NOMBRE";
    my $cabecera = qq(<section class="cabecera-pagina"><div class="wrap">)
        . ($a{seccion} && $a{seccion} ne $a{titulo} ? qq(<p class="antetitulo">$a{seccion}</p>) : '')
        . qq(<h1>$a{titulo}</h1></div></section>\n);
    my $cuerpo = $es_inicio                 ? inicio($p)
               : $a{clave} eq 'formacion'   ? $cabecera . formacion($p)
               : $a{clave} eq 'acceso'      ? $cabecera . acceso_personal($p)
               : $a{clave} eq 'calendario'  ? $cabecera . calendario($p)
               : $a{clave} eq 'archivo'     ? $cabecera . archivo($p)
               : $a{clave} eq 'postula'     ? $cabecera . postula($p)
               : $a{clave} eq 'gracias'     ? $cabecera . gracias($p, 'Recibimos tu postulación. La Quinta se pondrá en contacto contigo por correo o teléfono.')
               : $a{clave} eq 'enviado'     ? $cabecera . gracias($p, 'Recibimos tu mensaje. Te responderemos a la brevedad por correo.')
               : $cabecera . qq(<article class="wrap contenido">\n) . ($a{contenido} =~ s/<!--FORMULARIO_CONTACTO-->/formulario_contacto()/er
                                                                        =~ s/<!--CIFRAS_DOTACION-->/cifras_dotacion($a{contenido})/er) . qq(\n</article>);
    # en la 404 ningun item del menu queda marcado como actual
    my $menu = menu($p, $a{clave} eq 'error404' ? '-' : $a{ruta}, $a{seccion});
    my $acceso_actual = $a{clave} eq 'acceso' ? ' aria-current="page"' : '';
    my $candado = icono('candado');
    my $anio = (localtime)[5] + 1900;
    my $descripcion = $a{descripcion} // $DESCRIPCION;
    # el archivo y la pagina 404 no deben aparecer en buscadores
    my $indexable = $a{ruta} !~ m{^archivo/} && $a{clave} !~ /^(?:error404|gracias|enviado|calendario)$/;
    my $meta = $indexable ? meta_compartir(%a, titulo_completo => $titulo, descripcion => $descripcion) . datos_estructurados(%a)
                          : qq(\n<meta name="robots" content="noindex">);
    my $redes = join "\n", map { qq(<li><a href="$_->[1]" target="_blank" rel="noopener">$_->[0]</a></li>) } @REDES;
    return <<"HTML";
<!doctype html>
<html lang="es-CL">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$titulo</title>
<meta name="description" content="$descripcion">$meta
<link rel="icon" href="${p}favicon.ico">
<link rel="stylesheet" href="${p}assets/css/estilos.css$V_CSS">
<script src="${p}assets/js/menu.js$V_JS" defer></script>
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
<p>Río Maule 5383, Villa Independencia<br>Sector Denavi Sur, Talcahuano, Chile</p>
</div>
<div>
<h2>Comunícate</h2>
<p><a href="mailto:$CORREO">$CORREO</a></p>
<ul class="pie-enlaces">
$redes
</ul>
</div>
<div>
<h2>Enlaces</h2>
<ul class="pie-enlaces">
<li><a href="${p}contacto/">Contacto</a></li>
<li><a href="https://cbt.cl" target="_blank" rel="noopener">Cuerpo de Bomberos de Talcahuano</a></li>
<li><a href="${p}archivo/">Archivo</a></li>
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
