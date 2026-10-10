# reecicla-app — iOS Client ♻️

App móvil nativa para **iOS** construida con **SwiftUI**, conectada al ecosistema de microservicios de [`reecicla-backend`](../reecicla-backend).

---

## 🏗️ Arquitectura

```
reecicla-app/
├── Network/
│   ├── Config.swift          ← LOCAL ONLY (gitignored) — tu IP o URL del servidor
│   ├── Config.swift.example  ← Template para configurar el entorno
│   ├── Endpoints.swift       ← URLs centralizadas (lee de Config.swift)
│   └── APIClient.swift       ← URLSession + manejo de errores + Keychain JWT
├── Models/
│   └── AuthModels.swift      ← Structs Codable mapeados al backend
├── Services/
│   └── AuthService.swift     ← login(), register(), logout(), getProfile()
├── ViewModels/
│   └── AuthViewModel.swift   ← ObservableObject con estado + manejo de errores
├── Views/
│   ├── LoginView.swift       ← Pantalla Auth con tab switcher Login/Registro
│   ├── RegisterView.swift    ← Stub (formulario embebido en LoginView)
│   ├── HomeView.swift        ← Dashboard post-login
│   ├── GuestOrderTrackingView.swift ← Seguimiento privado sin cuenta
│   ├── AuthTextField.swift   ← Campo de texto reutilizable con ícono
│   └── ColorExtension.swift  ← Design tokens (mirrors reecicla-frontend CSS vars)
├── ContentView.swift         ← Router: Login ↔ Home según estado de autenticación
├── reecicla_appApp.swift     ← Entry point, inyecta AuthViewModel como EnvironmentObject
└── Info.plist                ← NSAllowsLocalNetworking: true (permite HTTP local)
```

---

## ⚙️ Setup local

### Requisitos

- Xcode 16+
- iOS 17+ (dispositivo o simulador)
- Backend corriendo: ver [`reecicla-backend`](../reecicla-backend)

### 1. Configurar la URL del backend

```bash
cp reecicla-app/Network/Config.swift.example reecicla-app/Network/Config.swift
```

Edita `Config.swift` y reemplaza con tu IP o URL y el slug del negocio:

```swift
enum AppConfig {
    // Desarrollo local — dispositivo físico en la misma red WiFi
    static let baseURL = "http://192.168.X.X:3000"
    static let tenantSlug = "demo"

    // Producción
    // static let baseURL = "https://api.reecicla.com"
}
```

> ⚠️ `Config.swift` está en `.gitignore` — nunca sube al repositorio.

### 2. Levantar el backend

```bash
cd ../reecicla-backend
docker compose up -d
```

### 3. Abrir en Xcode

```bash
open reecicla-app.xcodeproj
```

Selecciona tu dispositivo o simulador y presiona **⌘R**.

> **Dispositivo físico**: el iPhone debe estar en la misma red WiFi que tu Mac.  
> **Simulador**: `localhost` funciona directamente, puedes usar `http://localhost:3000`.

---

## 🔐 Autenticación

La app implementa autenticación con **JWT** almacenado en el **Keychain** del dispositivo (no en UserDefaults).

| Campo | Descripción |
|---|---|
| `ID de Tenant` | Identificador del tenant (ej. `reecicla`) |
| `Email` | Correo del usuario |
| `Contraseña` | Mínimo 6 caracteres |

El token se renueva automáticamente en cada login y persiste entre sesiones hasta que el usuario cierra sesión explícitamente.

También se puede cotizar y aceptar como invitado, sin crear cuenta. Para aceptar, el cliente ingresa nombre, correo, teléfono y dirección; verifica el código enviado a su correo y recibe un enlace privado de seguimiento. En la pantalla de seguimiento se puede pegar ese enlace completo o su token.

La app recibe enlaces `reecicla://seguimiento/<token>`. Los enlaces web del correo se abren en el navegador salvo que el dominio de producción configure Universal Links y Associated Domains para la app.

El envío del OTP y del enlace depende del SMTP configurado en el backend. Para Gmail, configura las variables `SMTP_*` en el `.env` raíz del backend; la app no almacena credenciales de correo.

---

## 🌐 Endpoints consumidos

Todos los requests van a través del **API Gateway** en el puerto `3000`.

| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/recicla/{slug}/auth/register` | Registro de cliente |
| `POST` | `/recicla/{slug}/auth/login` | Login + emisión de JWT |
| `GET` | `/api/auth/me` | Perfil del usuario autenticado |
| `POST` | `/recicla/{slug}/quotation/quotes` | Crear cotización con o sin sesión |
| `POST` | `/recicla/{slug}/quotation/quotes/{id}/accept` | Aceptar; invitado verifica el correo por OTP |
| `GET` | `/recicla/{slug}/orders/tracking/{token}` | Consultar seguimiento privado sin sesión |

---

## 🎨 Diseño

El sistema de diseño replica los tokens CSS de `reecicla-frontend`:

| Token | Valor | Uso |
|---|---|---|
| `bgPage` | `#f8fafc` | Fondo de pantallas |
| `bluePrimary` | `#2563eb` | Botones, focus |
| `greenPrimary` | `#16a34a` | Éxito, precios |
| `textMain` | `#0f172a` | Texto principal |
| `textMuted` | `#64748b` | Labels, subtítulos |

---

## 📝 Notas de desarrollo

- **`Config.swift` cambia con cada red WiFi** — solo editás la IP y el slug del negocio, nunca sube al repo.
- El backend requiere `tenant_id` en todos los requests de auth — el campo está expuesto en el formulario con valor por defecto `reecicla`.
- El `Info.plist` tiene `NSAllowsLocalNetworking: true` para permitir HTTP (no HTTPS) en desarrollo local. En producción se usará HTTPS y esta clave puede eliminarse.
