import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@optionalTypeArgs
mixin AutomaticKeepAliveWidgetModelMixin<W extends WMWidget<IWM>, M extends Model>
    on WidgetModel<W, M> {
  KeepAliveHandle? _keepAliveHandle;

  void _ensureKeepAlive() {
    assert(_keepAliveHandle == null);
    _keepAliveHandle = KeepAliveHandle();
    KeepAliveNotification(_keepAliveHandle!).dispatch(context);
  }

  void _releaseKeepAlive() {
    _keepAliveHandle!.release();
    _keepAliveHandle = null;
  }

  @protected
  bool get wantKeepAlive;

  @protected
  void updateKeepAlive() {
    if (wantKeepAlive) {
      if (_keepAliveHandle == null) _ensureKeepAlive();
    } else {
      if (_keepAliveHandle != null) _releaseKeepAlive();
    }
  }

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    if (wantKeepAlive) _ensureKeepAlive();
  }

  @override
  void dispose() {
    if (_keepAliveHandle != null) _releaseKeepAlive();
    super.dispose();
  }

  /// original "build" override analog
  @mustCallSuper
  Widget onBuild() {
    if (wantKeepAlive && _keepAliveHandle == null) {
      _ensureKeepAlive();
    }
    return const _NullWidget();
  }
}

class _NullWidget extends StatelessWidget {
  const _NullWidget();

  @override
  Widget build(BuildContext context) {
    throw FlutterError(
      'Widgets that mix AutomaticKeepAliveWidgetModelMixin into their State must '
      'call super.build() but must ignore the return value of the superclass.',
    );
  }
}
