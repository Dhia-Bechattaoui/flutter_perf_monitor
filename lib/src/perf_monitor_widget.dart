import 'package:flutter/material.dart';
import 'flutter_perf_monitor.dart';
import 'models/fps_data.dart';
import 'models/memory_data.dart';
import 'models/performance_metrics.dart';

/// A widget that displays real-time performance metrics.
///
/// This widget shows FPS, memory usage, and other performance indicators
/// in a visually appealing overlay that can be positioned anywhere in your app.
class PerfMonitorWidget extends StatefulWidget {
  /// The position of the monitor widget
  final Alignment alignment;

  /// Whether to show the FPS display
  final bool showFPS;

  /// Whether to show the memory usage display
  final bool showMemory;

  /// Whether to show the CPU usage display
  final bool showCPU;

  /// The background color of the monitor
  final Color backgroundColor;

  /// The text color of the monitor
  final Color textColor;

  /// The border radius of the monitor
  final double borderRadius;

  /// The padding of the monitor
  final EdgeInsets padding;

  /// Creates a new PerfMonitorWidget instance.
  ///
  /// [key] - The widget key
  /// [alignment] - The position of the monitor widget
  /// [showFPS] - Whether to show the FPS display
  /// [showMemory] - Whether to show the memory usage display
  /// [showCPU] - Whether to show the CPU usage display
  /// [backgroundColor] - The background color of the monitor
  /// [textColor] - The text color of the monitor
  /// [borderRadius] - The border radius of the monitor
  /// [padding] - The padding of the monitor
  const PerfMonitorWidget({
    super.key,
    this.alignment = Alignment.topRight,
    this.showFPS = true,
    this.showMemory = true,
    this.showCPU = true,
    this.backgroundColor = const Color(0x80000000),
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  State<PerfMonitorWidget> createState() => _PerfMonitorWidgetState();
}

class _PerfMonitorWidgetState extends State<PerfMonitorWidget> {
  PerformanceMetrics? _currentMetrics;
  FPSData? _currentFPS;
  MemoryData? _currentMemory;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _startListening() {
    FlutterPerfMonitor.instance.metricsStream.listen((metrics) {
      if (mounted) {
        setState(() {
          _currentMetrics = metrics;
        });
      }
    });

    FlutterPerfMonitor.instance.fpsStream.listen((fps) {
      if (mounted) {
        setState(() {
          _currentFPS = fps;
        });
      }
    });

    FlutterPerfMonitor.instance.memoryStream.listen((memory) {
      if (mounted) {
        setState(() {
          _currentMemory = memory;
        });
      }
    });
  }

  void _stopListening() {
    // Streams are automatically managed by the FlutterPerfMonitor
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.textColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: _isExpanded ? _buildExpandedView() : _buildCompactView(),
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showFPS && _currentFPS != null)
          _buildMetricChip('FPS', _currentFPS!.currentFPS.toStringAsFixed(1)),
        if (widget.showMemory && _currentMemory != null)
          _buildMetricChip(
            'MEM',
            '${_currentMemory!.currentUsageMB.toStringAsFixed(1)}MB',
          ),
        if (widget.showCPU && _currentMetrics != null)
          _buildMetricChip(
            'CPU',
            '${_currentMetrics!.cpuUsage.toStringAsFixed(1)}%',
          ),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (widget.showFPS && _currentFPS != null) _buildFPSDetails(),
        if (widget.showMemory && _currentMemory != null) _buildMemoryDetails(),
        if (widget.showCPU && _currentMetrics != null) _buildCPUDetails(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.speed, color: widget.textColor, size: 16.0),
        const SizedBox(width: 4.0),
        Text(
          'Performance Monitor',
          style: TextStyle(
            color: widget.textColor,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: widget.textColor,
          size: 16.0,
        ),
      ],
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: widget.textColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: widget.textColor,
          fontSize: 10.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFPSDetails() {
    if (_currentFPS == null) return const SizedBox.shrink();

    return _buildDetailSection('FPS', [
      _buildDetailRow('Current', _currentFPS!.currentFPS.toStringAsFixed(1)),
      _buildDetailRow('Average', _currentFPS!.averageFPS.toStringAsFixed(1)),
      _buildDetailRow('Min', _currentFPS!.minFPS.toStringAsFixed(1)),
      _buildDetailRow('Max', _currentFPS!.maxFPS.toStringAsFixed(1)),
    ]);
  }

  Widget _buildMemoryDetails() {
    if (_currentMemory == null) return const SizedBox.shrink();

    final rows = <Widget>[
      _buildDetailRow(
        'Current',
        '${_currentMemory!.currentUsageMB.toStringAsFixed(1)}MB',
      ),
      _buildDetailRow(
        'Peak',
        '${_currentMemory!.peakUsageMB.toStringAsFixed(1)}MB',
      ),
    ];

    // Only show Available and Usage if we have total memory data
    if (_currentMemory!.totalMemory > 0) {
      rows.add(
        _buildDetailRow(
          'Available',
          '${_currentMemory!.availableMemoryMB.toStringAsFixed(1)}MB',
        ),
      );
      rows.add(
        _buildDetailRow(
          'Usage',
          '${_currentMemory!.usagePercentage.toStringAsFixed(1)}%',
        ),
      );
    }

    return _buildDetailSection('Memory', rows);
  }

  Widget _buildCPUDetails() {
    if (_currentMetrics == null) return const SizedBox.shrink();

    return _buildDetailSection('CPU', [
      _buildDetailRow(
        'Usage',
        '${_currentMetrics!.cpuUsage.toStringAsFixed(1)}%',
      ),
      _buildDetailRow(
        'Frame Time',
        '${_currentMetrics!.frameTime.toStringAsFixed(2)}ms',
      ),
    ]);
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50.0,
            child: Text(
              label,
              style: TextStyle(
                color: widget.textColor.withValues(alpha: 0.8),
                fontSize: 10.0,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
