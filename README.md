# 📱 Mi Primera App en Flutter

Este proyecto es una aplicación creada con Flutter.

## Que es

Este repositorio contiene el desarrollo completo de la aplicación móvil, incluyendo todas las interfaces y funcionalidades dirigidas a los pacientes. Construido con Flutter, ofrece una experiencia fluida y optimizada para dispositivos móviles.

## 🚀 Configuración Inicial

1. **Instalar Java** (JDK 21)  
   - Descargar e instalar [Temurin JDK](https://adoptium.net/)  
   - Agregar la ruta a `JAVA_HOME` y `Path`  

2. **Instalar Flutter**  
   - Descargar e instalar Flutter desde [flutter.dev](https://flutter.dev/docs/get-started/install)  

3. **Verificar la instalación y crear el proyecto**  

   ```sh
   flutter doctor
   ```
   ```sh
   flutter create mi_primera_app
   ```
   ```sh
   cd mi_primera_app
   ```
   ```sh
   flutter run   
   ```

## 📦 Mantenimiento y Construcción

Para asegurar que las librerías estén actualizadas y el proyecto funcione correctamente, ejecuta los siguientes comandos:

### 1. Actualizar dependencias
```sh
flutter pub get
```
```sh
flutter pub upgrade
```

### 2. Limpiar el proyecto
```sh
flutter clean
```

### 3. Generar APK en forma de release (prueba)
```sh
flutter build apk --release
```

### 4. Generar apk Listo ()

```sh
flutter build apk --release --output=build/app/outputs/flutter-apk/SMM.apk
```

## comandos de git que me fueron utiles

Si trabajas en Windows y colaboras con personas que usan Linux o macOS, te recomiendo esta configuración:

```sh
git config --global core.autocrlf input
```

Si solo trabajas en Windows y no colaboras con otros sistemas operativos, puedes usar esta otra opción:

```sh
git config --global core.autocrlf true
```


## genera documentacion para tu proyecto en flutter/dart

Primero deberas estar en la carpeta donde tienes todo tu codigo (ejemplo: app/).

```sh
cd {nombre_tu_carpeta}
```

Nota: en tu codigo deberas utilizar "/// {descripcion del metodo, funcion de tu codigo}"

luego de revisar que tenga cada metodo o funcion documentado, pondras el siguiente codigo

```sh
dart doc
```

esto creara una carpeta dentro de tu aplicacion creara la carpeta 'doc/api'

y pondras entrar a index.html, podras ver tu proyecto documentado

Sugerencia: para mas facil (si esta en VS code) instala Live Server, es una extension que te ayudara a ver tus html con facilidad