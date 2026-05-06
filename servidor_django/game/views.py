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
            # 'jugador' es el objeto que devuelve.
            # 'creado' es un booleano (True si es nuevo, False si ya existía).
            jugador, creado = Jugador.objects.get_or_create(
                nombre=nombre_recibido,
                defaults={
                    'nivel_actual': 1,
                    'puntuacion': 0
                }
            )

            # 4. Definimos el mensaje y el código de estado según si es nuevo o no
            if creado:
                mensaje = 'Partida creada con éxito'
                status_code = 201  # Created
            else:
                mensaje = 'Bienvenido de nuevo, progreso recuperado'
                status_code = 200  # OK

            # 5. Devolvemos la respuesta con el ID (indispensable para el Singleton de Godot)
            return JsonResponse({
                'mensaje': mensaje,
                'jugador_id': jugador.id
            }, status=status_code)

        except json.JSONDecodeError:
            # Si Godot nos envía algo que no es JSON, damos error
            return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
        except Exception as e:
            # Capturamos cualquier otro error inesperado para que no devuelva un HTML 500
            return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt
def api_jugador_detalle(request, jugador_id):
    # 1. Buscamos al jugador por el ID que viene en la URL (Path Param)
    try:
        jugador = Jugador.objects.get(id=jugador_id)
    except Jugador.DoesNotExist:
        return JsonResponse({'error': 'Jugador no encontrado'}, status=404)

    # 2. Lógica para el método GET (Leer datos para mostrar en Godot)
    if request.method == 'GET':
        return JsonResponse({
            'nombre': jugador.nombre,
            'puntuacion': jugador.puntuacion,
            'nivel_actual': jugador.nivel_actual,
            'tiene_doble_salto': jugador.tiene_doble_salto  # <-- NUEVO: Enviamos el poder a Godot
        }, status=200)

    # 3. Lógica para el método PUT (Actualizar datos)
    elif request.method == 'PUT':
        try:
            body_unicode = request.body.decode('utf-8')
            datos = json.loads(body_unicode)

            # Buscamos si nos envían datos nuevos
            nueva_puntuacion = datos.get('puntuacion')
            nuevo_doble_salto = datos.get('tiene_doble_salto')  # <-- NUEVO: Leemos el poder

            cambios_realizados = False

            # Si mandaron puntuación, la actualizamos
            if nueva_puntuacion is not None:
                jugador.puntuacion = nueva_puntuacion
                cambios_realizados = True

            # Si mandaron el doble salto, lo actualizamos
            if nuevo_doble_salto is not None:
                jugador.tiene_doble_salto = nuevo_doble_salto
                cambios_realizados = True

            # Si se ha modificado algo, guardamos en la base de datos
            if cambios_realizados:
                jugador.save()
                return JsonResponse({'mensaje': 'Datos del jugador actualizados correctamente'}, status=200)
            else:
                return JsonResponse({'error': 'No se enviaron parámetros válidos para actualizar'}, status=400)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido'}, status=400)

    # 4. Lógica para el método DELETE (Borrar registro)
    elif request.method == 'DELETE':
        jugador.delete()  # Borramos de la base de datos
        return JsonResponse({'mensaje': f'Jugador {jugador_id} eliminado correctamente'}, status=200)

    # Si intentan usar otro método distinto a GET, PUT o DELETE
    return JsonResponse({'error': 'Método HTTP no permitido en esta ruta'}, status=405)