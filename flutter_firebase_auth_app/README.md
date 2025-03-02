# Flutter Firebase Auth App

Este proyecto es una aplicación Flutter que utiliza Firebase Authentication para gestionar el inicio de sesión de los usuarios. La aplicación permite a los usuarios autenticarse y acceder a una pantalla principal después de iniciar sesión.

## Estructura del Proyecto

```
flutter_firebase_auth_app
├── android                # Código específico de Android
├── ios                    # Código específico de iOS
├── lib                    # Código fuente de la aplicación
│   ├── main.dart          # Punto de entrada de la aplicación
│   ├── screens            # Pantallas de la aplicación
│   │   ├── home_screen.dart # Pantalla principal después de iniciar sesión
│   │   └── login_screen.dart # Pantalla de inicio de sesión
│   ├── services           # Servicios de la aplicación
│   │   └── auth_service.dart # Lógica de autenticación con Firebase
│   └── widgets            # Widgets reutilizables
│       └── custom_button.dart # Botón personalizado
├── pubspec.yaml           # Configuración del proyecto Flutter
└── README.md              # Documentación del proyecto
```

## Requisitos

- Flutter SDK
- Firebase Project configurado
- Dependencias de Firebase en `pubspec.yaml`

## Instalación

1. Clona el repositorio:
   ```
   git clone <URL_DEL_REPOSITORIO>
   ```

2. Navega al directorio del proyecto:
   ```
   cd flutter_firebase_auth_app
   ```

3. Instala las dependencias:
   ```
   flutter pub get
   ```

4. Configura Firebase siguiendo la [documentación oficial de Firebase](https://firebase.google.com/docs/flutter/setup).

5. Ejecuta la aplicación:
   ```
   flutter run
   ```

## Contribuciones

Las contribuciones son bienvenidas. Si deseas contribuir, por favor abre un issue o envía un pull request.

## Licencia

Este proyecto está bajo la Licencia MIT.