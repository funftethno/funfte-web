#!/usr/bin/perl
# Crea las miniaturas de 640 px de ancho de las fotos de las tarjetas de Material Mayor
# (la primera foto de cada unidad) en assets/img/mini/. Las tarjetas las usan en vez de la
# foto completa para que las paginas carguen mas rapido; si falta una, usan la foto completa.
#
# Uso (desde la raiz del repositorio):  perl herramientas/miniaturas.pl
# Necesita ffmpeg. Solo crea las que faltan o cuya foto cambio despues; borra las que sobran.
# Despues ejecuta perl herramientas/generar.pl para que las paginas las usen.
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use plantilla qw(fotos_tarjetas);

my $IMG  = "$FindBin::Bin/../assets/img";
my $MINI = "$IMG/mini";
mkdir $MINI unless -d $MINI;

my %fotos = map { $_ => 1 } grep { /\.(?:jpe?g|png)$/i && -e "$IMG/$_" } fotos_tarjetas();
for my $foto (sort keys %fotos) {
    my ($origen, $destino) = ("$IMG/$foto", "$MINI/$foto");
    next if -e $destino && -M $destino <= -M $origen;
    system('ffmpeg', '-nostdin', '-v', 'error', '-y', '-i', $origen,
           '-vf', "scale='min(640,iw)':-2", '-q:v', '4', $destino) == 0
        or die "No se pudo crear la miniatura de $foto (¿esta instalado ffmpeg?)\n";
    # una foto que ya es chica no gana nada: se usa tal cual
    if (-s $destino > 0.8 * -s $origen) {
        unlink $destino;
        delete $fotos{$foto};
        next;
    }
    print "  -> assets/img/mini/$foto\n";
}

opendir my $dir, $MINI or die "$MINI: $!";
for my $mini (grep { !/^\./ && !$fotos{$_} } readdir $dir) {
    unlink "$MINI/$mini";
    print "  borrada assets/img/mini/$mini\n";
}
closedir $dir;
print "Listo.\n";
