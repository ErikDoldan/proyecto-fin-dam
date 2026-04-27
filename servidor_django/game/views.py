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

            # 3. Creamos el registro en la base de datos
            nuevo_jugador = Jugador.objects.create(
                nombre=nombre_recibido,
                nivel_actual=1,
                puntuacion=0
            )

            # 4. Devolvemos una respuesta de éxito (Status 201 = Creado)
            return JsonResponse({
                'mensaje': 'Partida creada con éxito',
                'jugador_id': nuevo_jugador.id
            }, status=201)

        except json.JSONDecodeError:
            # Si Godot nos envía algo que no es JSON, damos error
            return JsonResponse({'error': 'Formato JSON inválido'}, status=400)


@csrf_exempt
def api_jugador_detalle(request, jugador_id):
    # 1. Buscamos al jugador por el ID que viene en la URL (Path Param)
    try:
        jugador = Jugador.objects.get(id=jugador_id)
    except Jugador.DoesNotExist:
        return JsonResponse({'error': 'Jugador no encontrado'}, status=404)

    # 2. Lógica para el método PUT (Actualizar datos)
    if request.method == 'PUT':
        try:
            body_unicode = request.body.decode('utf-8')
            datos = json.loads(body_unicode)

            # Buscamos si nos envían una nueva puntuación
            nueva_puntuacion = datos.get('puntuacion')

            if nueva_puntuacion is not None:
                jugador.puntuacion = nueva_puntuacion
                jugador.save()  # Guardamos en la base de datos
                return JsonResponse({'mensaje': 'Puntuación actualizada', 'nueva_puntuacion': jugador.puntuacion})
            else:
                return JsonResponse({'error': 'Falta el parámetro "puntuacion"'}, status=400)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Formato JSON inválido'}, status=400)

    # 3. Lógica para el método DELETE (Borrar registro)
    elif request.method == 'DELETE':
        jugador.delete()  # Borramos de la base de datos
        return JsonResponse({'mensaje': f'Jugador {jugador_id} eliminado correctamente'})

    # Si intentan usar otro método distinto a PUT o DELETE
    return JsonResponse({'error': 'Método HTTP no permitido en esta ruta'}, status=405)