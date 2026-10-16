# Contar

Base de gestión para estudios contables. Incluye autenticación, dos roles y los convertidores originales encapsulados detrás de permisos.

La aplicación usa PostgreSQL en desarrollo, pruebas y producción.

## Funcionalidad actual

- Administradores: acceso total, alta/edición/baja de usuarios y asignación de herramientas.
- Operarios: acceso exclusivo a los convertidores que tengan asignados.
- Convertidor de extractos bancarios.
- Convertidor de tarjetas de crédito.
- Procesamiento local: los archivos elegidos en los convertidores no se suben al servidor.

## Puesta en marcha

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Abrir `http://localhost:3000`.

PostgreSQL debe estar iniciado. En macOS con Homebrew:

```bash
brew services start postgresql@14
```

Por defecto se crean `contar_development` y `contar_test`. En producción se configura `DATABASE_URL`; para usar otro nombre local se puede definir `CONTAR_DATABASE_NAME`.

El seed crea un acceso inicial para desarrollo:

- Correo: `admin@contar.local`
- Contraseña: `Cambiar123!`

Para elegir credenciales propias al inicializar:

```bash
CONTAR_ADMIN_EMAIL=admin@tuestudio.com CONTAR_ADMIN_PASSWORD='una-clave-segura' bin/rails db:seed
```

Cambiar la contraseña inicial antes de usar la aplicación con datos reales.

> El entorno local actual usa Ruby 3.1 y Rails 7.2 porque son las versiones instaladas. Antes de desplegar en producción, actualizar a versiones con soporte vigente de Ruby y Rails y volver a ejecutar la suite y Brakeman.

## Convertidores importados

El código fuente provisto está en `lib/converters/` y se sirve únicamente a usuarios autenticados. Las librerías vendorizadas (`pdf.js` y SheetJS) están en `lib/converters/vendor/`. Los PDFs del ZIP son documentos de calibración y no se copiaron al proyecto para evitar almacenar información bancaria dentro del repositorio.

La lógica de parseo y validación original se conservó; sólo se adaptaron las rutas de navegación y carga de dependencias para integrarla con Contar.

## Despliegue en Render

El repositorio incluye `render.yaml` y `bin/render-build.sh`. El Blueprint crea un servicio web gratuito y una base PostgreSQL gratuita en la región de Virginia, ejecuta migraciones y configura `/health` como verificación de aplicación y base de datos.

1. Abrir [Deploy to Render](https://render.com/deploy?repo=https://github.com/francofer7/contar).
2. Conectar la cuenta de GitHub y elegir este repositorio.
3. Completar `RAILS_MASTER_KEY` con el contenido local de `config/master.key`.
4. Elegir un correo y una contraseña segura para `CONTAR_ADMIN_EMAIL` y `CONTAR_ADMIN_PASSWORD`.
5. Revisar y aprobar el Blueprint.

Los secretos nunca deben agregarse al repositorio. Los próximos commits sobre `main` dispararán despliegues automáticos.
