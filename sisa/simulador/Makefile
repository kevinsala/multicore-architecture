JAVA_BIN_PATH=/opt/j2sdk1.4.2_04/bin

CLASSES=Simulador.class Decodificador.class Finestra.class Pantalla.java

all: $(CLASSES)


%.class: %.java
	$(JAVA_BIN_PATH)/javac $<

clean:
	rm *.class
