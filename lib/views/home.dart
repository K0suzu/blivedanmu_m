import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController ridController = TextEditingController();
  TextEditingController serverUrlController = TextEditingController();

  bool isValidate = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      String? rid = prefs.getString("rid");
      String? serverUrl = prefs.getString("serverUrl");

      ridController.text = rid ?? "";
      serverUrlController.text = serverUrl ?? "";
      validate();
    });
    super.initState();
  }

  void validate() {
    setState(() {
      isValidate =
          ridController.text.isNotEmpty && serverUrlController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: serverUrlController,
                decoration: const InputDecoration(labelText: "服务器地址"),
                onChanged: (value) {
                  validate();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: ridController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "房间号"),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                onChanged: (value) {
                  validate();
                },
              ),
              const SizedBox(
                height: 30,
              ),
              ConfirmButton(
                enabled: !isValidate,
                onPressed: () {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString("rid", ridController.text);
                    prefs.setString("serverUrl", serverUrlController.text);

                    Navigator.of(context).pushNamed("/danmaku",
                        arguments: {"rid": ridController.text});
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmButton extends StatefulWidget {
  const ConfirmButton(
      {super.key, required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: widget.enabled ? null : widget.onPressed,
        child: const Text('确定'));
  }
}
