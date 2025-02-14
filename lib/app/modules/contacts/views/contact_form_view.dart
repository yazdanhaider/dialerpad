import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_form_controller.dart';

class ContactFormView extends GetView<ContactFormController> {
  const ContactFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text(controller.isEditing.value ? 'Edit Contact' : 'Add Contact')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: controller.saveContact,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.grey),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                          onPressed: controller.pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name Fields
              TextFormField(
                controller: controller.firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Numbers Section
              Obx(() => Column(
                    children: [
                      ...controller.phoneControllers.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: entry.value,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: entry.key == 0
                                            ? 'Phone Number'
                                            : 'Additional Phone',
                                        prefixIcon: const Icon(Icons.phone),
                                      ),
                                      validator: (value) {
                                        if (entry.key == 0 &&
                                            (value == null || value.isEmpty)) {
                                          return 'Please enter phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  if (entry.key > 0)
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => controller
                                          .removePhoneField(entry.key),
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                            ),
                          ),
                      TextButton.icon(
                        onPressed: controller.addPhoneField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Another Phone Number'),
                      ),
                    ],
                  )),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Company Field
              TextFormField(
                controller: controller.companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
