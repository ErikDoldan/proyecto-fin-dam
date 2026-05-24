import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from django.contrib.auth.hashers import make_password, check_password
from .models import Item, Jugador, Inventario

def api_items(request):
    # Comprobamos que la petición sea de tipo GET
    if request.method == 'GET':
        # Capturamos el parámetro de la query de la URL (?tipo=H o ?tipo=C)
        tipo_query = request.GET.get('tipo', None)

        # Si el usuario mandó el parámetro 'tipo', filtramos. Si no, devolvemos todo.
        if tipo_query:
            items = Item.objects.filter(tipo=tipo_query)
        else:
            items = Item.objects.all()

        # Convertimos los objetos de la base de datos a una estructura de diccionario
        # para poder enviarla como JSON.
        datos_items = []
        for item in items:
            datos_items.append({
                'id': item.id,
                'nombre': item.nombre,
                'descripcion': item.descripcion,
                'tipo': item.tipo
            })

        return JsonResponse({'items': datos_items}, safe=False)


@csrf_exempt
def api_jugadores(request):
    if request.method == 'POST':
        try:
            body_unicode = request.body.decode('utf-8')
            datos = json.loads(body_unicode)

            nombre_recibido = datos.get('nombre')
            password_recibida = datos.get('contrasena')  # Nuevo campo
            accion = datos.get('accion')  # Nuevo campo: 'login' o 'registro'

            if not nombre_recibido or not password_recibida:
                return JsonResponse({'error': 'Nombre y contraseña son obligatorios'}, status=400)

            # --- LÓGICA DE REGISTRO ---
            if accion == 'registro':
                if Jugador.objects.filter(nombre=nombre_recibido).exists():
                    return JsonResponse({'error': 'El nombre de usuario ya está pillado'}, status=409)

                # Creamos el jugador con la contraseña encriptada
                nuevo_jugador = Jugador.objects.create(
                    nombre=nombre_recibido,
                    contrasena=make_password(password_recibida),
                    nivel_actual=1,
                    puntuacion=0
                )
                return JsonResponse({
                    'mensaje': 'Cuenta creada con éxito',
                    'jugador_id': nuevo_jugador.id
                }, status=201)

            # --- LÓGICA DE LOGIN ---
            elif accion == 'login':
                try:
                    jugador = Jugador.objects.get(nombre=nombre_recibido)

                    # Comparamos la clave escrita con la encriptada de la base de datos
                    if check_password(password_recibida, jugador.contrasena):
                        return JsonResponse({
                            'mensaje': 'Bienvenido de nuevo',
                            'jugador_id': jugador.id,
                            'puntuacion': jugador.puntuacion,
                            'tiene_doble_salto': jugador.tiene_doble_salto,
                            'tiene_dash': jugador.tiene_dash,
                            'tiene_fuego': jugador.tiene_fuego,
                            'tiene_escudo': jugador.tiene_escudo,
                            'tiene_planeador': jugador.tiene_planeador,
                            'tiene_agua': jugador.tiene_agua,
                            'habilidades_equipadas': jugador.habilidades_equipadas,
                        }, status=200)
                    else:
                        return JsonResponse({'error': 'La contraseña no coincide'}, status=401)

                except Jugador.DoesNotExist:
                    return JsonResponse({'error': 'El usuario no existe'}, status=404)

            else:
                return JsonResponse({'error': 'Acción no válida'}, status=400)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
def api_jugador_detalle(request, jugador_id):
    # 1. Busco al jugador por el ID que viene en la URL (Path Param)
    try:
        jugador = Jugador.objects.get(id=jugador_id)
    except Jugador.DoesNotExist:
        return JsonResponse({'error': 'Jugador no encontrado'}, status=404)

    # 2. Lógica para el método GET
    if request.method == 'GET':
        return JsonResponse({
            'nombre': jugador.nombre,
            'puntuacion': jugador.puntuacion,
            'nivel_actual': jugador.nivel_actual,
            'tiene_doble_salto': jugador.tiene_doble_salto,
            'tiene_dash': jugador.tiene_dash,
            'habilidades_equipadas': jugador.habilidades_equipadas,
            'nivel_desbloqueado': jugador.nivel_desbloqueado,
            'tiene_fuego': jugador.tiene_fuego,
            'tiene_escudo': jugador.tiene_escudo,
            'tiene_planeador': jugador.tiene_planeador,
            'tiene_agua': jugador.tiene_agua,
        }, status=200)

    # 3. Lógica para el método PUT
    elif request.method == 'PUT':
        try:
            body_unicode = request.body.decode('utf-8')
            datos = json.loads(body_unicode)

            nueva_puntuacion = datos.get('puntuacion')
            nuevas_equipadas = datos.get('habilidades_equipadas')
            nuevo_nivel_desbloqueado = datos.get('nivel_desbloqueado')
            cambios_realizados = False

            if nueva_puntuacion is not None:
                jugador.puntuacion = nueva_puntuacion
                cambios_realizados = True

            if nuevas_equipadas is not None:
                jugador.habilidades_equipadas = nuevas_equipadas
                cambios_realizados = True

            if nuevo_nivel_desbloqueado is not None:
                jugador.nivel_desbloqueado = nuevo_nivel_desbloqueado
                cambios_realizados = True


            catalogo_habilidades = {
                'tiene_doble_salto': {'nombre': 'Fragmento de viento', 'desc': 'Permite realizar un segundo impulso en el aire.'},
                'tiene_dash': {'nombre': 'Fragmento de rayo', 'desc': 'Otorga un impulso rápido hacia adelante para esquivar.'},
                'tiene_fuego': {'nombre': 'Fragmento de fuego', 'desc': 'Permite disparar proyectiles de fuego a los enemigos.'},
                'tiene_escudo': {'nombre': 'Fragmento de piedra', 'desc': 'Crea una barrera regenerable que absorbe el daño del siguiente golpe.'},
                'tiene_planeador': {'nombre': 'Fragmento de sombra', 'desc': 'Permite descender lentamente y cruzar grandes abismos.'},
                'tiene_agua': {'nombre': 'Fragmento de agua', 'desc': 'Aumenta considerablemente la velocidad de movimiento.'}
            }

            habilidades_map = {
                'tiene_doble_salto': datos.get('tiene_doble_salto'),
                'tiene_dash': datos.get('tiene_dash'),
                'tiene_fuego': datos.get('tiene_fuego'),
                'tiene_escudo': datos.get('tiene_escudo'),
                'tiene_planeador': datos.get('tiene_planeador'),
                'tiene_agua': datos.get('tiene_agua')
            }

            for nombre_var, valor in habilidades_map.items():
                if valor is not None:
                    # 1. Actualiza el booleano en el modelo Jugador
                    setattr(jugador, nombre_var, valor)
                    cambios_realizados = True

                    # 2. Lógica del Inventario bonito para el TF
                    if valor == True:
                        datos_item = catalogo_habilidades[nombre_var]
                        # Buscam o cream el Item con su nombre y descripción
                        item_obj, _ = Item.objects.get_or_create(
                            nombre=datos_item['nombre'],
                            defaults={'descripcion': datos_item['desc'], 'tipo': 'H'}
                        )
                        # Registro en el Inventario (Relación N:N)
                        Inventario.objects.get_or_create(
                            jugador=jugador,
                            item=item_obj,
                            defaults={'cantidad': 1}
                        )

            if cambios_realizados:
                jugador.save()
                return JsonResponse({'mensaje': 'Datos del jugador y su inventario actualizados correctamente'}, status=200)
            else:
                return JsonResponse({'error': 'No se enviaron parámetros válidos para actualizar'}, status=400)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido'}, status=400)

    # 4. Lógica para el método DELETE
    elif request.method == 'DELETE':
        jugador.delete()  # Borramos de la base de datos
        return JsonResponse({'mensaje': f'Jugador {jugador_id} eliminado correctamente'}, status=200)

    # Si intentan usar otro método distinto a GET, PUT o DELETE
    return JsonResponse({'error': 'Método HTTP no permitido en esta ruta'}, status=405)