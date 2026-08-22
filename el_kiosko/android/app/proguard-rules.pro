# Reglas de R8 para el build de release.
#
# El motor de Flutter y los plugins traen sus propias reglas "consumer", así
# que acá sólo va lo específico de esta app.

# Play Core (deferred components / split install).
#
# El embedding de Flutter referencia estas clases para descargar módulos bajo
# demanda, pero esta app NO usa deferred components y por lo tanto no incluye
# la librería Play Core. Sin esta regla, R8 aborta el build de release con
# "Missing class com.google.android.play.core...".
#
# Se usa -dontwarn en vez de agregar la dependencia: no la necesitamos y
# sumarla engordaría el AAB sin motivo.
-dontwarn com.google.android.play.core.**

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
