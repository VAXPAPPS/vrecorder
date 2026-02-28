import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vrecorder/core/colors/vaxp_colors.dart';
import 'package:vrecorder/core/service_locator.dart';
import 'package:vrecorder/core/theme/vaxp_theme.dart';
import 'package:vrecorder/presentation/bloc/audio_bloc.dart';
import 'package:vrecorder/presentation/pages/recorder_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';

Future<void> main() async {
  // Initialize Flutter bindings first to ensure the binary messenger is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize Service Locator (DI)
  await ServiceLocator.setupServiceLocator();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(405, 700), 
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VaxpApp());
}

class VaxpApp extends StatelessWidget {
  const VaxpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: VaxpTheme.dark,
      home: BlocProvider<AudioBloc>(
        create: (context) => ServiceLocator.audioBloc,
        child: const RecorderPage(),
      ),
    );
  }
}
