import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cidaas_poc/protected_resource/presentation/cubit/protected_resource_cubit.dart';

class ProtectedResourcePage extends StatelessWidget {
  const ProtectedResourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protected Resource')),
      body: BlocConsumer<ProtectedResourceCubit, ProtectedResourceState>(
        listener: (context, state) {
          if (state is ProtectedResourceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is ProtectedResourceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProtectedResourceLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Resource Data:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        state.resource.data,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProtectedResourceCubit>()
                          .getResource(); // Volver a cargar
                    },
                    child: const Text('Refresh Resource'),
                  ),
                ],
              ),
            );
          } else if (state is ProtectedResourceError ||
              state is ProtectedResourceInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state is ProtectedResourceError
                        ? state.message
                        : 'Press the button to load the protected resource.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProtectedResourceCubit>().getResource();
                    },
                    child: const Text('Load Protected Resource'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
