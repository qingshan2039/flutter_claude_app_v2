import 'dart:async';

import 'package:flutter/widgets.dart';

/// 流式文本展示组件（T32.2）。
///
/// 订阅一个 `Stream<String>`（增量分片），逐片累积显示，未结束时显示光标 `▌`，
/// 结束回调 [onDone]。适配任意流式来源（LLM 流、SSE 解析后的 delta）。
class StreamingTextView extends StatefulWidget {
  const StreamingTextView({
    required this.stream,
    super.key,
    this.style,
    this.showCursor = true,
    this.onDone,
  });

  /// 增量分片流（每个元素是一段新增文本）。
  final Stream<String> stream;
  final TextStyle? style;
  final bool showCursor;
  final VoidCallback? onDone;

  @override
  State<StreamingTextView> createState() => _StreamingTextViewState();
}

class _StreamingTextViewState extends State<StreamingTextView> {
  final StringBuffer _buffer = StringBuffer();
  StreamSubscription<String>? _sub;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(StreamingTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _sub?.cancel();
      _buffer.clear();
      _done = false;
      _subscribe();
    }
  }

  void _subscribe() {
    _sub = widget.stream.listen(
      (delta) {
        if (!mounted) return;
        setState(() => _buffer.write(delta));
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _done = true);
        widget.onDone?.call();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCursor = widget.showCursor && !_done;
    return Text(
      '$_buffer${showCursor ? '▌' : ''}',
      style: widget.style,
    );
  }
}
