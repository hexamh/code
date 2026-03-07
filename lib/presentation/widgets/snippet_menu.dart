import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';

/// Code snippet with a name, language hint, and template text.
class CodeSnippet {
  final String name;
  final String description;
  final String template;
  final IconData icon;

  const CodeSnippet({
    required this.name,
    required this.description,
    required this.template,
    this.icon = Icons.code,
  });
}

/// Built-in code snippets for common patterns.
class SnippetLibrary {
  SnippetLibrary._();

  static const List<CodeSnippet> dartSnippets = [
    CodeSnippet(
      name: 'main',
      description: 'Main function entry point',
      template: 'void main() {\n  \n}\n',
      icon: Icons.play_arrow,
    ),
    CodeSnippet(
      name: 'class',
      description: 'Class declaration',
      template: 'class MyClass {\n  MyClass();\n\n  \n}\n',
      icon: Icons.class_,
    ),
    CodeSnippet(
      name: 'stateless',
      description: 'StatelessWidget template',
      template: '''class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      icon: Icons.widgets,
    ),
    CodeSnippet(
      name: 'stateful',
      description: 'StatefulWidget template',
      template: '''class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      icon: Icons.widgets_outlined,
    ),
    CodeSnippet(
      name: 'try-catch',
      description: 'Try-catch block',
      template: 'try {\n  \n} catch (e) {\n  print(e);\n}\n',
      icon: Icons.error_outline,
    ),
    CodeSnippet(
      name: 'async',
      description: 'Async function',
      template: 'Future<void> myFunction() async {\n  \n}\n',
      icon: Icons.sync,
    ),
    CodeSnippet(
      name: 'for-loop',
      description: 'For loop',
      template: 'for (int i = 0; i < length; i++) {\n  \n}\n',
      icon: Icons.loop,
    ),
    CodeSnippet(
      name: 'if-else',
      description: 'If-else block',
      template: 'if (condition) {\n  \n} else {\n  \n}\n',
      icon: Icons.call_split,
    ),
    CodeSnippet(
      name: 'switch',
      description: 'Switch statement',
      template: 'switch (value) {\n  case first:\n    break;\n  default:\n    break;\n}\n',
      icon: Icons.switch_left,
    ),
    CodeSnippet(
      name: 'enum',
      description: 'Enum declaration',
      template: 'enum MyEnum {\n  value1,\n  value2,\n  value3,\n}\n',
      icon: Icons.list_alt,
    ),
  ];

  static const List<CodeSnippet> webSnippets = [
    CodeSnippet(
      name: 'html5',
      description: 'HTML5 boilerplate',
      template: '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body>
  
</body>
</html>
''',
      icon: Icons.html,
    ),
    CodeSnippet(
      name: 'css-reset',
      description: 'CSS reset base',
      template: '''*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: system-ui, sans-serif;
  line-height: 1.5;
}
''',
      icon: Icons.css,
    ),
    CodeSnippet(
      name: 'arrow-fn',
      description: 'Arrow function (JS/TS)',
      template: 'const myFunction = () => {\n  \n};\n',
      icon: Icons.javascript,
    ),
    CodeSnippet(
      name: 'fetch',
      description: 'Fetch API call',
      template: '''const response = await fetch('url');
const data = await response.json();
console.log(data);
''',
      icon: Icons.cloud_download,
    ),
  ];

  static const List<CodeSnippet> pythonSnippets = [
    CodeSnippet(
      name: 'def',
      description: 'Function definition',
      template: 'def my_function():\n    pass\n',
      icon: Icons.functions,
    ),
    CodeSnippet(
      name: 'class',
      description: 'Class definition',
      template: 'class MyClass:\n    def __init__(self):\n        pass\n',
      icon: Icons.class_,
    ),
    CodeSnippet(
      name: 'if-main',
      description: 'Main guard',
      template: 'if __name__ == "__main__":\n    main()\n',
      icon: Icons.play_arrow,
    ),
    CodeSnippet(
      name: 'list-comp',
      description: 'List comprehension',
      template: 'result = [x for x in items if condition]\n',
      icon: Icons.format_list_bulleted,
    ),
  ];

  /// Returns all snippets grouped by category.
  static Map<String, List<CodeSnippet>> get allGrouped => {
        'Dart / Flutter': dartSnippets,
        'Web (HTML/CSS/JS)': webSnippets,
        'Python': pythonSnippets,
      };
}

/// Bottom sheet for inserting code snippets.
class SnippetMenu extends StatelessWidget {
  final ValueChanged<String> onInsert;

  const SnippetMenu({super.key, required this.onInsert});

  static void show(BuildContext context, {required ValueChanged<String> onInsert}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SnippetMenu(onInsert: onInsert),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = SnippetLibrary.allGrouped;

    return Column(
      children: [
        // Handle
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.code, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Code Snippets',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: grouped.entries.map((group) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      group.key,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...group.value.map((snippet) => ListTile(
                        leading: Icon(snippet.icon, size: 20),
                        title: Text(snippet.name),
                        subtitle: Text(
                          snippet.description,
                          style: context.textTheme.bodySmall,
                        ),
                        trailing: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: context.colorScheme.primary,
                        ),
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);
                          onInsert(snippet.template);
                        },
                      )),
                  const Divider(indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
