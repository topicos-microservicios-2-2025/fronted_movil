import 'package:flutter/material.dart';

class FormularioRegistro extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBuscar;
  final bool isLoading;
  const FormularioRegistro({
    required this.controller,
    required this.onBuscar,
    required this.isLoading,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Número de registro:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Ingrese su número de registro'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isLoading ? null : onBuscar,
              child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Buscar'),
            ),
          ],
        ),
      ],
    );
  }
}
