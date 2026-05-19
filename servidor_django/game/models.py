from django.db import models

# Tabla 1
class Jugador(models.Model):
    nombre = models.CharField(max_length=50, unique=True)
    contrasena = models.CharField(max_length=128, default="")

    nivel_actual = models.IntegerField(default=1)
    puntuacion = models.IntegerField(default=0)
    tiene_doble_salto = models.BooleanField(default=False)
    habilidades_equipadas = models.TextField(default="")
    nivel_desbloqueado = models.IntegerField(default=1)
    tiene_dash = models.BooleanField(default=False)
    tiene_fuego = models.BooleanField(default=False)
    tiene_escudo = models.BooleanField(default=False)
    tiene_planeador = models.BooleanField(default=False)
    tiene_agua = models.BooleanField(default=False)

    def __str__(self):
        return self.nombre

# Tabla 2
class Item(models.Model):

    TIPO_CHOICES = [
        ('H', 'Habilidad'),
        ('C', 'Consumible'),
    ]
    nombre = models.CharField(max_length=50)
    descripcion = models.TextField()
    tipo = models.CharField(max_length=1, choices=TIPO_CHOICES)

    def __str__(self):
        return self.nombre

# Tabla 3 (Esta es la tabla intermedia que crea la relación N:N)
class Inventario(models.Model):
    jugador = models.ForeignKey(Jugador, on_delete=models.CASCADE)
    item = models.ForeignKey(Item, on_delete=models.CASCADE)
    cantidad = models.IntegerField(default=1)

    class Meta:
        # Evita que un jugador tenga dos filas diferentes para el mismo ítem
        unique_together = ('jugador', 'item')

    def __str__(self):
        return f"{self.cantidad}x {self.item.nombre} (de {self.jugador.nombre})"