import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// 添加密码页占位（桌面端暂不支持添加）。
class CipherAddPage extends StatelessWidget {
  const CipherAddPage({this.vaultId, super.key});

  final String? vaultId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加密码'),
        leading: BackButton(onPressed: AppRouter.pop),
      ),
      body: const Center(child: Text('请使用 iOS/Android 客户端添加密码')),
    );
  }
}
