import 'package:flutter/material.dart';

class TerminosCondicionesDialog extends StatelessWidget {
  const TerminosCondicionesDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Términos y Condiciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '''
Términos y Condiciones de Uso

1. Introducción
Bienvenido a *Sistema de Monitoreo de la Marcha* (en adelante, "la Aplicación"), operada por *Leyendary Inc.*, con domicilio en Calle Reforma #28, Colonia Centro, C.P. 43600, Tulancingo, Hidalgo, México. La Aplicación está diseñada para facilitar la rehabilitación de los pacientes y proporcionar herramientas para terapeutas. Al utilizar nuestra plataforma web y móvil, usted acepta estos Términos y Condiciones de Uso. Si no está de acuerdo con estos términos, le recomendamos que no utilice la Aplicación.

2. Recopilación y Uso de Datos
Al utilizar la Aplicación, recopilamos y procesamos los siguientes datos:

- *Datos personales:* Información del terapeuta y paciente, incluyendo nombre, edad, contacto y datos de salud relevantes.
- *Conversaciones:* Mensajes e interacciones entre terapeutas y pacientes dentro de la Aplicación.
- *Datos de rehabilitación:* Estadísticas, progreso y evaluaciones relacionadas con las terapias.
- *Grabación de videos y sensores:* Captura de videos e información de movimiento utilizando tecnologías como MediaPipe para analizar ángulos y desempeño en los ejercicios.

3. Uso de la Información
La información recopilada se utilizará exclusivamente para los siguientes fines:

- Monitoreo y mejora del proceso de rehabilitación.
- Análisis de progreso y personalización de terapias.
- Comunicación entre terapeutas y pacientes dentro de la Aplicación.
- Desarrollo y mejora de los servicios ofrecidos en la Aplicación.

4. Protección de Datos
Nos comprometemos a proteger la privacidad de los datos recopilados. Implementamos medidas de seguridad técnicas y administrativas para evitar el acceso no autorizado, la pérdida o alteración de la información. Sin embargo, el usuario también es responsable de mantener segura su cuenta y credenciales de acceso.

5. Consentimiento y Derechos del Usuario
Al registrarse y utilizar la Aplicación, el usuario otorga su consentimiento para la recopilación y procesamiento de sus datos según lo descrito en estos términos. El usuario tiene derecho a:

- Solicitar acceso a su información personal.
- Modificar o corregir sus datos si son inexactos.
- Solicitar la eliminación de su información, salvo cuando sea necesaria para cumplir con regulaciones legales o contractuales.

6. Responsabilidades del Usuario
El usuario se compromete a utilizar la Aplicación de manera responsable y a no compartir información confidencial de terceros sin su consentimiento. Además, se prohíbe el uso de la Aplicación con fines fraudulentos, ilegales o que perjudiquen a otros usuarios.

7. Modificaciones y Vigencia
Nos reservamos el derecho de modificar estos Términos y Condiciones en cualquier momento. Cualquier cambio será notificado a los usuarios a través de la Aplicación. El uso continuo de la Aplicación después de las modificaciones implica la aceptación de los nuevos términos.

8. Jurisdicción y Legislación Aplicable
Estos Términos y Condiciones se regirán e interpretarán de acuerdo con las leyes de los Estados Unidos Mexicanos. Cualquier controversia que surja en relación con la Aplicación será sometida a los tribunales competentes de Tulancingo, Hidalgo.

9. Contacto
Para cualquier consulta sobre estos Términos y Condiciones, puede contactarnos a través del correo electrónico *leyendary2024@gmail.com*.

Al utilizar nuestra Aplicación, usted acepta estos Términos y Condiciones en su totalidad.
''',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    );
  }
} 