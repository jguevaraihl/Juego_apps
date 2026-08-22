# Reglas de R8 para el build de release.
#
# El motor de Flutter y los plugins traen sus propias reglas "consumer", así
# que acá sólo va lo específico de esta app.

# Flutter embedding: se referencia desde el manifest y por reflexión.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# No romper los nombres de las excepciones en los reportes de crash.
-keepattributes SourceFile,LineNumberTable,*Annotation*

# No dejar logs de debug en release.
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
}
