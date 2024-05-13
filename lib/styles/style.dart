import 'package:flutter/material.dart';

// Estilo para el fondo del diálogo
const BoxDecoration dialogBackgroundDecoration = BoxDecoration
(
  color: Color.fromARGB(255, 38, 130, 84),
);

// Estilo para el texto de los botones del diálogo
const TextStyle dialogButtonTextStyle = TextStyle
(
  color: Colors.black,
);

// Estilo para los botones del diálogo
final ButtonStyle dialogButtonStyle = ElevatedButton.styleFrom
(
  textStyle: dialogButtonTextStyle, // Aplica el estilo al texto del botón
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);
