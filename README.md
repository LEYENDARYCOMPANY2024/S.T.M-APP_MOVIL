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


