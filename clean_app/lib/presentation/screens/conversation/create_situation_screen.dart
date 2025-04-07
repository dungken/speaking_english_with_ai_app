import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../application/conversation/conversation_bloc.dart';
import '../../../domain/repositories/conversation_repository.dart';
import '../../widgets/conversation/situation_form.dart';

class CreateSituationScreen extends StatelessWidget {
  const CreateSituationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationBloc(
        repository: context.read<ConversationRepository>(),
      ),
      child: BlocListener<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state is ConversationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is ConversationSuccess &&
              state.conversationId != null) {
            Get.toNamed('/chat', arguments: state.conversationId);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Conversation'),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          body: BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              if (state is ConversationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state is ConversationFailure)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red[100],
                        child: Text(
                          state.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SituationForm(
                      onSubmit: (userRole, aiRole, situation) {
                        context.read<ConversationBloc>().add(
                              CreateConversation(
                                userRole: userRole,
                                aiRole: aiRole,
                                situation: situation,
                              ),
                            );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
