import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Item,Jugador


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


@csrf_exempt  # Desactivamos la seguridad CSRF solo para esta función
def api_jugadores(request):
    if request.method == 'POST':
        try:
            # 1. Leemos los parámetros ocultos en el cuerpo (body) de la petición
            body_unicode = request.body.decode('utf-8')
            datos = json.loads(body_unicode)

            # 2. Extraemos el nombre que nos envía el cliente
            nombre_recibido = datos.get('nombre')

            if not nombre_recibido:
                return JsonResponse({'error': 'El parámetro "nombre" es obligatorio'}, status=400)

            # 3. Lógica inteligente: Si existe lo recupera, si no, lo crea.
            jugador, creado = Jugador.objects.get_or_create(
                nombre=nombre_recibido,
                defaults={
                    'nivel_actual': 1,
                    'puntuacion': 0
                }
            )

            # 4. Defino el mensaje y el código de estado según si es nuevo o no
            if creado:
                mensaje = 'Partida creada con éxito'
                status_code = 201  # Created
            else:
                mensaje = 'Bienvenido de nuevo, progreso recuperado'
                status_code = 200  # OK


            return JsonResponse({
                'mensaje': mensaje,
                'jugador_id': jugador.id,
                'puntuacion': jugador.puntuacion,
                'tiene_doble_salto': jugador.tiene_doble_salto
            }, status=status_code)

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
            'tiene_doble_salto': jugador.tiene_doble_salto
        }, status=200)

    # 3. Lógica para el método PUT
    elif request.method == 'PUT':
        try:
            body_unicode = request.body.decode('utf-8')
            datos = json.loads(body_unicode)


            nueva_puntuacion = datos.get('puntuacion')
            nuevo_doble_salto = datos.get('tiene_doble_salto')
            nuevas_equipadas = datos.get('habilidades_equipadas')

            cambios_realizados = False

            if nueva_puntuacion is not None:
                jugador.puntuacion = nueva_puntuacion
                cambios_realizados = True

            if nuevo_doble_salto is not None:
                jugador.tiene_doble_salto = nuevo_doble_salto
                cambios_realizados = True

            if nuevas_equipadas is not None:
                jugador.habilidades_equipadas = nuevas_equipadas
                cambios_realizados = True

            if cambios_realizados:
                jugador.save()
                return JsonResponse({'mensaje': 'Datos del jugador actualizados correctamente'}, status=200)
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