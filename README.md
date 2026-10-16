# Contar

Base de gestión para estudios contables. Incluye autenticación, dos roles y los convertidores originales encapsulados detrás de permisos.

La aplicación usa PostgreSQL en desarrollo, pruebas y producción.

## Funcionalidad actual

- Administradores: acceso total, alta/edición/baja de usuarios, asignación de herramientas y envío de accesos por WhatsApp.
- Operarios: acceso exclusivo a los convertidores que tengan asignados.
- Convertidor de extractos bancarios.
- Convertidor de tarjetas de crédito.
- Teléfonos internacionales validados y normalizados con `phonelib`, con selector de país y Argentina como opción predeterminada.
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
CONTAR_ADMIN_EMAIL=admin@tuestudio.com CONTAR_ADMIN_PASSWORD='una-clave-segura' CONTAR_ADMIN_PHONE_COUNTRY='AR' CONTAR_ADMIN_PHONE='3515559999' bin/rails db:seed
```

Cambiar la contraseña inicial antes de usar la aplicación con datos reales.

> El entorno local actual usa Ruby 3.1 y Rails 7.2 porque son las versiones instaladas. Antes de desplegar en producción, actualizar a versiones con soporte vigente de Ruby y Rails y volver a ejecutar la suite y Brakeman.

## Convertidores importados

El código fuente provisto está en `lib/converters/` y se sirve únicamente a usuarios autenticados. Las librerías vendorizadas (`pdf.js` y SheetJS) están en `lib/converters/vendor/`. Los PDFs del ZIP son documentos de calibración y no se copiaron al proyecto para evitar almacenar información bancaria dentro del repositorio.

La lógica de parseo y validación original se conservó; sólo se adaptaron las rutas de navegación y carga de dependencias para integrarla con Contar.

## Despliegue en Render

El repositorio incluye `render.yaml` y `bin/render-build.sh`. El Blueprint crea un servicio web gratuito en la región de Virginia, se conecta a PostgreSQL en Neon, ejecuta migraciones y configura `/health` como verificación de aplicación y base de datos.

1. Crear el proyecto `contar` en [Neon](https://console.neon.tech/) y copiar su cadena de conexión PostgreSQL con SSL.
2. Abrir [Deploy to Render](https://render.com/deploy?repo=https://github.com/francofer7/contar).
3. Conectar la cuenta de GitHub y elegir este repositorio.
4. Completar `DATABASE_URL` con la cadena de conexión entregada por Neon.
5. Completar `RAILS_MASTER_KEY` con el contenido local de `config/master.key`.
6. Elegir un correo y una contraseña segura para `CONTAR_ADMIN_EMAIL` y `CONTAR_ADMIN_PASSWORD`.
7. Completar `CONTAR_ADMIN_PHONE_COUNTRY` con el código ISO del país y `CONTAR_ADMIN_PHONE` con el número nacional. Para Argentina: `AR` y el número sin `0`, `15` ni `+54 9` (por ejemplo, `3515559999`).
8. Revisar y aprobar el Blueprint.

El build ejecuta migraciones y seeds en cada despliegue. Los seeds son idempotentes: crean el administrador si falta, pero no reemplazan su contraseña si ya existe. Si agregaste las variables a un servicio existente, guardalas en Render y dispará un nuevo despliegue.

Los secretos nunca deben agregarse al repositorio. Los próximos commits sobre `main` dispararán despliegues automáticos.
