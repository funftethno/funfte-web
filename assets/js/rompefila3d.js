// Visor 3D del rompefila (Recuerdos). menu.js carga este módulo al tocar «Ver en 3D».
// La placa es el contorno del escudo (sacado de la foto de estudio) extruido con su grosor:
// la foto del frente va adelante y la del reverso, espejada, atrás. Usa three.js r160
// alojado en assets/js/vendor/ (la política de seguridad del sitio solo permite scripts propios).
import * as THREE from './vendor/three.module.min.js';

// Contorno del escudo en coordenadas de la textura (u, v de 0 a 1), recorrido en un solo sentido
const CONTORNO = [0.1674,1.0,0.1145,0.9885,0.1079,0.977,0.1057,0.9655,0.1013,0.954,0.0925,0.9425,0.0837,0.931,0.0683,0.9195,0.0419,0.908,0.0154,0.8966,0.0088,0.8851,0.0066,0.8736,0.0044,0.8621,0.0044,0.8506,0.0022,0.8391,0.0022,0.8276,0.0022,0.8161,0.0,0.8046,0.0,0.7931,0.0,0.7816,0.0,0.7701,0.0,0.7586,0.0,0.7471,0.0,0.7356,0.0022,0.7241,0.0022,0.7126,0.0022,0.7011,0.0044,0.6897,0.0044,0.6782,0.0066,0.6667,0.0088,0.6552,0.011,0.6437,0.0132,0.6322,0.0154,0.6207,0.0176,0.6092,0.0198,0.5977,0.0286,0.5862,0.0264,0.5747,0.0308,0.5632,0.0352,0.5517,0.0374,0.5402,0.0419,0.5287,0.0463,0.5172,0.0507,0.5057,0.0551,0.4943,0.0617,0.4828,0.0661,0.4713,0.0727,0.4598,0.0749,0.4483,0.0793,0.4368,0.0837,0.4253,0.0903,0.4138,0.0969,0.4023,0.1035,0.3908,0.1101,0.3793,0.1167,0.3678,0.1233,0.3563,0.13,0.3448,0.1366,0.3333,0.1454,0.3218,0.152,0.3103,0.1608,0.2989,0.1696,0.2874,0.1784,0.2759,0.1872,0.2644,0.196,0.2529,0.2048,0.2414,0.2137,0.2299,0.2247,0.2184,0.2335,0.2069,0.2445,0.1954,0.2555,0.1839,0.2709,0.1724,0.2819,0.1609,0.293,0.1494,0.3062,0.1379,0.3172,0.1264,0.3304,0.1149,0.3436,0.1034,0.3568,0.092,0.3678,0.0805,0.3855,0.069,0.3987,0.0575,0.4141,0.046,0.4339,0.0345,0.4493,0.023,0.4692,0.0115,0.4912,0.0,0.5264,0.0057,0.5485,0.0172,0.5617,0.0287,0.5815,0.0402,0.5991,0.0517,0.6123,0.0632,0.63,0.0747,0.6454,0.0862,0.6586,0.0977,0.674,0.1092,0.6894,0.1207,0.7004,0.1322,0.7137,0.1437,0.7269,0.1552,0.7379,0.1667,0.7511,0.1782,0.7599,0.1897,0.7687,0.2011,0.7841,0.2126,0.7952,0.2241,0.804,0.2356,0.815,0.2471,0.8238,0.2586,0.8304,0.2701,0.8414,0.2816,0.848,0.2931,0.8568,0.3046,0.859,0.3161,0.8722,0.3276,0.8789,0.3391,0.8877,0.3506,0.8921,0.3621,0.9009,0.3736,0.9053,0.3851,0.9119,0.3966,0.9185,0.408,0.9251,0.4195,0.9295,0.431,0.9361,0.4425,0.9405,0.454,0.9449,0.4655,0.9471,0.477,0.9515,0.4885,0.9604,0.5,0.9648,0.5115,0.967,0.523,0.9714,0.5345,0.9736,0.546,0.978,0.5575,0.9802,0.569,0.9824,0.5805,0.9846,0.592,0.989,0.6034,0.989,0.6149,0.9912,0.6264,0.9934,0.6379,0.9956,0.6494,0.9956,0.6609,0.9978,0.6724,0.9978,0.6839,0.9978,0.6954,0.9978,0.7069,1.0,0.7184,1.0,0.7299,0.9978,0.7414,0.9978,0.7529,0.9978,0.7644,0.9978,0.7759,0.9978,0.7874,0.9956,0.7989,0.9956,0.8103,0.9934,0.8218,0.9912,0.8333,0.989,0.8448,0.989,0.8563,0.9868,0.8678,0.9846,0.8793,0.978,0.8908,0.967,0.9023,0.9295,0.9138,0.9119,0.9253,0.8987,0.9368,0.8899,0.9483,0.8833,0.9598,0.8789,0.9713,0.8767,0.9828,0.8678,0.9943];
const ALTO = 1.1498;      // alto / ancho de la placa
const GROSOR = 0.035;       // en anchos de placa (unos 1,5 mm en una placa de 45 mm)
const BISEL = 0.008;

const textura = (nombre) => new URL('../img/' + nombre, import.meta.url).href;
let dialogo, lienzo, renderer, escena, camara, placa, animando = false;
let rotX = -0.12, rotY = -0.45, velY = 0, arrastrando = false, ultimo = null, quieto = 0;
const sinMovimiento = matchMedia('(prefers-reduced-motion: reduce)').matches;

export function abrir() {
  if (!dialogo) crear();
  if (!renderer) return;
  dialogo.showModal();
  ajustar();
  if (!animando) { animando = true; requestAnimationFrame(cuadro); }
}

function crear() {
  dialogo = document.createElement('dialog');
  dialogo.className = 'visor-3d';
  dialogo.setAttribute('aria-label', 'Rompefila en 3D');
  dialogo.innerHTML = '<button type="button" class="visor-cerrar" aria-label="Cerrar">×</button>'
    + '<p class="visor-ayuda">Arrastra para girar el rompefila</p>';
  document.body.append(dialogo);
  dialogo.querySelector('.visor-cerrar').addEventListener('click', () => dialogo.close());
  dialogo.addEventListener('click', (e) => { if (e.target === dialogo) dialogo.close(); });
  dialogo.addEventListener('close', () => { animando = false; });

  try {
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  } catch (e) {
    renderer = null;
    dialogo.querySelector('.visor-ayuda').textContent = 'Tu navegador no puede mostrar el modelo 3D.';
    dialogo.showModal();
    return;
  }
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  lienzo = renderer.domElement;
  dialogo.prepend(lienzo);

  escena = new THREE.Scene();
  camara = new THREE.PerspectiveCamera(28, 1, 0.1, 20);
  camara.position.set(0, 0, 3.1);

  // Entorno simple para los reflejos del metal: una sala gris con dos paneles de luz
  const pmrem = new THREE.PMREMGenerator(renderer);
  const sala = new THREE.Scene();
  const caja = new THREE.Mesh(new THREE.BoxGeometry(10, 10, 10), new THREE.MeshBasicMaterial({ color: 0x4a4744, side: THREE.BackSide }));
  sala.add(caja);
  for (const [x, y, z, s] of [[-3, 3, 3, 3], [3.5, 1, 2, 2], [0, -4, -2, 4]]) {
    const panel = new THREE.Mesh(new THREE.PlaneGeometry(s, s), new THREE.MeshBasicMaterial({ color: 0xffffff }));
    panel.position.set(x, y, z); panel.lookAt(0, 0, 0); sala.add(panel);
  }
  escena.environment = pmrem.fromScene(sala, 0.04).texture;
  const sol = new THREE.DirectionalLight(0xffffff, 1.2);
  sol.position.set(-1.5, 2, 3);
  escena.add(sol);

  // Forma del escudo centrada; el ancho mide 1
  const forma = new THREE.Shape();
  for (let i = 0; i < CONTORNO.length; i += 2) {
    const x = CONTORNO[i] - 0.5, y = (CONTORNO[i + 1] - 0.5) * ALTO;
    if (i === 0) forma.moveTo(x, y); else forma.lineTo(x, y);
  }
  const uvTapa = {
    // Tapas: la textura sigue al contorno. Atrás se achica un 2 % hacia el centro para no
    // mostrar el terciopelo del borde, porque el reverso no calza exacto con el frente.
    generateTopUV(geo, v, a, b, c) {
      return [a, b, c].map((i) => {
        const x = v[i * 3], y = v[i * 3 + 1], atras = v[i * 3 + 2] < GROSOR / 2;
        const k = atras ? 0.98 : 1;
        return new THREE.Vector2(0.5 + x * k, 0.5 + (y / ALTO) * k);
      });
    },
    generateSideWallUV() { return [0, 0, 0, 0].map(() => new THREE.Vector2(0, 0)); },
  };
  const geo = new THREE.ExtrudeGeometry(forma, {
    depth: GROSOR, bevelEnabled: true, bevelThickness: BISEL, bevelSize: BISEL, bevelSegments: 3,
    curveSegments: 2, UVGenerator: uvTapa,
  });
  geo.translate(0, 0, -GROSOR / 2);
  // ExtrudeGeometry deja las dos tapas en el grupo 0 (primero la de atrás, después la de
  // adelante) y los costados en el grupo 1: se separan para usar una foto en cada cara.
  const [tapas, costados] = geo.groups;
  geo.clearGroups();
  geo.addGroup(tapas.start, tapas.count / 2, 2);
  geo.addGroup(tapas.start + tapas.count / 2, tapas.count / 2, 0);
  geo.addGroup(costados.start, costados.count, 1);

  const cargador = new THREE.TextureLoader();
  const cargar = (nombre) => {
    const t = cargador.load(textura(nombre), () => { if (!animando) renderer.render(escena, camara); });
    t.colorSpace = THREE.SRGBColorSpace;
    t.anisotropy = renderer.capabilities.getMaxAnisotropy();
    return t;
  };
  placa = new THREE.Mesh(geo, [
    new THREE.MeshStandardMaterial({ map: cargar('rompefila-3d-frente.jpg'), roughness: 0.32, metalness: 0.15 }),
    new THREE.MeshStandardMaterial({ color: 0xc9c4ba, roughness: 0.28, metalness: 0.95 }),
    new THREE.MeshStandardMaterial({ map: cargar('rompefila-3d-reverso.jpg'), roughness: 0.4, metalness: 0.55 }),
  ]);
  escena.add(placa);

  lienzo.addEventListener('pointerdown', (e) => {
    arrastrando = true; ultimo = [e.clientX, e.clientY]; velY = 0;
    lienzo.setPointerCapture(e.pointerId);
  });
  lienzo.addEventListener('pointermove', (e) => {
    if (!arrastrando) return;
    const dx = e.clientX - ultimo[0], dy = e.clientY - ultimo[1];
    ultimo = [e.clientX, e.clientY];
    velY = dx * 0.01;
    rotY += velY;
    rotX = Math.max(-0.8, Math.min(0.8, rotX + dy * 0.01));
    quieto = 0;
  });
  const soltar = () => { arrastrando = false; };
  lienzo.addEventListener('pointerup', soltar);
  lienzo.addEventListener('pointercancel', soltar);
  addEventListener('resize', () => { if (dialogo.open) ajustar(); });
}

function ajustar() {
  const ancho = lienzo.clientWidth, alto = lienzo.clientHeight;
  renderer.setSize(ancho, alto, false);
  camara.aspect = ancho / alto;
  camara.updateProjectionMatrix();
}

function cuadro() {
  if (!animando) return;
  if (!arrastrando) {
    // Inercia al soltar y, después de un rato quieto, un giro lento
    velY *= 0.94;
    rotY += velY;
    if (++quieto > 90 && !sinMovimiento) rotY += 0.004;
  }
  placa.rotation.set(rotX, rotY, 0);
  renderer.render(escena, camara);
  requestAnimationFrame(cuadro);
}
