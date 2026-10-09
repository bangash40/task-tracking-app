import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/task_service.dart';

/// Add or edit a task. Interns add tasks for themselves; admins pass the
/// [assignee] to assign a task to an intern.
class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;
  final UserModel? assignee;

  const TaskFormScreen({super.key, this.task, this.assignee});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  bool get _isAdmin => context.read<AuthProvider>().profile?.isAdmin ?? false;

  /// Name of the intern the task is for, shown to admins.
  String? get _assigneeName => _isEditing && _isAdmin
      ? widget.task!.assignedToName
      : widget.assignee?.name;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController =
        TextEditingController(text: widget.task?.description);
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final today = AppDates.today;
    final initial = _dueDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // Allow keeping an existing past due date when editing.
      firstDate: initial.isBefore(today) ? initial : today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = AppDates.dayOnly(picked));
      field.didChange(_dueDate);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final profile = context.read<AuthProvider>().profile;
    if (profile == null) return;

    // Admins create tasks for an intern; interns create tasks for themselves.
    final owner = profile.isAdmin ? widget.assignee : profile;
    if (!_isEditing && owner == null) return;

    final service = context.read<TaskService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await service.updateTask(
          widget.task!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            dueDate: _dueDate,
          ),
        );
      } else {
        await service.createTask(
          TaskModel(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            dueDate: _dueDate!,
            assignedTo: owner!.uid,
            assignedToName: owner.name,
            createdBy: profile.uid,
            createdByRole:
                profile.isAdmin ? UserRoles.admin : UserRoles.intern,
          ),
        );
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Task updated'
                : (profile.isAdmin ? 'Task assigned' : 'Task created'),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save the task. Try again.')),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task'),
        content: const Text('This task will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final service = context.read<TaskService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    try {
      await service.deleteTask(widget.task!.id);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Task deleted')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the task. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAdmin
              ? (_isEditing ? 'Edit Assigned Task' : 'Assign Task')
              : (_isEditing ? 'Edit Task' : 'Add Task'),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isAdmin && _assigneeName != null) ...[
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Assigned to',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    child: Text(_assigneeName!),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: Validators.taskTitle,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: Validators.description,
                ),
                const SizedBox(height: 16),
                FormField<DateTime>(
                  initialValue: _dueDate,
                  validator: (value) =>
                      value == null ? 'Due date is required' : null,
                  builder: (field) => InkWell(
                    onTap: () => _pickDate(field),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        errorText: field.errorText,
                      ),
                      child: Text(
                        _dueDate == null
                            ? 'Select a date'
                            : AppDates.format(_dueDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditing
                              ? 'Save Changes'
                              : (_isAdmin ? 'Assign Task' : 'Create Task'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
