import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class KeepAliveNotification extends Notification {
  final Listenable handle;
  const KeepAliveNotification(this.handle) : assert(handle != null);
}

class KeepAliveHandle extends ChangeNotifier {
  void release() {
    notifyListeners();
  }
}

@optionalTypeArgs
mixin AutomaticKeepAliveWidgetModelMixin<W extends WMWidget<IWM>,
    M extends Model> on WidgetModel<W, M> {
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

  // TODO(butuzov): разобраться в логике, тк в оригинальном миксине здесь возвращается виджет с ошибкой, FLT-1322
  @mustCallSuper
  Widget build(IWM wm) {
    if (wantKeepAlive && _keepAliveHandle == null) _ensureKeepAlive();
    return const _NullWidget();
  }
}

class _NullWidget extends StatelessWidget {
  const _NullWidget();

  @override
  Widget build(BuildContext context) {
    throw FlutterError(
      'Widgets that mix AutomaticKeepAliveClientMixin into their State must '
      'call super.build() but must ignore the return value of the superclass.',
    );
  }
}
