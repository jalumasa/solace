# Firestore maps documents reflectively onto model classes in some code paths;
# keep the model package intact so field names survive minification.
-keep class com.jonathanalumasa.solace.model.** { *; }
