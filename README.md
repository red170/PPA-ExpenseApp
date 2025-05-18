# Gestor de Gastos 170

Aplicación móvil simple para llevar un control de gastos personales, desarrollada como parte de la asignatura Desarrollo de Aplicaciones Móviles DAM-21.

## Descripción

"Gestor de Gastos 170" es una aplicación móvil intuitiva diseñada para ayudar a los usuarios a registrar y gestionar sus gastos diarios. Permite añadir nuevas transacciones, categorizarlas, especificar el monto y la fecha, y ofrece la posibilidad de editar o eliminar entradas existentes. La aplicación muestra un resumen del total de gastos, proporcionando una vista rápida de tu situación financiera. Todos los datos se almacenan de forma segura y localmente en el dispositivo del usuario.

## Características

* **Registro de Gastos:** Añade fácilmente nuevos gastos con descripción, categoría, monto y fecha.

* **Listado de Transacciones:** Visualiza un historial de todos tus gastos registrados.

* **Resumen Total:** Consulta el monto total acumulado de tus gastos.

* **Edición de Gastos:** Modifica los detalles de cualquier gasto previamente registrado.

* **Eliminación de Gastos:** Borra transacciones que ya no necesitas.

* **Almacenamiento Local:** Tus datos se guardan directamente en tu dispositivo utilizando una base de datos SQLite, sin necesidad de conexión a internet constante.

* **Interfaz Sencilla:** Diseño limpio y fácil de usar.

## Tecnologías Utilizadas

* **Flutter:** Framework de UI de Google para construir aplicaciones compiladas de forma nativa para móvil, web y escritorio desde una única base de código.

* **Dart:** Lenguaje de programación optimizado para clientes, desarrollado por Google.

* **sqflite:** Plugin de Flutter para acceder y manipular bases de datos SQLite en iOS y Android.

* **path_provider:** Plugin de Flutter para encontrar ubicaciones comunes en el sistema de archivos (necesario para la base de datos).

* **intl:** Paquete de Dart para internacionalización y localización, utilizado aquí para formatear fechas y moneda.

## Configuración del Proyecto

Para ejecutar este proyecto localmente, asegúrate de tener instalado:
