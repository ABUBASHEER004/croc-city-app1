# The SLF4J binding is optional for some Android dependencies.
# R8 sees the optional legacy binding class but it is not required at runtime.
-dontwarn org.slf4j.impl.StaticLoggerBinder
