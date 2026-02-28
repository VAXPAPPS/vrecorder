import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vrecorder/core/theme/vaxp_theme.dart';
import 'package:vrecorder/core/venom_layout.dart';
import 'package:vrecorder/domain/entities/recording.dart';
import 'package:vrecorder/presentation/bloc/audio_bloc.dart';
import 'package:vrecorder/presentation/bloc/audio_event.dart';
import 'package:vrecorder/presentation/bloc/audio_state.dart';
import 'dart:io';

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  @override
  void initState() {
    super.initState();
    // Load recordings on startup
    context.read<AudioBloc>().add(const LoadRecordingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
      title: "Voice Recorder",
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- Recording Section ---
                  _buildRecordingSection(context, state),
                  const SizedBox(height: 30),

                  // --- Saved Recordings Section ---
                  _buildRecordingsSection(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Main Recording Section
  Widget _buildRecordingSection(BuildContext context, AudioState state) {
    final isRecording = state is RecordingInProgress;
    final elapsedTime = (state is RecordingInProgress) ? state.elapsedTime : Duration.zero;
    final level = (state is RecordingInProgress) ? state.currentLevel : 0.0;

    return VaxpGlass(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'New Voice Recording',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),

            // Display elapsed time
            Text(
              _formatDuration(elapsedTime),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: isRecording ? Colors.red : Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Display sound level
            if (isRecording) ...[
              Text(
                'Sound Level',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: level,
                  minHeight: 20,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getLevelColor(level),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start/Stop Recording button
                ElevatedButton.icon(
                  onPressed: () {
                    if (isRecording) {
                      context.read<AudioBloc>().add(const StopRecordingEvent());
                    } else {
                      context.read<AudioBloc>().add(const StartRecordingEvent());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecording ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                  ),
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 24,
                  ),
                  label: Text(
                    isRecording ? 'Stop' : 'Start',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            // Status messages
            if (state is AudioLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ] else if (state is AudioError) ...[
              const SizedBox(height: 20),
              Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ] else if (state is RecordingCompleted) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✓ Recording saved: ${state.recording.filename}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Saved Recordings Section
  Widget _buildRecordingsSection(BuildContext context, AudioState state) {
    List<Recording> recordings = [];

    if (state is RecordingsLoaded) {
      recordings = state.recordings;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Recordings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 15),

        if (recordings.isEmpty)
          VaxpGlass(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Text(
                  'No saved recordings yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
        else
          ...recordings.map((recording) => _buildRecordingCard(context, recording)),
      ],
    );
  }

  // Single Recording Card
  Widget _buildRecordingCard(BuildContext context, Recording recording) {
    return VaxpGlass(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.audiotrack, size: 32),
        title: Text(recording.filename),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              '${recording.durationString} • ${recording.fileSizeString}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              recording.createdAt.toString().split('.')[0],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle, color: Colors.green),
                onPressed: () {
                  _playAudio(recording.filePath);
                },
                tooltip: 'Play',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(context, recording.id);
                },
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmation(BuildContext context, String recordingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(188, 0, 0, 0),
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AudioBloc>().add(DeleteRecordingEvent(recordingId));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Format duration display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Select sound level color
  Color _getLevelColor(double level) {
    if (level < 0.5) return Colors.green;
    if (level < 0.75) return Colors.yellow;
    return Colors.red;
  }

  // Play Audio File
  void _playAudio(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(188, 0, 0, 0),
        title: const Text('Play File'),
        content: Text('Do you want to play:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Play file using default application
              Process.run('xdg-open', [filePath]).then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Playing file...')),
                  );
                }
              }).catchError((e) {
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Error playing file: $e')),
                  );
                }
              });
            },
            child: const Text('Play', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
