import 'package:flutter/material.dart';

mixin UpdateState<T extends StatefulWidget> on State<T> {
  void updateState() {
    if (mounted) setState(() {});
  }
}
