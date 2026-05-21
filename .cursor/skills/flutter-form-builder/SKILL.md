---
name: flutter-form-builder
description: Build Flutter forms with flutter_form_builder, form_builder_validators, form_builder_file_picker, and form_builder_image_picker. Use when creating or modifying Flutter forms, FormBuilder widgets, validation rules, file/image fields, or when the user mentions flutter_form_builder or FormBuilderValidators.
---

# Flutter Form Builder

## Packages

Use these packages unless the user requests different versions:

```yaml
dependencies:
  flutter_form_builder: ^10.3.0+2
  form_builder_validators: ^11.3.0
  form_builder_file_picker: ^5.1.0
  form_builder_image_picker: ^4.4.0
```

Add dependencies with Flutter tooling from the package that owns the form:

```bash
flutter pub add 'flutter_form_builder:^10.3.0+2' 'form_builder_validators:^11.3.0' 'form_builder_file_picker:^5.1.0' 'form_builder_image_picker:^4.4.0'
```

## Imports

Use only the imports needed by the fields in the file:

```dart
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
```

## Form Pattern

Use `FormBuilder` for form state and keep a typed boundary between UI form values and domain/application models.

```dart
final _formKey = GlobalKey<FormBuilderState>();

FormBuilder(
  key: _formKey,
  initialValue: const {
    'email': '',
  },
  child: Column(
    children: [
      FormBuilderTextField(
        name: 'email',
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.email(),
        ]),
      ),
      FilledButton(
        onPressed: () {
          final form = _formKey.currentState;
          if (form == null || !form.saveAndValidate()) return;
          final values = form.value;
          // Map values into a typed request/draft before calling the ViewModel.
        },
        child: const Text('Save'),
      ),
    ],
  ),
);
```

Prefer `saveAndValidate()` for submit actions. Use `fields['fieldName']?.didChange(value)` for controlled updates instead of maintaining duplicate `TextEditingController` or local field state unless the widget requires it.

## Supported Fields

Choose the narrowest field that matches the input:

- Boolean: `FormBuilderCheckbox`, `FormBuilderSwitch`
- Single selection: `FormBuilderDropdown`, `FormBuilderRadioGroup`, `FormBuilderChoiceChip`, `FormBuilderSearchableDropdown`, `FormBuilderTypeAhead`
- Multiple selection: `FormBuilderCheckboxGroup`, `FormBuilderFilterChip`
- Text and formatted strings: `FormBuilderTextField`
- Date/time: `FormBuilderDateTimePicker`, `FormBuilderDateRangePicker`
- Numeric range/value: `FormBuilderSlider`, `FormBuilderRangeSlider`, `FormBuilderTouchSpin`, `FormBuilderRating`
- Media and files: `FormBuilderFilePicker`, `FormBuilderImagePicker`
- Specialty input: `FormBuilderColorPicker`, `FormBuilderSignaturePad`

Every field must have a stable `name`. Match `initialValue` types to the widget's value type.
Before using specialty fields, verify the current package exports/imports in the target app. Ask before adding any package beyond the versions listed above.

## Validator Pattern

Use `FormBuilderValidators.compose([...])` for normal AND validation. Use extension methods for readable conditional or chained validation when it stays clearer than a list.

```dart
validator: FormBuilderValidators.compose([
  FormBuilderValidators.required(),
  FormBuilderValidators.minLength(8),
  FormBuilderValidators.hasUppercaseChars(atLeast: 1),
  FormBuilderValidators.hasNumericChars(atLeast: 1),
]),
```

Use validator categories by intent:

- Required and composition: `required`, `compose`, `aggregate`, `conditional`, `skipWhen`, `or`, `defaultValue`, `transform`
- Boolean: `isTrue`, `isFalse`, `hasLowercaseChars`, `hasUppercaseChars`, `hasNumericChars`, `hasSpecialChars`
- Collection/length/range: `minLength`, `maxLength`, `equalLength`, `containsElement`, `unique`, `range`
- Date/time: `date`, `dateTime`, `dateFuture`, `datePast`, `dateRange`, `time`, `timeZone`
- File: `fileExtension`, `fileName`, `fileSize`, `mimeType`, `path`
- Finance/identity/network: `creditCard`, `iban`, `bic`, `password`, `username`, `email`, `url`, `phoneNumber`, `ip`, `latitude`, `longitude`
- Numeric: `numeric`, `integer`, `min`, `max`, `between`, `positiveNumber`, `negativeNumber`, `notZeroNumber`, `evenNumber`, `oddNumber`, `prime`
- String/use-case: `alphabetical`, `contains`, `startsWith`, `endsWith`, `match`, `matchNot`, `singleLine`, `minWordsCount`, `maxWordsCount`, `base64`, `colorCode`, `json`, `uuid`, `isbn`, `vin`

Override messages with `.withErrorMessage('...')` when the default message is not product-appropriate.

## File And Image Inputs

For file/image fields, validate both client-side selection constraints and server-side expectations. Use file validators for extension, size, MIME type, filename, and path. Keep picked file objects in the form only long enough to map them into the app's upload model or request.

## Project Conventions

When a form submits to app state, callbacks should call the feature ViewModel/use case with typed values. Do not place business logic, API calls, or error string construction inside the widget. For full screens, keep following the project state architecture: one screen provider, typed `ScreenState`, and `ref.read` only in callbacks.
