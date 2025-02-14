import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dialpad_controller.dart';
import '../../../widgets/call_state_display.dart';

class DialpadView extends GetView<DialpadController> {
  const DialpadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CallStateDisplay(),

            // Number Display Area
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              alignment: Alignment.center,
              child: Obx(() => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Country Code Selector
                          GestureDetector(
                            onTap: () => controller.showCountryPicker(context),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Text(
                                    controller.selectedCountry?.flagEmoji ??
                                        '🌍',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${controller.selectedCountry?.phoneCode ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, size: 20),
                                ],
                              ),
                            ),
                          ),
                          // Phone Number Display
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: controller.scrollController,
                              child: Text(
                                controller.displayNumber,
                                style: const TextStyle(
                                  fontSize: 36,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (controller.inputNumber.isNotEmpty)
                        TextButton.icon(
                          onPressed: controller.clearNumber,
                          icon: const Icon(Icons.backspace_outlined),
                          label: const Text('Clear'),
                        ),
                    ],
                  )),
            ),

            // Dialpad Grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialpadRow(['1', '2', '3']),
                    _buildDialpadRow(['4', '5', '6']),
                    _buildDialpadRow(['7', '8', '9']),
                    _buildDialpadRow(['*', '0', '#']),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: _buildCallButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialpadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildDialButton(number)).toList(),
    );
  }

  Widget _buildDialButton(String number) {
    final Map<String, String> letters = {
      '2': 'ABC',
      '3': 'DEF',
      '4': 'GHI',
      '5': 'JKL',
      '6': 'MNO',
      '7': 'PQRS',
      '8': 'TUV',
      '9': 'WXYZ',
      '0': '+',
    };

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.addNumber(number),
              onLongPress: number == '0' ? controller.onZeroLongPress : null,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (letters.containsKey(number))
                      Text(
                        letters[number]!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.inputNumber.isNotEmpty
              ? () => controller.makeCall()
              : null,
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.call,
            color: Colors.white,
            size: 28,
          ),
        ));
  }
}
