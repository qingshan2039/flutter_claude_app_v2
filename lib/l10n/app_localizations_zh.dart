// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter Claude 应用';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get navHome => '首页';

  @override
  String get navSearch => '搜索';

  @override
  String get navSettings => '设置';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get loading => '加载中…';

  @override
  String get emptyTitle => '暂无内容';

  @override
  String get emptyMessage => '这里还没有可显示的内容。';

  @override
  String get successMessage => '完成！';

  @override
  String get errorNetwork => '网络异常，请检查网络连接。';

  @override
  String get errorServer => '服务器开小差了，请稍后重试。';

  @override
  String get errorUnauthorized => '登录已过期，请重新登录。';

  @override
  String get errorValidation => '输入有误，请检查后重试。';

  @override
  String get errorUnknown => '发生未知错误。';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get settingsLanguage => '语言';

  @override
  String greetingNamed(String name) {
    return '你好，$name！';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个条目',
      zero: '没有条目',
    );
    return '$_temp0';
  }

  @override
  String unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你有 $count 条未读消息',
      zero: '没有未读消息',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '最近更新：$dateString';
  }

  @override
  String priceLabel(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      symbol: '\$',
      decimalDigits: 2,
    );
    final String amountString = amountNumberFormat.format(amount);

    return '价格：$amountString';
  }

  @override
  String completionRate(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '完成度：$valueString';
  }
}
