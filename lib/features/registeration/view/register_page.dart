import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import '../../../provider/providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationNotifierProvider);
    final notifier = ref.read(registrationNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация сотрудника'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.isSending
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Имя'),
                        initialValue: state.firstName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите имя';
                          }
                          return null;
                        },
                        onChanged: (value) => notifier.setFirstName(value),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Фамилия'),
                        initialValue: state.lastName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите фамилию';
                          }
                          return null;
                        },
                        onChanged: (value) => notifier.setLastName(value),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => notifier.pickImages(),
                        child: const Text('Прикрепить фото'),
                      ),
                      const SizedBox(height: 10),
                      if (state.images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.images.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder<Uint8List>(
                                future: state.images[index].readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.memory(
                                        snapshot.data!,
                                        height: 100,
                                        width: 100,
                                      ),
                                    );
                                  } else {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => notifier.sendData(_formKey, context),
                        child: const Text('Отправить'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
