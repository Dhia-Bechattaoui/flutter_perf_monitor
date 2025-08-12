import 'package:flutter/material.dart';
import 'package:flutter_perf_monitor/flutter_perf_monitor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Performance Monitor Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Performance Monitor Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();

    // Initialize the performance monitor
    FlutterPerfMonitor.initialize();

    // Set up animation for demo purposes
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    FlutterPerfMonitor.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;

      if (_isMonitoring) {
        FlutterPerfMonitor.startMonitoring();
      } else {
        FlutterPerfMonitor.stopMonitoring();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: const Color(0xFFFFFFFF),
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Performance Monitor Demo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Text(
                  'This app demonstrates the Flutter Performance Monitor package.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),

                // Animated widget to generate some load
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value * 2 * 3.14159,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.speed,
                          color: Color(0xFFFFFFFF),
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _toggleMonitoring,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMonitoring
                        ? const Color(0xFFF44336)
                        : const Color(0xFF4CAF50),
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _isMonitoring
                      ? 'Performance monitoring is active. Check the overlay widget!'
                      : 'Click the button above to start performance monitoring.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),

          // Performance monitor widget overlay
          if (_isMonitoring)
            const PerfMonitorWidget(
              alignment: Alignment.topLeft,
              backgroundColor: Color(0x80000000),
              textColor: Color(0xFFFFFFFF),
              showFPS: true,
              showMemory: true,
              showCPU: true,
            ),
        ],
      ),
    );
  }
}
